//
//  TopicManger.h
//  TP
//
//  Created by Bailang on 11/24/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicManager : NSObject

@property(strong, nonatomic) NSMutableArray *tempTopicAllList;

@property(strong, nonatomic) NSMutableArray *topicAllList;
@property(strong, nonatomic) NSArray *recentTopicList;
@property(strong, nonatomic) NSArray *searchTopicList;

+(TopicManager *) instance;

-(void) getTopic: (NSString*)title;

-(void) fetchTopicList;
-(NSArray*) fetchSearchArray: (NSString*)text;

@end
