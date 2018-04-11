//
//  MapViewController.m
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MapViewController.h"
#import "LocationHelper.h"
#import "UserInfo.h"
#import "FirebaseDBHelper.h"
#import "UIView+Toast.h"
#import "Marker.h"
#import "Utils.h"
#import "DateUtils.h"

@import GoogleMaps;
@import GooglePlaces;
@import FirebaseDynamicLinks;

static NSString *const DYNAMIC_LINK_DOMAIN = @"z8abe.app.goo.gl";

static NSInteger const NumberParams = 24;

static NSString *const BundleID = @"com.bailang.tp";
static NSString *const CustomScheme = @"tp_app";
static NSString *const AppStoreID = @"";

static NSString *const PackageName = @"com.property.david.tp";

@interface MapViewController () <MFMessageComposeViewControllerDelegate> {
    UILabel *titleLabel;
    UILabel *subTitleLabel;
    
    NSMutableArray* markerList;
    NSMutableArray* gMarkerList;
}

@property(nonatomic, strong) NSMutableDictionary<NSString *, UITextField *> *dictionary;
@property(nonatomic, strong) NSURL *longLink;

@end

@implementation MapViewController {
    GMSMapView* mapView;
    GMSPlacesClient *_placesClient;
    NSTimer* timer;
    BOOL isClicked;
    BOOL isShowed;
    int cnt;
    int cnt_show;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isClicked = NO;
    isShowed = NO;
    cnt = 0;
    
    self.navigationItem.titleView = [self setTitle: [Utils displayTitle:self.topic.title] subTitle:[NSString stringWithFormat:@"%ld", (long)self.topic.count]];
    
    _placesClient = [GMSPlacesClient sharedClient];
    
    self.dictionary = [[NSMutableDictionary alloc] initWithCapacity:NumberParams];
    
    CLLocation* userLocation = [LocationHelper instance].userLocation;
    
    if (userLocation) {
        [[LocationHelper instance] stopLocationManager];
    }
    
    double latitude = userLocation.coordinate.latitude;
    double longitude = userLocation.coordinate.longitude;
    
    [UserInfo instance].latitude = latitude;
    [UserInfo instance].longitude = longitude;
    
    NSLog(@"latitude: %f, longitude: %f", latitude, longitude);
    
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:10.0];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [mapView setMinZoom:1 maxZoom:14];
    self.view = mapView;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    
    CGFloat btnWidth = screenWidth / 4;
    CGFloat btnOrgX = (screenWidth - btnWidth) / 2;
    CGFloat btnOrgY = screenHeight - btnWidth - tabBarHeight - 30;
    CGRect btnFrame = CGRectMake(btnOrgX, btnOrgY, btnWidth, btnWidth);
    
    self.btnAddMarker = [[UIButton alloc] initWithFrame:btnFrame];
    UIImage *btnImage = [UIImage imageNamed:@"btn_add"];
    [self.btnAddMarker setImage:btnImage forState:UIControlStateNormal];
    
    [self.btnAddMarker addTarget:self action:@selector(touchStarted:) forControlEvents:UIControlEventTouchDown];
    [self.btnAddMarker addTarget:self action:@selector(touchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAddMarker addTarget:self action:@selector(touchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.view addSubview: self.btnAddMarker];
    
    CGFloat imgWidth = screenWidth / 1.5;
    CGFloat imgOrgX = (screenWidth - imgWidth) / 2;
    CGFloat imgOrgY = (screenHeight - imgWidth) / 3;
    self.imgSuccessView = [[UIImageView alloc] initWithFrame:CGRectMake(imgOrgX, imgOrgY, imgWidth, imgWidth)];
    UIImage* imgSuccess = [UIImage imageNamed:@"img_success"];
    [self.imgSuccessView setImage:imgSuccess];
    [self.view addSubview: self.imgSuccessView];
    self.imgSuccessView.hidden = YES;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update_dt) userInfo:nil repeats:YES];
    
    markerList = [[NSMutableArray alloc] init];
    gMarkerList = [[NSMutableArray alloc] init];
    
    [self getMarkerList];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocationHelper instance] initCurrentLocation];
}

- (void)setTitle:(NSString*)title count:(NSInteger)count {
    titleLabel.text = title;
    subTitleLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
}

- (void)touchStarted:(id)sender {
    isClicked = YES;
    NSLog(@"Touch started");
}

