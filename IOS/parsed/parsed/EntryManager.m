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
    [NSKeyedArchiver archiveRootObject:self.entryArray toFile:self.filePath];
    
    if (!isNewCache) {
        // Save to Parse
        [self saveToParse:entry];
    }
    
    
}

- (void)saveToParse:(EntryData*)entry
{
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // Used to get the top most visible VC in this case CreateItemVC to use as delegate of our alertView
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
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
                // Show success message
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"Successfully saved entry" delegate:topController cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:topController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }
            
        }];
    } else {
        // Save later when network is re-established
        [entryParse saveEventually];
        
    }
}

- (void)createDataFromParse:(NSArray*)parseObjects
{
    for (PFObject *object in parseObjects) {
        EntryData *entry = [[EntryData alloc] initWithUUID:[object objectForKey:@"UUID"] message:[object objectForKey:@"message"] name:[object objectForKey:@"name"] number:[object objectForKey:@"number"]];
        [self saveEntryData:entry isNewCache:YES];
    }
}

- (void)deleteEntryData:(EntryData*)entry
{
    
}
@end
