//
//  MapViewController.h
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic.h"

@interface MapViewController : UIViewController

@property (strong, nonatomic) Topic * topic;

@property (strong, nonatomic) UIButton* btnAddMarker;
@property (strong, nonatomic) UIImageView* imgSuccessView;

-(UIView*)setTitle:(NSString *)title subTitle:(NSString*)subTitle;

@end
