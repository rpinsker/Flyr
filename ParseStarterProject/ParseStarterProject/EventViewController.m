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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "ErrorHandlingController.h"

#define FONT_STRING @"AvenirNext-Medium"
#define FONT_CAPTION_STRING_SIZE 25
#define FONT_NAV_BAR_STRING_SIZE 45
#define WIDTH_EDGE_INSET 0
#define HEIGHT_EDGE_INSENT 23


@interface EventViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UIScrollView *sv;
@property (nonatomic) NSInteger numEventsToShow;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *eventsToShow;
@property (nonatomic, strong) UIAlertView *locationAlertView;
@property (nonatomic, strong) UIAlertView *zipcodeAlertView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIImage *eventImage;
@property (nonatomic, strong) NSDate *lastPullOfEvents;

@end

@implementation EventViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.lastPullOfEvents) {
        self.lastPullOfEvents = [NSDate dateWithTimeIntervalSinceNow:-60];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    //set up navigation bar
    self.navigationItem.title = @"Event Feed";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.89 green:.39 blue:.39 alpha:.8];
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
    
    if (!self.eventsToShow) {
        if ([[PFUser currentUser][@"setUpDone"] isEqual:@YES]) {
            //[self pullEvents];
            if (!self.locationManager) {
                self.locationManager = [[CLLocationManager alloc] init];
                self.locationManager.delegate = self;
            }
            //        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
            //        [self.locationManager requestWhenInUseAuthorization];
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    if (!error) {
                        [PFUser currentUser][@"location"] = geoPoint;
                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded)
                                [self pullEvents];
                            if (error)
                                [ErrorHandlingController handleParseError:error];
                        }];
                    }
                    else if ([PFUser currentUser][@"location"]) {
                        [self pullEvents];
                    }
                }];
            }
        }
    }
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    /* hard code a bunch of events 
    for (int i = 0; i < 25; i++) {
        PFObject *newEvent = [PFObject objectWithClassName:@"Event"];
        newEvent[@"eventName"] = [NSString stringWithFormat:@"event %d",i];
        newEvent[@"startTime"] = [NSDate dateWithTimeIntervalSinceNow:-3600];
        newEvent[@"endTime"] = [NSDate dateWithTimeIntervalSinceNow:3600 * 7 + 60*i];
        newEvent[@"stringLocation"] = @"1003 E 61st Street Chicago, IL 60637";
       // newEvent[@"eventDescription"] = @"descriptiondescription descriptiondescription descriptiondescription\ndescriptiondescription descriptiondescription descriptiondescription\ndescriptiondescription descriptiondescription descriptiondescription\ndescriptiondescription descriptiondescription descriptiondescription\ndescriptiondescription descriptiondescription descriptiondescription\ndescriptiondescription descriptiondescription descriptiondescription\ndescriptiondescription descriptiondescription descriptiondescription\ndescriptiondescription descriptiondescription descriptiondescription\n";
        
        [newEvent saveInBackground];
        
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:@"1003 E 61st Street Chicago, IL 60637" completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks) {
                CLPlacemark *placemark = placemarks[0];
                PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLocation:placemark.location];
                newEvent[@"location"] = geopoint;
                [newEvent saveInBackground];
            }
        }];
    }
    
    /* end hard coding events */

    
    
    
    if ([[PFUser currentUser][@"setUpDone"] isEqual:@NO]) {
        [self setUpUser];
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
    
//    if ([[PFUser currentUser][@"setUpDone"] isEqual:@YES]) {
//        //[self pullEvents];
//        if (!self.locationManager) {
//            self.locationManager = [[CLLocationManager alloc] init];
//            self.locationManager.delegate = self;
//        }
////        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
////        [self.locationManager requestWhenInUseAuthorization];
//        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
//            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//                if (!error) {
//                    [PFUser currentUser][@"location"] = geoPoint;
//                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                        if (succeeded)
//                            [self pullEvents];
//                        if (error)
//                            [ErrorHandlingController handleParseError:error];
//                    }];
//                }
//            }];
//        }
//    }
    
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

- (void) pullEvents
{
    self.lastPullOfEvents = [NSDate date];
    /* TODO: PULL EVENTS IN THE RIGHT PLACE WITH THE RIGHT START TIME */
    NSDate *rightNow = [NSDate date];
    PFGeoPoint *usersLocation = [PFUser currentUser][@"location"];
    NSNumber *usersRadius = [PFUser currentUser][@"radius"];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"startTime" lessThanOrEqualTo:rightNow];
    [eventQuery whereKey:@"endTime" greaterThan:rightNow];
    [eventQuery whereKey:@"location" nearGeoPoint:usersLocation withinMiles:[usersRadius doubleValue]];
    [eventQuery orderByAscending:@"endTime"];
    eventQuery.limit = 5;
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu events.", (unsigned long)objects.count);
            NSMutableArray *objectsMutable = [objects mutableCopy];
            for (PFObject *object in objects) {
                NSString *FBUserID = object[@"FBUserID"];
                if (![FBUserID isEqualToString:@"0"]) // private event
                {
                    if (![[FBSDKAccessToken currentAccessToken].userID isEqualToString:FBUserID]) { // can't show this event
                        [objectsMutable removeObject:object];
                    }
                }
            }
            objects = [objectsMutable copy];
            self.numEventsToShow = objects.count;
            self.eventsToShow = objects;
            [self.tableView reloadData];
            if ([objects count] == 0) {
                //self.tableView.hidden = YES;
            }
            else {
                self.tableView.hidden = NO;
            }
            self.lastPullOfEvents = [NSDate date];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [ErrorHandlingController handleParseError:error];
        }
    }];
}

