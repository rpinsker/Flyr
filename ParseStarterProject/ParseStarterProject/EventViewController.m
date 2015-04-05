//
//  EventViewController.m
//  Flyr1
//
//  Created by Rachel Pinsker on 12/20/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import "EventViewController.h"
#import "EventDetailViewController.h"
#import "ShareViewController.h"
#import "EventTableViewCell.h"
#import "MoreViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

#define FONT_STRING @"AvenirNext-Medium"
#define FONT_CAPTION_STRING_SIZE 15
#define FONT_NAV_BAR_STRING_SIZE 45
#define WIDTH_EDGE_INSET 0
#define HEIGHT_EDGE_INSENT 23


@interface EventViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIScrollView *sv;
@property (nonatomic) NSInteger numEventsToShow;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *eventsToShow;

@end

@implementation EventViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    //set up navigation bar
    self.navigationItem.title = @"Event Feed";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:.05 alpha:1];
    self.navigationController.navigationBar.alpha = .8;
    self.navigationController.navigationBar.titleTextAttributes = @{FONT_STRING : NSFontAttributeName,
                                                                    NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                    };
    
    // set up settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"•••"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showSettings)];
    settingsButton.tintColor = [UIColor whiteColor];
    [settingsButton setTitleTextAttributes:@{FONT_STRING : NSFontAttributeName,
                                             NSForegroundColorAttributeName : [UIColor whiteColor],
                                             } forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = settingsButton;
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([[PFUser currentUser][@"setUpDone"] isEqual:@NO]) {
        NSLog(@"not done");
    }
    
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    
    //set up gesture recognizers
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(showDetailView:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    //    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(showShareView:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    //    [self.view addGestureRecognizer:swipeRight];
    
    
    //TODO: put in paging so that not all loads at once
    
    self.tableView = [[UITableView alloc] initWithFrame:mainScreenBounds];
    [self.tableView registerClass:[EventTableViewCell class]
           forCellReuseIdentifier:@"EventViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.pagingEnabled = YES;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.contentOffset = CGPointMake(0, self.navigationController.navigationBar.frame.size.height);
    
    [self.tableView addGestureRecognizer:swipeRight];
    [self.tableView addGestureRecognizer:swipeLeft];
    
    [self.view addSubview:self.tableView];
    
    /* TODO: PULL EVENTS IN THE RIGHT PLACE WITH THE RIGHT START TIME */
    NSDate *rightNow = [NSDate date];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    // TODO: add in right geopoint area
    [eventQuery whereKey:@"startTime" lessThanOrEqualTo:rightNow];
    [eventQuery whereKey:@"endTime" greaterThan:rightNow];
    eventQuery.limit = 4;
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu events.", (unsigned long)objects.count);
            self.numEventsToShow = objects.count;
            self.eventsToShow = objects;
            [self.tableView reloadData];
            if ([objects count] == 0) {
                self.tableView.hidden = YES;
            }
            else {
                self.tableView.hidden = NO;
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    /* USING SCROLL VIEW */
    //    /* initialize scrollView */
    //    self.sv = [[UIScrollView alloc] initWithFrame:mainScreenBounds];
    //    self.sv.backgroundColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
    //    self.sv.pagingEnabled = YES;
    //    self.sv.contentSize = CGSizeMake(mainScreenBounds.size.width, mainScreenBounds.size.height*numEventsToShow);
    //    self.sv.directionalLockEnabled = YES;
    //    [self.sv setContentOffset:CGPointMake(0, 20)];
    //    [self.view addSubview:self.sv];
    //
    //
    //    //eventually can be a for each loop that goes through the events pulled
    //    /*create cells to display each event */
    //    for (int i = 0; i < numEventsToShow; i++) {
    //        NSInteger widthEdgeInset = 0;
    //        NSInteger heightEdgeInset = 23;
    //        /* image view */
    //        UIImageView *i1 = [[UIImageView alloc] initWithFrame:CGRectMake(widthEdgeInset, mainScreenBounds.size.height*i+ heightEdgeInset, mainScreenBounds.size.width - (widthEdgeInset*2), mainScreenBounds.size.height - (heightEdgeInset*2))];
    //        i1.backgroundColor = [UIColor clearColor];
    //        i1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
    //        [self.sv addSubview:i1];
    //        /* end image view */
    //
    //        /* caption */
    //        int captionTextViewHeight = 200; // if you change this, change height of options table view height in shareViewController
    //        UITextView *captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(widthEdgeInset, i1.frame.origin.y + i1.frame.size.height - captionTextViewHeight, mainScreenBounds.size.width - (widthEdgeInset * 2), captionTextViewHeight)];
    //        captionTextView.backgroundColor = [UIColor colorWithWhite:.33
    //                                                            alpha:.7];
    //        captionTextView.opaque = NO;
    //
    //        // add text
    //        captionTextView.text = [NSString stringWithFormat:@"TITLE: %s\n\nTIME: %s\n\nLOCATION: %s","birthday party!", "11 - 2", "1414 E 59th Street, Chicago, IL 60637"];
    //
    //        //format text
    //        captionTextView.font = [UIFont fontWithName:FONT_STRING
    //                                               size:FONT_CAPTION_STRING_SIZE];
    //        captionTextView.textColor = [UIColor whiteColor];
    //        [self.sv addSubview:captionTextView];
    //        /* end caption */
    //    }
    
    //Refresh Control
    //add a refresh control to allow refreshing of data - no other time is the data refreshed
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@"Loading..."];
    [refreshString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [refreshString length])];
    [refreshString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Medium" size:13.0] range:NSMakeRange(0, [refreshString length])];
    refreshControl.attributedTitle = refreshString;
    
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
}

-(IBAction)handleRefresh:(id)sender
{
    //    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) { // only query if internet is reachable
    NSDate *rightNow = [NSDate date];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    // TODO: add in right geopoint area
    [eventQuery whereKey:@"startTime" lessThanOrEqualTo:rightNow];
    [eventQuery whereKey:@"endTime" greaterThan:rightNow];
    // NSMutableArray *followingUsers = [NSMutableArray array];
    //Create mutable array to add items for news feed
    NSMutableArray *eventItemsMut = [NSMutableArray array];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        [eventItemsMut addObjectsFromArray:items];
        if ([items count] == 0) {
            self.tableView.hidden = YES;
            //                    self.refreshButton.hidden = NO;
            //                    self.refreshButton.enabled = YES;
            //                    [self.refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
            //                    [self.refreshButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            self.tableView.hidden = NO;
            //                    self.refreshButton.hidden = YES;
            //                    self.refreshButton.enabled = NO;
        }
        self.eventsToShow = [NSArray arrayWithArray:eventItemsMut];
        [self.tableView reloadData];
        [(UIRefreshControl *)sender endRefreshing];
    }];
    //    }
    //    else { // if no internet, end the refresh control
    //        [(UIRefreshControl *)sender endRefreshing];
    //    }
}


