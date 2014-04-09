//
//  EntryData.h
//  parsed
//
//  Created by Aaron Burke on 4/8/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntryData : NSObject <NSCoding>

@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSNumber *number;
@property (nonatomic,strong) NSString *parseObjId;


- (id)initWithMessage:(NSString*)message  name:(NSString*)name
                                        number:(NSNumber*)number;

- (id)initWithUUID:(NSString*)UUID message:(NSString*)message
                                      name:(NSString*)name
                                    number:(NSNumber*)number
                                parseObjId:(NSString*)parseObjectId;


- (NSString*)getUUID;

@end