# pragma mark - alert view for location

- (void) setUpUser
{
    self.locationAlertView = [[UIAlertView alloc] initWithTitle:@"location" message:@"Would you like to allow Flyr to use your current location to find events near you? You can also enter a zip code to see events in the area." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    self.locationAlertView.delegate = self;
    [self.locationAlertView show];
}



- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.locationAlertView]) { // just asked if they want to allow access to location or enter zip code
        if (buttonIndex == 0) { // user wants to enter a zip code
            if (!self.zipcodeAlertView) {
                self.zipcodeAlertView = [[UIAlertView alloc] initWithTitle:@"zipcode" message:@"enter zip code or hit cancel to have Flyr use your actual location" delegate:self cancelButtonTitle:@"use my location" otherButtonTitles:@"enter", nil];
                self.zipcodeAlertView.delegate = self;
                self.zipcodeAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [self.zipcodeAlertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
            }
            [self.zipcodeAlertView show];
        }
        else { // ask for permission for current location
            [self getCurrentLocation];
        }
    }
    else if ([alertView isEqual:self.zipcodeAlertView]) {
        if (buttonIndex == 0) { // ask for permission for current location
            [self getCurrentLocation];
        }
        else if ([[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
            [self.zipcodeAlertView show];
        }
        else { // use the zip code
            NSString *zipcodeString = [alertView textFieldAtIndex:0].text;
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:zipcodeString completionHandler:^(NSArray* placemarks, NSError* error){
                if (placemarks) { // found a place
                    CLPlacemark *placemark = placemarks[0];
                    PFGeoPoint *userLocation = [PFGeoPoint geoPointWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude]; // create the geopoint through parse
                    [PFUser currentUser][@"location"] = userLocation;
                    [PFUser currentUser][@"setUpDone"] = @YES;
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded)
                            [self pullEvents];
                    }];
                    // TODO: another alert view to confirm the right place?
                }
                // TODO: handle if nothing found
            }];
        }
    }
    
}

# pragma mark - location

- (void) getCurrentLocation
{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        [self.locationManager requestWhenInUseAuthorization];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                [PFUser currentUser][@"location"] = geoPoint;
                [PFUser currentUser][@"setUpDone"] = @YES;
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                        [self pullEvents];
                    if (error)
                        [ErrorHandlingController handleParseError:error];
                }];
            }
        }];
    }
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                [PFUser currentUser][@"location"] = geoPoint;
                [PFUser currentUser][@"setUpDone"] = @YES;
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [self pullEvents];
                    }
                }];
            }
        }];
    }
    // TODO: make user enter a zipcode if they take away authorization
}

