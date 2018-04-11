//
//  Mark.h
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Marker : NSObject

@property(strong, nonatomic) NSString *location;
@property(strong, nonatomic) NSString *date;

- (instancetype)initWithLocation:(NSString *)location
                         andDate:(NSString *)date;

@end
