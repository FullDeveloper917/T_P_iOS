//
//  UserInfo.h
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (strong, nonatomic) NSString* user_id;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

+(UserInfo *) instance;

@end
