//
//  DateUtils.m
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

+(NSString*) getDateAgo24 {
    int curTime = (int)[[NSDate date] timeIntervalSince1970];
    int ago24 = 24 * 60 * 60;
    int res = curTime - ago24;
    
    NSString* resStr = [NSString stringWithFormat:@"%d", res];
    return resStr;
}

+(NSString*) getDate {
    NSString * timeStamp = [NSString stringWithFormat:@"%lld",(long long)[[NSDate date] timeIntervalSince1970]];
    
    return timeStamp;
}

+(long long) getLongDateAgo24 {
    long long curTime = (long long)[[NSDate date] timeIntervalSince1970];
    long long ago24 = 24 * 60 * 60;
    long long res = curTime - ago24;
    
    return res;
}

+(long long) getLongDate {
    long long timeStamp = (long long)[[NSDate date] timeIntervalSince1970];
    
    return timeStamp;
}

@end
