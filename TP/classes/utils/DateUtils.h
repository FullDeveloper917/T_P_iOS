//
//  DateUtils.h
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+(NSString*) getDateAgo24;
+(NSString*) getDate;
+(long long) getLongDateAgo24;
+(long long) getLongDate;

@end
