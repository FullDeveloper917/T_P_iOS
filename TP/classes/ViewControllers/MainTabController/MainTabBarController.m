//
//  MainTabBarController.m
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "MainTabBarController.h"
#import "UserInfo.h"
#import "LocationHelper.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [UserInfo instance].user_id = udid;
    NSLog(@"uuid: %@", udid);
    
    [[LocationHelper instance] initCurrentLocation];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
