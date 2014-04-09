//
//  EntryManager.m
//  parsed
//
//  Created by Aaron Burke on 4/8/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "EntryManager.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface EntryManager ()

@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation EntryManager


+(EntryManager*)sharedInstance;
{
    static EntryManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[EntryManager alloc] init];
        
    });
    return _instance;
}

- (id)init {
    if (self = [super init]) {
        self.entryArray = [[NSMutableArray alloc] init];
        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([self getEntryData] != NULL) {
            self.entryArray = [[self getEntryData] mutableCopy];
        }
    }
    return self;
}

- (NSMutableArray*)getEntryData
{
    self.paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [self.paths objectAtIndex:0];
    self.filePath = [self.documentsDirectory stringByAppendingPathComponent: @"entryData.plist"];
    
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePath];
    
    
}

- (void)saveEntryData:(EntryData*)entry isNewCache:(BOOL)isNewCache
{
    // Save local data
    [self.entryArray addObject:entry];
    BOOL saveStatus = [NSKeyedArchiver archiveRootObject:self.entryArray toFile:self.filePath];
    
    if (!isNewCache) {
        // Save to Parse
        [self saveToParse:entry];
    }
    
    // Used to get the top most visible VC in this case CreateItemVC to use as delegate of our alertView
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if (saveStatus) {
        // Show success message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"Successfully saved entry" delegate:topController cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:@"Failed to save entry" delegate:topController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

- (void)saveToParse:(EntryData*)entry
{
    
    // Parse object creation
    PFObject *entryParse = [PFObject objectWithClassName:@"Entry"];
    entryParse[@"message"] = entry.message;
    entryParse[@"name"] = entry.name;
    entryParse[@"number"] = entry.number;
    entryParse[@"UUID"] = [entry getUUID];
    entryParse.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    
    if (self.appDelegate.isNetworkActive) {
        // Save now
        [entryParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error) {
                
                PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
                [query whereKey:@"UUID" equalTo:[entryParse objectForKey:@"UUID"]];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        NSLog(@"Successfully saved entry to Parse DB.");
                        
                        [self updateCacheIdData:object];
                        
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
                
            } else {
                
                NSLog(@"Error: %@", [error localizedDescription]);
                
            }
            
        }];
    } else {
        // Save later when network is re-established
        [entryParse saveEventually:^(BOOL succeeded, NSError *error) {
            if (!error) {
                PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
                [query whereKey:@"UUID" equalTo:[entryParse objectForKey:@"UUID"]];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        NSLog(@"Successfully saved entry to Parse DB.");
                        
                        [self updateCacheIdData:object];
                        
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }
}

- (void)createDataFromParse:(NSArray*)parseObjects
{
    for (PFObject *object in parseObjects) {
        EntryData *entry = [[EntryData alloc] initWithUUID:[object objectForKey:@"UUID"] message:[object objectForKey:@"message"] name:[object objectForKey:@"name"] number:[object objectForKey:@"number"] parseObjId:object.objectId];
        [self saveEntryData:entry isNewCache:YES];
    }
}

- (void)deleteEntryData:(EntryData*)entry
{
    // Delete item from local cache
    for (EntryData *entryCacheObj in self.entryArray) {
        if ([[entry getUUID] isEqualToString:[entryCacheObj getUUID]]) {
            [self.entryArray removeObject:entryCacheObj];
            break;
        }
    }
    [NSKeyedArchiver archiveRootObject:self.entryArray toFile:self.filePath];
    
    // Delete item from Parse
    if (self.appDelegate.isNetworkActive) {
        PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
        [query whereKey:@"UUID" equalTo:[entry getUUID]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully deleted entry from Parse.");
                
                if (self.appDelegate.isNetworkActive) {
                    [object deleteInBackground];
                } else {
                    [object deleteEventually];
                }
                
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

// Update cache entry with parse objectId data after saved to DB
- (void)updateCacheIdData:(PFObject*)entry
{
    for (EntryData *entryCacheObj in self.entryArray) {
        if ([[entry objectForKey:@"UUID"] isEqualToString:[entryCacheObj getUUID]]) {
            entryCacheObj.parseObjId = entry.objectId;
        }
    }
    // Save back to disk
    [NSKeyedArchiver archiveRootObject:self.entryArray toFile:self.filePath];
    
}

@end