- (void)touchEnded:(id)sender {
    isClicked = NO;
    NSLog(@"Touch ended");
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press {
    NSLog(@"Nomal Press");
    return NO;
}

-(UIView*)setTitle:(NSString *)title subTitle:(NSString*)subTitle {
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    
    subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = [UIColor blackColor];
    subTitleLabel.font = [UIFont systemFontOfSize:14];
    subTitleLabel.text = subTitle;
    [subTitleLabel sizeToFit];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subTitleLabel.frame.size.width, titleLabel.frame.size.width), 40)];
    [titleView addSubview:titleLabel];
    [titleView addSubview:subTitleLabel];
    
    float widthDiff = subTitleLabel.frame.size.width - titleLabel.frame.size.width;
    
    if (widthDiff > 0) {
        CGRect frame = titleLabel.frame;
        frame.origin.x = widthDiff / 2;
        titleLabel.frame = CGRectIntegral(frame);
    }else{
        CGRect frame = subTitleLabel.frame;
        frame.origin.x = fabsf(widthDiff) / 2;
        subTitleLabel.frame = CGRectIntegral(frame);
    }

    return titleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addMarker {
    CLLocation* userLocation = [LocationHelper instance].userLocation;
    double latitude = userLocation.coordinate.latitude;
    double longitude = userLocation.coordinate.longitude;
    
    [self getMarkerWithLatitude:latitude longitude:longitude rate:1.0];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude, longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.icon = [UIImage imageNamed:@"ic_circle"];
    marker.map = mapView;
    
    [[FirebaseDBHelper instance] addMarker:_topic.title callback:^(int status) {
        if(status == 1) {
            self.imgSuccessView.hidden = NO;
            isShowed = YES;
            
            [self updateMarkersNum];
        }
        else {
            [self.navigationController.view makeToast:@"Failed."];
        }
    }];
}

- (void)updateMarkersNum {
    [[FirebaseDBHelper instance] fetchMarkersNum:self.topic.title callback:^(NSInteger marker_num) {
        subTitleLabel.text = [NSString stringWithFormat:@"%ld", marker_num];
    }];
}

- (void)getMarkerList {
    [[FirebaseDBHelper instance] fetchMarkers:self.topic.title callback:^(NSArray *markers) {
        [markerList removeAllObjects];
        [markerList addObjectsFromArray:markers];
        
        [self updateMarkers];
    }];
}

- (GMSMarker*) getMarkerWithLatitude:(double)latitude longitude:(double)longitude rate:(double)rate{
    if(rate < 0.3) rate = 0.3;
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude, longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    CGRect frame = CGRectMake(0, 0, 60 * rate, 60 * rate);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:@"ic_circle"];
    imageView.alpha = rate;
    marker.iconView = imageView;
    
    marker.map = mapView;
    
    return marker;
}

- (void)updateMarkers {
    [self removeMarkers];
    
    for(int i = 0; i < markerList.count; i++) {
        Marker* marker = [markerList objectAtIndex:i];
        NSArray *location = [marker.location componentsSeparatedByString:@","];
        double latitude = [location[0] doubleValue];
        double longitude = [location[1] doubleValue];
        
        double mkDate = [marker.date doubleValue];
        double curDate = [[DateUtils getDate] doubleValue];
        double h24 = 24 * 60 * 60;
        double dis = curDate - mkDate;
        double rate = 1 - dis / h24;
        
        GMSMarker* gmsMarker = [self getMarkerWithLatitude:latitude longitude:longitude rate:rate];
        [gMarkerList addObject:gmsMarker];
    }
}

- (void)removeMarkers {
    for(int i = 0; i < gMarkerList.count; i++) {
        GMSMarker* marker = [gMarkerList objectAtIndex:i];
        marker.map = nil;
    }
    
    [gMarkerList removeAllObjects];
}

- (NSURL*)buildFDLLink:(NSString*)link {
//    link = [Utils displayTitle:link];
    link = [link stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString* res_str = [link stringByRemovingPercentEncoding];
    NSURL *link_url = [NSURL URLWithString:link];
    FIRDynamicLinkComponents *components = [FIRDynamicLinkComponents componentsWithLink:link_url domain:DYNAMIC_LINK_DOMAIN];
    
    // iOS params
    FIRDynamicLinkIOSParameters *iOSParams = [FIRDynamicLinkIOSParameters parametersWithBundleID:BundleID];
    iOSParams.customScheme = CustomScheme;
    components.iOSParameters = iOSParams;

    FIRDynamicLinkAndroidParameters *androidParams = [FIRDynamicLinkAndroidParameters parametersWithPackageName:PackageName];
    components.androidParameters = androidParams;
    
    NSURL* url = components.url;
    
    NSLog(@"Title: %@", res_str);
    NSLog(@"URL: %@", url.absoluteString);
    
    return components.url;
}

- (IBAction)onClickBtnShare:(id)sender {
    self.longLink = [self buildFDLLink:self.topic.title];

    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }

    NSArray *recipents = @[@""];

    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
//    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:self.longLink.absoluteString];

    // Present message view controller on screen
    if ( messageController )
    {
        [self.navigationController presentViewController:messageController animated:YES completion:nil];
    }
    else
    {
        // Gracefully handle the error
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSLog(@"Some result received: %ld", (long)result);
    //[controller dismissViewControllerAnimated:YEScompletion:nil];
}

- (void)update_dt{
    if(isClicked) {
        cnt++;
        
        if(cnt == 2) {
            isClicked = NO;
            
            [self addMarker];
            
            NSLog(@"Long press");
        }
    }
    else {
        cnt = 0;
    }
    
    if(isShowed) {
        isShowed = NO;
    }
    else {
        self.imgSuccessView.hidden = YES;
    }
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
