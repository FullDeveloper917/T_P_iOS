//
//  Topic.h
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Topic : NSObject

@property(strong, nonatomic) NSString *title;
@property(nonatomic) double recentDate;
@property(nonatomic) NSInteger count;

- (instancetype)initWithTitle:(NSString *)title;

- (NSComparisonResult)compare:(Topic *)otherObject;
- (NSComparisonResult)compareCount:(Topic *)otherObject;

@end
