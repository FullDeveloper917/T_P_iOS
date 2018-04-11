//
//  Utils.m
//  TP
//
//  Created by Bailang on 12/2/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(NSString*)validateTitle: (NSString*)title {
    title = [title stringByReplacingOccurrencesOfString:@"." withString:@"&period;"];
    title = [title stringByReplacingOccurrencesOfString:@"#" withString:@"&num;"];
    title = [title stringByReplacingOccurrencesOfString:@"$" withString:@"&dollar;"];
    title = [title stringByReplacingOccurrencesOfString:@"[" withString:@"&lsqb;"];
    title = [title stringByReplacingOccurrencesOfString:@"]" withString:@"&rsqb;"];
    
    return title;
}

+(NSString*)displayTitle: (NSString*)title {
    title = [title stringByReplacingOccurrencesOfString:@"&period;" withString:@"."];
    title = [title stringByReplacingOccurrencesOfString:@"&num;" withString:@"#"];
    title = [title stringByReplacingOccurrencesOfString:@"&dollar;" withString:@"$"];
    title = [title stringByReplacingOccurrencesOfString:@"&lsqb;" withString:@"["];
    title = [title stringByReplacingOccurrencesOfString:@"&rsqb;" withString:@"]"];
    
    return title;
}

@end
