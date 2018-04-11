//
//  TopicManger.m
//  TP
//
//  Created by Bailang on 11/24/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "TopicManager.h"
#import "FirebaseDBHelper.h"

@interface TopicManager () <FirebaseDBHelperDelegate>
@end

@implementation TopicManager

+(TopicManager *) instance {
    static dispatch_once_t p = 0;
    
    __strong static TopicManager * _pObj = nil;
    
    dispatch_once(&p, ^{
        _pObj = [[self alloc] init];
    });
    
    return _pObj;
}

-(instancetype) init {
    
    self = [super init];
    if(self) {
        [self setDelegate];
        self.topicAllList = [[NSMutableArray alloc] init];
        
        self.tempTopicAllList = [[NSMutableArray alloc] init];
        
        self.recentTopicList = [[NSArray alloc] init];
        self.searchTopicList = [[NSArray alloc] init];
    }
    
    return self;
}

-(void) setDelegate {
    [FirebaseDBHelper instance].delegate = self;
}

-(void) getTopic: (NSString*)title {
    
}

-(void) fetchTopicList {
    [[FirebaseDBHelper instance] fetchTopicList];
}

-(void) onFetchTopicListSucceed:(NSArray *)topicArray {
    [self.topicAllList removeAllObjects];
    [self.topicAllList addObjectsFromArray:topicArray];
    
    [self onFetchTopic];
}

-(void) onFetchTopic {
    [self.tempTopicAllList removeAllObjects];
    NSInteger cnt = self.topicAllList.count;
    for(int i = 0; i < cnt; i++) {
        Topic* topic = [self.topicAllList objectAtIndex:i];
        [[FirebaseDBHelper instance] fetchTopic:topic.title];
    }
}

- (void)onFetchTopicSucceed: (Topic*)topic {
    [self.tempTopicAllList addObject:topic];
    
    if(self.topicAllList.count == self.tempTopicAllList.count) {
        [self sortRecentArray];
        [self sortSearchArray];
    }
}

- (void)sortRecentArray {
    self.recentTopicList = [self.tempTopicAllList sortedArrayUsingSelector:@selector(compare:)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedRecentTopicList" object:self];
}

- (void)sortSearchArray {
    self.searchTopicList = [self.tempTopicAllList sortedArrayUsingSelector:@selector(compareCount:)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedSearchTopicList" object:self];
}

-(NSArray*) fetchSearchArray: (NSString*)text {
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.searchTopicList.count; i++) {
        Topic* topic = [self.searchTopicList objectAtIndex:i];
        NSString* title = [topic.title lowercaseString];
        text = [text lowercaseString];
        if([title containsString:text]) {
            [resultArray addObject:topic];
        }
    }
    
    return resultArray;
}

@end
