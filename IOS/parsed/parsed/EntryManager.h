//
//  EntryManager.h
//  parsed
//
//  Created by Aaron Burke on 4/8/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntryData.h"

@interface EntryManager : NSObject

@property (nonatomic, strong) NSMutableArray *entryArray;

+(EntryManager*)sharedInstance;

-(NSMutableArray*)getEntryData;

- (void)saveEntryData:(EntryData*)entry isNewCache:(BOOL)isNewCache isEditingItem:(BOOL)isEditingItem;
- (void)deleteEntryData:(EntryData*)entry;
- (void)createDataFromParse:(NSArray*)parseObjects;
                             
@end
