//
//  EntryData.m
//  parsed
//
//  Created by Aaron Burke on 4/8/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "EntryData.h"

@interface EntryData ()

// Private variable for the UUID creation
@property (nonatomic,strong) NSString *UUID;

@end

@implementation EntryData

- (id)initWithMessage:(NSString*)message name:(NSString*)name number:(NSNumber*)number {
    if ((self = [super init])) {
        self.message = message;
        self.name = name;
        self.number = number;
        self.UUID = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (id)initWithUUID:(NSString*)UUID message:(NSString*)message name:(NSString*)name number:(NSNumber*)number {
    if ((self = [super init])) {
        self.message = message;
        self.name = name;
        self.number = number;
        self.UUID = UUID;
    }
    return self;
}

#pragma mark NSCoding

#define kMessageKey     @"message"
#define kNameKey        @"name"
#define kNumberKey      @"number"
#define kUUIDKey        @"UUID"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.message = [decoder decodeObjectForKey:kMessageKey];
    self.number = [decoder decodeObjectForKey:kNumberKey];
    self.name = [decoder decodeObjectForKey:kNameKey];
    self.UUID = [decoder decodeObjectForKey:kUUIDKey];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.message forKey:kMessageKey];
    [encoder encodeObject:self.number forKey:kNumberKey];
    [encoder encodeObject:self.name forKey:kNameKey];
    [encoder encodeObject:self.UUID forKey:kUUIDKey];
}

#pragma getUUID
// Getter for readonly property
- (NSString*)getUUID
{
    return [self.UUID copy];
}

@end