-(IBAction)handleRefresh:(id)sender
{
    //    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) { // only query if internet is reachable
    NSDate *rightNow = [NSDate date];
    PFGeoPoint *usersLocation = [PFUser currentUser][@"location"];
    NSNumber *usersRadius = [PFUser currentUser][@"radius"];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    eventQuery.limit = 4;
    [eventQuery whereKey:@"startTime" lessThanOrEqualTo:rightNow];
    [eventQuery whereKey:@"endTime" greaterThan:rightNow];
    [eventQuery whereKey:@"startTime" greaterThan:self.lastPullOfEvents];
    [eventQuery whereKey:@"location" nearGeoPoint:usersLocation withinMiles:[usersRadius doubleValue]];
    [eventQuery orderByAscending:@"endTime"];
    NSMutableArray *eventItemsMut = [NSMutableArray array];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        NSMutableArray *objectsMutable = [items mutableCopy];
        for (PFObject *object in items) {
            NSString *FBUserID = object[@"FBUserID"];
            if (![FBUserID isEqualToString:@"0"]) // private event
            {
                if (![[FBSDKAccessToken currentAccessToken].userID isEqualToString:FBUserID]) { // can't show this event
                    [objectsMutable removeObject:object];
                }
            }
        }
        items = [objectsMutable copy];
        [eventItemsMut addObjectsFromArray:items];
        [(UIRefreshControl *)sender endRefreshing];
        self.lastPullOfEvents = [NSDate date];
        if ([items count] == 0) {
            //self.tableView.hidden = YES;
            //                    self.refreshButton.hidden = NO;
            //                    self.refreshButton.enabled = YES;
            //                    [self.refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
            //                    [self.refreshButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            self.tableView.hidden = NO;
            [eventItemsMut addObjectsFromArray:self.eventsToShow];
            self.eventsToShow = [NSArray arrayWithArray:eventItemsMut];
            [self.tableView reloadData];
            //                    self.refreshButton.hidden = YES;
            //                    self.refreshButton.enabled = NO;
        }
        
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
    
    
    PFFile *imageFile = event[@"image"];
    if (imageFile) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            UIImage *image = [UIImage imageWithData:imageData];
            cell.image = image;
        }];
    }
    else {
        cell.image = nil;
    }
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIScreen mainScreen].bounds.size.height;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%lu",indexPath.row);
    if (indexPath.row == [self.eventsToShow count] - 2) {
        [self loadMoreData];
    }
}
-(void)loadMoreData
{
    //    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) { // only query if internet is reachable
    NSDate *rightNow = [NSDate date];
    PFGeoPoint *usersLocation = [PFUser currentUser][@"location"];
    NSNumber *usersRadius = [PFUser currentUser][@"radius"];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    // TODO: order by distance
    [eventQuery whereKey:@"startTime" lessThanOrEqualTo:rightNow];
    [eventQuery whereKey:@"endTime" greaterThan:rightNow];
    [eventQuery whereKey:@"location" nearGeoPoint:usersLocation withinMiles:[usersRadius doubleValue]];
    eventQuery.skip = [self.eventsToShow count];
    eventQuery.limit = 5;
    [eventQuery orderByAscending:@"endTime"];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        if (!error) {
            self.lastPullOfEvents = [NSDate date];
            if ([items count] != 0) {
                NSMutableArray *objectsMutable = [items mutableCopy];
                for (PFObject *object in items) {
                    NSString *FBUserID = object[@"FBUserID"];
                    if (![FBUserID isEqualToString:@"0"]) // private event
                    {
                        if (![[FBSDKAccessToken currentAccessToken].userID isEqualToString:FBUserID]) { // can't show this event
                            [objectsMutable removeObject:object];
                        }
                    }
                }
                items = [objectsMutable copy];
                
                NSMutableArray *itemsToAddToEventsToShow = [[NSMutableArray alloc] initWithArray:items];
                NSInteger lastSection = [self.eventsToShow count];
                for (PFObject *item in items) { // add the new items
                    if ([self.eventsToShow containsObject:item]) { // if it's already shown, remove it
                        [itemsToAddToEventsToShow removeObject:item];
                    }
                }
                self.eventsToShow = [self.eventsToShow arrayByAddingObjectsFromArray:itemsToAddToEventsToShow];
                
                //for each item in items prepare item for insertion
                NSInteger counter = [itemsToAddToEventsToShow count];
                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                //            NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
                for (NSInteger i = lastSection; i < counter + lastSection; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [indexPaths addObject:indexPath];
                }
                
                //            [indexSet addIndexesInRange:NSMakeRange(lastSection, counter)];
                [self.tableView insertRowsAtIndexPaths:indexPaths  withRowAnimation:UITableViewRowAnimationTop];
                //            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
            }
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
        detailVC.location = eventSwiped[@"location"];
        
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
        UITableViewCell *cellSwiped = [self.tableView cellForRowAtIndexPath:indexPath];
        shareVC.eventImage = cellSwiped.image;
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
