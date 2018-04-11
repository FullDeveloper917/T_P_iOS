//
//  Mark.m
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "Marker.h"

@implementation Marker

- (instancetype)init {
    return [self initWithLocation:@"" andDate:@""];
}

- (instancetype)initWithLocation:(NSString *)location
                         andDate:(NSString *)date; {
    
    self = [super init];
    if(self) {
        self.location = location;
        self.date = date;
    }
 
    return self;
}

@end
