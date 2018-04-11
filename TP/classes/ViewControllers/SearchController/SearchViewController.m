//
//  SearchViewController.m
//  TP
//
//  Created by Bailang on 11/16/17.
//  Copyright © 2017 Bailang. All rights reserved.
//

#import "SearchViewController.h"
#import "PopInputView.h"
#import "TopicManager.h"
#import "FirebaseDBHelper.h"
#import "MapViewController.h"
#import "UIView+Toast.h"
#import "SearchInfoCell.h"
#import "Utils.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    NSMutableArray* topicList;
    float topOffset;
}

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    topicList = [[NSMutableArray alloc] init];
    
    self.searchBar.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableData) name:@"FetchedSearchTopicList" object:nil];
    
    [self updateTableData];
    
    [[TopicManager instance] fetchTopicList];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];

    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissKeyboard
{
    // add self
//    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [topicList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchInfoCell" forIndexPath:indexPath];
    
    Topic* topic = [topicList objectAtIndex:indexPath.row];
    
    cell.title.text = [Utils displayTitle:topic.title];
    cell.count.text = [NSString stringWithFormat:@"%ld", (long)topic.count];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Topic* topic = [topicList objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"SearchMapSegue" sender:topic];
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
    
    NSInteger cnt = [TopicManager instance].searchTopicList.count;
    if(cnt <= 7) {
        [topicList addObjectsFromArray: [TopicManager instance].searchTopicList];
    }
    else {
        for(int i = 0; i < 7; i++) {
            [topicList addObject:[[TopicManager instance].searchTopicList objectAtIndex:i]];
        }
    }
    
    [self.tableView reloadData];
}

-(void)updateSearchTableData: (NSArray*)resultArray {
    [topicList removeAllObjects];
    
    NSInteger cnt = resultArray.count;
    if(cnt <= 7) {
        [topicList addObjectsFromArray: resultArray];
    }
    else {
        for(int i = 0; i < 7; i++) {
            [topicList addObject:[resultArray objectAtIndex:i]];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Search Bar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText isEqualToString:@""]) {
        [self updateTableData];
    }
    else {
        searchText = [Utils validateTitle:searchText];
        NSArray* resultArray = [[TopicManager instance] fetchSearchArray:searchText];
        [self updateSearchTableData:resultArray];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"SearchMapSegue"]) {
        MapViewController * controller = (MapViewController *)[segue destinationViewController];
        controller.topic = (Topic *)sender;
    }
}

@end
