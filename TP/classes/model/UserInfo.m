//
//  UserInfo.m
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+(UserInfo *) instance {
    
    static dispatch_once_t p = 0;
    
    __strong static UserInfo * _pObj = nil;
    
    dispatch_once(&p, ^{
        _pObj = [[self alloc] init];
        
        _pObj.user_id = @"";
    });
    
    return _pObj;
}

@end
