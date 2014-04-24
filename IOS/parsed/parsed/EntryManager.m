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
@property (nonatomic, strong) NSString *filePathCache;
@property (nonatomic, strong) NSString *filePathOfflineSave;
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
        self.offlineSavedArray = [[NSMutableArray alloc] init];
        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([self getEntryData] != NULL) {
            self.entryArray = [[self getEntryData] mutableCopy];
        }
        if ([self getEntryOfflineSaveData] != NULL) {
            self.offlineSavedArray = [[self getEntryOfflineSaveData] mutableCopy];
        }
    }
    return self;
}

- (NSMutableArray*)getEntryData
{
    self.paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [self.paths objectAtIndex:0];
    self.filePathCache = [self.documentsDirectory stringByAppendingPathComponent: @"entryData.plist"];
    
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePathCache];
    
    
}

- (NSMutableArray*)getEntryOfflineSaveData
{
    self.paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [self.paths objectAtIndex:0];
    self.filePathOfflineSave = [self.documentsDirectory stringByAppendingPathComponent: @"offlineSavedData.plist"];
    
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePathOfflineSave];
    
    
}

- (void)saveEntryData:(EntryData*)entry isNewCache:(BOOL)isNewCache isEditingItem:(BOOL)isEditingItem
{
    // Used to get the top most visible VC in this case CreateItemVC to use as delegate of our alertView
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if (!isEditingItem) {
        // New entry
        // Save local data
        [self.entryArray addObject:entry];
        BOOL saveStatus = [NSKeyedArchiver archiveRootObject:self.entryArray toFile:self.filePathCache];
        
        if (!isNewCache) {
            // Save to Parse
            [self saveToParse:entry];
            
            if (saveStatus) {
                // Show success message
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Complete" message:@"Successfully saved entry" delegate:topController cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:@"Failed to save entry" delegate:topController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        
        
    } else {
        // Editing an existing entry
        int entryIndex = 0;
        for (int i = 0, j = self.entryArray.count; i<j ; i++) {
            if ([[self.entryArray[i] getUUID] isEqualToString:[entry getUUID]]) {
                entryIndex = i;
                EntryData *cachedEntry = self.entryArray[i];
                cachedEntry.name  = entry.name;
                cachedEntry.message = entry.message;
                cachedEntry.number = entry.number;
                break;
            }
            
        }

        BOOL saveStatus = [NSKeyedArchiver archiveRootObject:self.entryArray toFile:self.filePathCache];
        
        [self updateToParse:[self.entryArray objectAtIndex:entryIndex] indexNum:entryIndex];
        
        if (saveStatus) {
            // Show success message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit Complete" message:@"Successfully edited entry" delegate:topController cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit Failed" message:@"Failed to edit entry" delegate:topController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
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
        [self.offlineSavedArray addObject:entry];
        [NSKeyedArchiver archiveRootObject:self.offlineSavedArray toFile:self.filePathOfflineSave];
        
    }
}

- (void)updateToParse:(EntryData*)entry indexNum:(int)indexNum
{
    if (self.appDelegate.isNetworkActive) {
        PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
        [query whereKey:@"UUID" equalTo:[entry getUUID]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *entryFromParse, NSError *error) {
            
            entryFromParse[@"message"] = entry.message;
            entryFromParse[@"name"] = entry.name;
            entryFromParse[@"number"] = entry.number;
            [entryFromParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    NSLog(@"Successfully saved entry to Parse DB.");
                } else {
                    
                    NSLog(@"Error: %@", [error localizedDescription]);
                    
                }
                
            }];;
            
        }];
    } else {
       
        for (EntryData *entryOfflineSaved in self.offlineSavedArray) {
            if ([[entryOfflineSaved getUUID] isEqualToString:[entry getUUID]]) {
                [self.offlineSavedArray removeObject:entryOfflineSaved];
            }
        }
        
        [self.offlineSavedArray addObject:entry];
        [NSKeyedArchiver archiveRootObject:self.offlineSavedArray toFile:self.filePathOfflineSave];
        
    }
}

- (void)createDataFromParse:(NSArray*)parseObjects
{
    for (PFObject *object in parseObjects) {
        EntryData *entry = [[EntryData alloc] initWithUUID:[object objectForKey:@"UUID"] message:[object objectForKey:@"message"] name:[object objectForKey:@"name"] number:[object objectForKey:@"number"] parseObjId:object.objectId];
        [self saveEntryData:entry isNewCache:YES isEditingItem:NO];
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
    [NSKeyedArchiver archiveRootObject:self.entryArray toFile:self.filePathCache];
    
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
    [NSKeyedArchiver archiveRootObject:self.entryArray toFile:self.filePathCache];
    
}

// Implemented this method to remove parse saveEventually
// Updates parse.com with the correct offline data immediately when network returns
// Parse.com saveEventually proved unreliable
- (void)updateParseWithSavedData {
    NSMutableArray *parseObjects;
    if (parseObjects == NULL) {
        parseObjects = [[NSMutableArray alloc] init];
    } else {
        [parseObjects removeAllObjects];
    }
    for (EntryData *entry in self.offlineSavedArray) {
        PFObject *entryParse = [PFObject objectWithClassName:@"Entry"];
        if ([entry.parseObjId length] != 0) {
                entryParse.objectId = entry.parseObjId;
        }
        entryParse[@"message"] = entry.message;
        entryParse[@"name"] = entry.name;
        entryParse[@"number"] = entry.number;
        entryParse[@"UUID"] = [entry getUUID];
        [parseObjects addObject:entryParse];
    }
    [PFObject saveAllInBackground:parseObjects block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Show success message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Complete" message:@"Successfully saved entry" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.offlineSavedArray removeAllObjects];
            [NSKeyedArchiver archiveRootObject:self.offlineSavedArray toFile:self.filePathOfflineSave];
        }
    }];
}

@end
