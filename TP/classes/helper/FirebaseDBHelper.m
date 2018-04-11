//
//  FirebaseDBHelper.m
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "FirebaseDBHelper.h"
#import "Consts.h"
#import "DateUtils.h"
#import "UserInfo.h"
#import "LocationHelper.h"
#import "Marker.h"

@import FirebaseAuth;

@implementation FirebaseDBHelper

+(FirebaseDBHelper *) instance {
    
    static dispatch_once_t p = 0;
    
    __strong static FirebaseDBHelper * _pObj = nil;
    
    dispatch_once(&p, ^{
        _pObj = [[self alloc] init];
        _pObj.ref = [[FIRDatabase database] reference];
    });
    
    return _pObj;
}

-(void) checkTopic:(NSString *)title callback:(CheckResult)checkResult {
    [[[_ref child:C_TOPIC] child:title] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSInteger cnt = snapshot.childrenCount;
        if(cnt == 1) {
            checkResult(1);
        }
        else {
            checkResult(0);
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        checkResult(0);
        NSLog(@"%@", error.localizedDescription);
    }];
}

-(void) createTopic:(NSString *)title callback:(Result)callback {
    [[_ref child:C_TOPIC] updateChildValues:@{title: title} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(error == nil) {
            callback(1);
        }
        else {
            callback(0);
        }
    }];
}

-(void) addMarker: (NSString*)title callback:(Result)callback {
    NSString* user_id = [UserInfo instance].user_id;
    NSString* date = [DateUtils getDate];
    CLLocation* userLocation = [LocationHelper instance].userLocation;
    double latitude = userLocation.coordinate.latitude;
    double longitude = userLocation.coordinate.longitude;
    NSString* location = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
    
    [[[[_ref child:C_TOPIC] child:title] child:user_id] setValue:@{@"date":date, @"location":location} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(error == nil) {
            callback(1);
        }
        else {
            callback(0);
        }
    }];
}

-(void) fetchMarkers:(NSString*)title callback:(FetchMarkersResult)callback {
    NSString* aDate = [DateUtils getDateAgo24];
    [[[[[_ref child:C_TOPIC] child:title] queryOrderedByChild:@"date"] queryStartingAtValue:aDate] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSMutableArray* markerList = [[NSMutableArray alloc] init];
        for(snapshot in snapshot.children) {
            NSString* location = snapshot.value[@"location"];
            NSString* strDate = snapshot.value[@"date"];
            
            Marker* marker = [[Marker alloc] initWithLocation:location andDate:strDate];
            [markerList addObject:marker];
        }
        
        callback(markerList);
    }];
}

-(void) fetchMarkersNum:(NSString*)title callback:(FetchMarkerNum)callback {
    NSString* aDate = [DateUtils getDateAgo24];
    [[[[[_ref child:C_TOPIC] child:title] queryOrderedByChild:@"date"] queryStartingAtValue:aDate] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        callback(snapshot.childrenCount);
    }];
}

-(void) fetchTopicList {
    [[_ref child:C_TOPIC] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *_Nonnull snapshot){
        NSMutableArray* topicArray = [[NSMutableArray alloc] init];
        for(snapshot in snapshot.children) {
            NSString* title = snapshot.key;

            Topic* topic = [[Topic alloc] initWithTitle:title];
            topic.count = snapshot.childrenCount;
            [topicArray addObject:topic];
        }

        [self.delegate onFetchTopicListSucceed:topicArray];
    }];
}

-(void) fetchTopic:(NSString*)title {
    NSString* aDate = [DateUtils getDateAgo24];
    [[[[[_ref child:C_TOPIC] child:title] queryOrderedByChild:@"date"] queryStartingAtValue:aDate] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString* title = snapshot.key;
        NSInteger count = snapshot.childrenCount;
        NSLog(@"%@: %ld", title, (long)count);
        NSLog(@"ADate: %@", aDate);
        
        double maxDate = [aDate doubleValue];
        bool flag = false;
        NSString* user_id = [UserInfo instance].user_id;
        for(snapshot in snapshot.children) {
            NSString* key = snapshot.key;
            NSString* location = snapshot.value[@"location"];
            NSString* strDate = snapshot.value[@"date"];
            double date = maxDate;
            if(![strDate isEqualToString:@""]) {
                date = [strDate doubleValue];
            }
            
            if([user_id isEqualToString:key]) {
                if(maxDate < date) {
                    maxDate = date;
                    flag = true;
                }
            }
            
            NSLog(@"key: %@", key);
            NSLog(@"location: %@", location);
            NSLog(@"date: %@", strDate);
        }
        
        Topic* topic = [[Topic alloc] initWithTitle:title];
        topic.count = count;
        topic.recentDate = maxDate;
        
        [self.delegate onFetchTopicSucceed:topic];
    }];
}

@end
