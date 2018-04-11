//
//  LocationHelper.h
//  FEETRS
//
//  Created by PC on 9/16/15.
//  Copyright (c) 2015 PC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationHelper : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* userLocation;

+(LocationHelper *) instance;
- (instancetype)init;

- (void)initCurrentLocation;
- (void)stopLocationManager;

@end
