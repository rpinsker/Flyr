//
//  EventDetailViewController.m
//  Flyr1
//
//  Created by Rachel Pinsker on 12/20/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import "EventDetailViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>


#define FONT_STRING @"AvenirNext-Medium"
#define FONT_CAPTION_STRING_SIZE 15
#define BUTTON_HEIGHT 60
#define GO_OR_NO_BUTTON_STRING_SIZE 23
static const NSString *uberServerToken = @"kJAVhzlqrGPdgQn4V1TJ1BfWVlx0Q1oiEQkZ2n5E";
static const NSString *uberClientID = @"F501X0Phg7ifm_9PmBo3orD5kX806ZSd";


@interface EventDetailViewController ()

@property (nonatomic, strong) UIButton *GoButton;
@property (nonatomic, strong) UIButton *NoButton;
@property (nonatomic) double startLocationLatitude;
@property (nonatomic) double startLocationLongitude;
@property (nonatomic, strong) CLPlacemark *endPlacemark;
@property (nonatomic, strong) NSString *uberProductID;

@end


@implementation EventDetailViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    
    //set up gesture recognizer
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(back)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    //set up mapView
    MKMapView *map = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,mainScreenBounds.size.width, mainScreenBounds.size.height)];
    map.zoomEnabled = YES;
    map.scrollEnabled = NO;
    
    
    // get location of event
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks) {
            CLPlacemark *placemark = placemarks[0];
            self.endPlacemark = placemark;
            MKPlacemark *mkplacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
            [map addAnnotation:mkplacemark];
            
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) { // show their location on the map
                map.showsUserLocation = YES;
                CLLocationManager *manager = [[CLLocationManager alloc] init];
                CLLocation *loc = [manager location];
                
                NSLog(@"lat: %f",(double)mkplacemark.coordinate.latitude);
                NSLog(@"lat: %f",(double)loc.coordinate.latitude);
                double deltaX = fabs((double)mkplacemark.coordinate.latitude - (double)loc.coordinate.latitude);
                double deltaY = fabs((double)mkplacemark.coordinate.longitude - (double)loc.coordinate.longitude);
                
                MKCoordinateSpan span = MKCoordinateSpanMake(2.7*deltaX, 2.7*deltaY);
                double latCenter = MAX((double)mkplacemark.coordinate.latitude,(double)loc.coordinate.latitude) - (fabs((double)mkplacemark.coordinate.latitude - (double)loc.coordinate.latitude))/2.0;
                double longCenter = MAX((double)mkplacemark.coordinate.longitude,(double)loc.coordinate.longitude) - (fabs((double)mkplacemark.coordinate.longitude - (double)loc.coordinate.longitude) / 2.0);
                CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(latCenter, longCenter);
               // map.region = MKCoordinateRegionMake(mkplacemark.coordinate, span);
                map.region = MKCoordinateRegionMake(centerCoord, span);
            }
            else {
                MKCoordinateRegion region;
                region.center = mkplacemark.coordinate;
                region.span = MKCoordinateSpanMake(.005, .005);
                map.region = region;
            }
            
        }
    }];
    
    // get current location
    PFGeoPoint *location = [PFUser currentUser][@"location"];
    self.startLocationLatitude = location.latitude;
    self.startLocationLongitude = location.longitude;
    
    
    [self.view addSubview:map];
    
    //set up text view
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, mainScreenBounds.size.height/2, mainScreenBounds.size.width, mainScreenBounds.size.height/2 - BUTTON_HEIGHT)];
    detailTextView.backgroundColor = [UIColor colorWithWhite:.33
                                                       alpha:1];
    detailTextView.opaque = YES;
    
    // add text
    detailTextView.text = self.detailString;
    
    //format text
    detailTextView.font = [UIFont fontWithName:FONT_STRING
                                          size:FONT_CAPTION_STRING_SIZE];
    detailTextView.textColor = [UIColor whiteColor];
    detailTextView.editable = NO;
    
    // make buttons
    self.GoButton = [[UIButton alloc] initWithFrame:CGRectMake(0,mainScreenBounds.size.height - BUTTON_HEIGHT, mainScreenBounds.size.width/2, BUTTON_HEIGHT)];
    [self.GoButton addTarget:self
                      action:@selector(takeMeTherePressed)
            forControlEvents:UIControlEventTouchUpInside];
    self.GoButton.backgroundColor = [UIColor colorWithRed:0
                                                    green:.5
                                                     blue:0
                                                    alpha:1];
    [self.GoButton setTitle:@"Take me there"
                   forState:UIControlStateNormal];
    self.GoButton.titleLabel.font = [UIFont fontWithName:FONT_STRING
                                                    size:GO_OR_NO_BUTTON_STRING_SIZE];
    self.GoButton.titleLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:self.GoButton];
    
    
    self.NoButton = [[UIButton alloc] initWithFrame:CGRectMake(mainScreenBounds.size.width/2, mainScreenBounds.size.height - BUTTON_HEIGHT, mainScreenBounds.size.width/2, BUTTON_HEIGHT)];
    [self.NoButton addTarget:self
                      action:@selector(back)
            forControlEvents:UIControlEventTouchUpInside];
    self.NoButton.backgroundColor = [UIColor colorWithRed:.5
                                                    green:0
                                                     blue:0
                                                    alpha:1];
    
    [self.NoButton setTitle:@"Not feeling it"
                   forState:UIControlStateNormal];
    self.NoButton.titleLabel.font = [UIFont fontWithName:FONT_STRING
                                                    size:GO_OR_NO_BUTTON_STRING_SIZE];
    self.NoButton.titleLabel.textColor = [UIColor whiteColor];
    
    
    [self.view addSubview:self.NoButton];
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) takeMeTherePressed
{
    // TODO: (possibly) alertactions only work on ios 8 and later. if going to be running on earlier ios, make it use an action sheet instead
    UIAlertController *goOptionsAlertController = [UIAlertController alertControllerWithTitle:@"Transportation Options" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // make and add cancel action
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {} ];
    [goOptionsAlertController addAction:cancelAction];
    
    // TODO: check on a phone that doesn't have uber and a phone that doesn't have google maps and a phone that doesn't have either
    
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) { // phone has google maps app
        // google maps action - make and add to controller
        UIAlertAction* googleMapsAction = [UIAlertAction actionWithTitle:@"Google Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self openGoogleMaps]; }];
        [goOptionsAlertController addAction:googleMapsAction];
        
        // apple maps action - make and add to controller
        UIAlertAction* appleMapsAction = [UIAlertAction actionWithTitle:@"Apple Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self openMap]; }];
        [goOptionsAlertController addAction:appleMapsAction];
        
    }
    else { // phone doesn't have google maps app, only option is regular apple maps
        // regular maps action - make and add to controller
        UIAlertAction* appleMapsAction = [UIAlertAction actionWithTitle:@"Map it" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self openMap]; }];
        [goOptionsAlertController addAction:appleMapsAction];
    }
    
    
    // get uber cost estimate
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"uber://"]]) {
        if (self.startLocationLongitude && self.startLocationLatitude && self.endPlacemark) {
            NSString *uberURL = [NSString stringWithFormat:@"https://api.uber.com/v1/estimates/price?server_token=%@&start_latitude=%f&start_longitude=%f&end_latitude=%f&end_longitude=%f", uberServerToken, self.startLocationLatitude, self.startLocationLongitude, self.endPlacemark.location.coordinate.latitude, self.endPlacemark.location.coordinate.longitude];
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            
            [[session dataTaskWithURL:[NSURL URLWithString:uberURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
              {
                  if (!error) {
                      NSLog(@"%@",response);
                      
                      NSError *jsonError;
                      NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                      if (!jsonError) {
                          UIAlertAction* uberAction;
                          NSArray *pricesArray = resultsDict[@"prices"];
                          NSLog(@"%@",pricesArray);
                          for (NSDictionary *dict in pricesArray) {
                              NSString *displayName = dict[@"display_name"];
                              if ([displayName isEqualToString:@"uberX"]) { // display this info
                                  if (!uberAction) {
                                      self.uberProductID = dict[@"product_id"];
                                      NSString *priceEstimate = dict[@"estimate"];
                                      NSString *durationEstimateStr = dict[@"duration"]; // time in seconds as a string
                                      int durationEstimate = [durationEstimateStr intValue];
                                      if (durationEstimate) {
                                          durationEstimate = durationEstimate / 60; // convert to minutes
                                      }
                                      NSString *actionTitle = [NSString stringWithFormat:@"Uber -- ~%d min, %@ (uberX)",durationEstimate, priceEstimate];
                                      uberAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self openUber]; }];
                                  }
                                  break;
                              }
                          }
                          if (!uberAction) { // couldn't find uberX, just take the first estimate
                              if (pricesArray) {
                                  NSDictionary *dict = pricesArray[0];
                                  self.uberProductID = dict[@"product_id"];
                                  int durationEstimate = dict[@"duration"]; // time in seconds
                                  if (durationEstimate) {
                                      durationEstimate = durationEstimate / 60; // convert to minutes
                                  }
                                  NSString *priceEstimate;
                                  if ([dict objectForKey:@"estimate"]) {
                                      priceEstimate = dict[@"estimate"];
                                  }
                                  NSString *actionTitle = [NSString stringWithFormat:@"Uber -- estimated %d min, %@ (%@)",durationEstimate, priceEstimate,dict[@"display_name"]];
                                  uberAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self openUber]; }];
                                  
                              }
                          }
                          if (uberAction) {
                              [goOptionsAlertController addAction:uberAction];
                              [self presentViewController:goOptionsAlertController animated:YES completion:NULL];
                          }
                      }
                  }
                  
              }] resume];
        }
        else { // problems getting uber information
            UIAlertAction *uberAction = [UIAlertAction actionWithTitle:@"Uber" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self openUber]; }];
            [goOptionsAlertController addAction:uberAction];
            [self presentViewController:goOptionsAlertController animated:YES completion:NULL];
        }
    }
    else { // no uber
        [self presentViewController:goOptionsAlertController animated:YES completion:NULL];
    }
    
}

