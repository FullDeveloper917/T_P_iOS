//
//  RecentViewController.m
//  TP
//
//  Created by Bailang on 11/15/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "RecentViewController.h"
#import "PopInputView.h"
#import "TopicManager.h"
#import "FirebaseDBHelper.h"
#import "InfoCell.h"
#import "MapViewController.h"
#import "UIView+Toast.h"
#import "Utils.h"

@import FirebaseDatabase;

@interface RecentViewController () {
    NSMutableArray* topicList;
}

@end

@implementation RecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    topicList = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableData) name:@"FetchedRecentTopicList" object:nil];
    
    [self updateTableData];
    
    [[TopicManager instance] fetchTopicList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [topicList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    
    Topic* topic = [topicList objectAtIndex:indexPath.row];
    
    cell.title.text = [Utils displayTitle:topic.title];
    cell.count.text = [NSString stringWithFormat:@"%ld", (long)topic.count];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Topic* topic = [topicList objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"RecentMapSegue" sender:topic];
}

- (IBAction)OnClickBtnAdd:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Create a Topic"
                                                                              message: @"Input topic"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"topic";
//        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * txtTopic = textfields[0];
        NSString* title = txtTopic.text;
        NSLog(@"Topic: %@", title);
        
        if([title isEqualToString:@""]) {
            [self.navigationController.view makeToast:@"You must enter topic."];
        }
        else {
            title = [Utils validateTitle:title];
            [self addTitle:title];
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) addTitle:(NSString*)title {
    [[FirebaseDBHelper instance] checkTopic:title callback:^(int status) {
        if(status == 1) {
            [self.navigationController.view makeToast:@"Topic is exist already."];
            NSLog(@"Exist");
        }
        else {
            [self createTopic:title];
        }
    }];
}

- (void) createTopic:(NSString*)title {
    [[FirebaseDBHelper instance] createTopic:title callback:^(int status) {
        if(status == 1) {
            [self.navigationController.view makeToast:@"Success"];
        }
        else {
            [self.navigationController.view makeToast:@"Failed"];
        }
    }];
}

-(void)updateTableData {
    [topicList removeAllObjects];
    
    NSInteger cnt = [TopicManager instance].recentTopicList.count;
    if(cnt <= 7) {
        [topicList addObjectsFromArray: [TopicManager instance].recentTopicList];
    }
    else {
        for(int i = 0; i < 7; i++) {
            [topicList addObject:[[TopicManager instance].recentTopicList objectAtIndex:i]];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"RecentMapSegue"]) {
        MapViewController * controller = (MapViewController *)[segue destinationViewController];
        controller.topic = (Topic *)sender;
    }
}

@end
