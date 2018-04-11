//
//  Topic.m
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "Topic.h"

@implementation Topic

- (instancetype)init {
    return [self initWithTitle:@""];
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

- (NSComparisonResult)compare:(Topic *)otherObject {
    if(self.recentDate > otherObject.recentDate) {
        return NSOrderedAscending;
    }
    else if(self.recentDate == otherObject.recentDate) {
        if(self.count > otherObject.count) {
            return NSOrderedAscending;
        }
        else if(self.count == otherObject.count) {
            return NSOrderedSame;
        }
    }
    
    return NSOrderedDescending;
}

- (NSComparisonResult)compareCount:(Topic *)otherObject {
    if(self.count > otherObject.count) {
        return NSOrderedAscending;
    }
    else if(self.count == otherObject.count) {
        return NSOrderedSame;
    }
    
    return NSOrderedDescending;
}

@end
