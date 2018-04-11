//
//  FirebaseDBHelper.h
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"

typedef void(^CheckResult)(int status);
typedef void(^Result)(int status);
typedef void(^FetchMarkersResult)(NSArray* markers);
typedef void(^FetchMarkerNum)(NSInteger marker_num);

@import FirebaseDatabase;

@protocol FirebaseDBHelperDelegate <NSObject>

@optional

- (void)onFetchTopicListSucceed: (NSArray *) topicArray;
- (void)onFetchTopicListFailed;

- (void)onFetchTopicSucceed: (Topic*)topic;

- (void)onFetchMarders: (NSInteger)count;

@end

@interface FirebaseDBHelper : NSObject

@property(nonatomic,assign) id<FirebaseDBHelperDelegate> delegate;

@property(strong, nonatomic) FIRDatabaseReference *ref;

+(FirebaseDBHelper *) instance;

-(void) checkTopic:(NSString *)title callback:(CheckResult)checkResult;
-(void) createTopic:(NSString *)title callback:(Result)callback;

-(void) addMarker: (NSString*)title callback:(Result)callback;

-(void) fetchMarkers:(NSString*)title callback:(FetchMarkersResult)callback;
-(void) fetchMarkersNum:(NSString*)title callback:(FetchMarkerNum)callback;

-(void) fetchTopicList;
-(void) fetchTopic:(NSString*)title;
-(void) fetchMarker:(NSString*)title;

@end