#pragma mark - Table View
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventsToShow count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventViewCell"];
    cell.navBarHeight = self.navigationController.navigationBar.frame.size.height;
    //    cell.title = [NSString stringWithFormat:@"Event #%ld",(long)indexPath.row];
    //    cell.caption = [NSString stringWithFormat:@"TITLE: %s\n\nTIME: %s\n\nLOCATION: %s","birthday party!", "11 - 2", "1414 E 59th Street, Chicago, IL 60637"];
    //    cell.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",(long)indexPath.row]];
    PFObject *event = self.eventsToShow[indexPath.row];
    cell.title = event[@"eventName"];
    
    NSDateFormatter *dateFormatterForTime = [[NSDateFormatter alloc] init];
    dateFormatterForTime.timeStyle = NSDateFormatterShortStyle;
    dateFormatterForTime.dateStyle = NSDateFormatterNoStyle;
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatterForTime setLocale:usLocale];
    NSString *startTime = [dateFormatterForTime stringFromDate:event[@"startTime"]];
    NSString *endTime = [dateFormatterForTime stringFromDate:event[@"endTime"]];
    
    cell.caption = [NSString stringWithFormat:@"TIME: %@ - %@\n\nLOCATION: %@",startTime,endTime,event[@"stringLocation"]];
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIScreen mainScreen].bounds.size.height;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%lu",indexPath.row);
    if (indexPath.row == [self.eventsToShow count] -2) {
        [self loadMoreData];
    }
}
-(void)loadMoreData
{
    //    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) { // only query if internet is reachable
    NSDate *rightNow = [NSDate date];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    // TODO: add in right geopoint area
    // TODO: order by distance
    [eventQuery whereKey:@"startTime" lessThanOrEqualTo:rightNow];
    [eventQuery whereKey:@"endTime" greaterThan:rightNow];
    eventQuery.skip = [self.eventsToShow count];
    eventQuery.limit = 5;
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        if (!error) {
            NSInteger lastSection = [self.eventsToShow count];
            self.eventsToShow = [self.eventsToShow arrayByAddingObjectsFromArray:items];
            
            //for each item in items prepare item for insertion
            NSInteger counter = [items count];
            NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
            [indexSet addIndexesInRange:NSMakeRange(lastSection, counter)];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
        }
        
    }];
    //    }
    
}


#pragma mark - Navigation

- (void) showDetailView: (UISwipeGestureRecognizer *) gestureRecognizer
{
    //Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    //Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    PFObject *eventSwiped;
    
    //Check if index path is valid
    if(indexPath)
    {
        //Get the cell out of the table view
        //EventTableViewCell *cell = (EventTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        eventSwiped = self.eventsToShow[indexPath.row];
        EventDetailViewController *detailVC = [[EventDetailViewController alloc] init];
        detailVC.detailString = eventSwiped[@"eventDescription"];
        detailVC.addressString = eventSwiped[@"stringLocation"];
        [self.navigationController pushViewController:detailVC
                                             animated:YES];
    }
    
    
}

- (void) showShareView: (UISwipeGestureRecognizer *) gestureRecognizer
{
    //Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    //Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    //Check if index path is valid
    if(indexPath)
    {
        PFObject *event = self.eventsToShow[indexPath.row];
        
        [self.navigationController popViewControllerAnimated:YES];
        ShareViewController *shareVC = [self.navigationController.viewControllers objectAtIndex:0];
        shareVC.eventVC = self;
        shareVC.event = event;
    }
}

- (void) showSettings
{
    MoreViewController *settingsVC = [[MoreViewController alloc] init];
    [self.navigationController pushViewController:settingsVC
                                         animated:NO];
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
