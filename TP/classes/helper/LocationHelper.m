//
//  LocationHelper.m
//  FEETRS
//
//  Created by PC on 9/16/15.
//  Copyright (c) 2015 PC. All rights reserved.
//

#import "LocationHelper.h"

@implementation LocationHelper

+(LocationHelper *) instance {
     static dispatch_once_t p = 0;
     
     __strong static LocationHelper * _sharedObject = nil;
     
     dispatch_once(&p, ^{
          _sharedObject = [[self alloc] init];
     });
     
     return _sharedObject;
}

- (instancetype)init {
     
     self = [super init];
     if (self) {
          
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLocationManager) name:@"LocationAuthorizationStatusChanged" object:nil];
     }
     
     return self;
}

- (void)initCurrentLocation
{
     if (self.locationManager == nil)
     {
          self.locationManager = [[CLLocationManager alloc] init];
          self.locationManager.delegate = self;
          self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
          self.locationManager.distanceFilter = kCLDistanceFilterNone; //kCLDistanceFilterNone// kDistanceFilter;
     }
     
     if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
          [self.locationManager requestWhenInUseAuthorization];
     }
     
     [self startLocationManager];
}

- (void)startLocationManager {
     [self.locationManager startUpdatingLocation];
}

- (void)stopLocationManager {
     [self.locationManager stopUpdatingLocation];
}

#pragma mark -
#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations {
     
     self.userLocation = [locations lastObject];
     
#if DEBUG
     NSLog(@"=====> New Location = (%f, %f)",
           self.userLocation.coordinate.latitude,
           self.userLocation.coordinate.longitude);
#endif
     
     [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLocationUpdated" object:self];
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
#if DEBUG
     NSLog(@"=====> User Location Failed : %@", error.localizedDescription);
#endif

     
     [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLocationUpdateFailed" object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
     
#if DEBUG
     NSString* strStatus = @"NotDetermined";
     switch (status) {
          case kCLAuthorizationStatusNotDetermined:
               strStatus = @"NotDetermined"; break;
          case kCLAuthorizationStatusRestricted:
               strStatus = @"Restricted"; break;
          case kCLAuthorizationStatusDenied:
               strStatus = @"Denied"; break;
          case kCLAuthorizationStatusAuthorizedAlways:
               strStatus = @"AuthorizedAlways"; break;
          case kCLAuthorizationStatusAuthorizedWhenInUse:
               strStatus = @"AuthorizedWhenInUse"; break;
               
          default:
               break;
     }
     NSLog(@"=====> User didChangeAuthorizationStatus : %d (%@)", status, strStatus);
#endif
     
     [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationAuthorizationStatusChanged" object:[NSNumber numberWithInt:status]];
}

@end