- (void) openMap
{
    self.GoButton.enabled = NO;
    // TODO: change this to show the actual address from the above geocoder (make mkplacemark not a local var). Be careful with threading though--here, must make sure mkplacemark has been initialized, and if it hasn't been, disable takeMeThereButton and
    //    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //    [geocoder geocodeAddressString:self.addressString completionHandler:^(NSArray *placemarks, NSError *error) {
    //        self.GoButton.enabled = YES;
    //        if (placemarks) {
    //            CLPlacemark *placemark = placemarks[0];
    //            MKPlacemark *mkplacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
    //
    //            NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
    //
    //            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:mkplacemark];
    //            [MKMapItem openMapsWithItems: @[toLocation]
    //                           launchOptions:options];
    //        }
    //    }];
    
    if (self.endPlacemark) {
        MKPlacemark *mkplacemark = [[MKPlacemark alloc] initWithPlacemark:self.endPlacemark];
        NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:mkplacemark];
        [MKMapItem openMapsWithItems: @[toLocation]
                       launchOptions:options];
        self.GoButton.enabled = YES;
    }

}

- (void) openGoogleMaps
{
    self.GoButton.enabled = NO;

    
    if (self.endPlacemark) {
        CLPlacemark *placemark = self.endPlacemark;
        [[UIApplication sharedApplication] openURL:
                      [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=walking",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude]]];
        self.GoButton.enabled = YES;
    }
    
}

- (void) openUber
{
    NSString *uberURLString = [NSString stringWithFormat:@"uber://?client_id=%@&action=setPickup&pickup[latitude]=%f&pickup[longitude]=%f&dropoff[latitude]=%f&dropoff[longitude]=%f&product_id=%@",uberClientID,self.startLocationLatitude,self.startLocationLongitude,self.endPlacemark.location.coordinate.latitude,self.endPlacemark.location.coordinate.longitude,self.uberProductID];
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:uberURLString]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
