//
//  EventDetailViewController.m
//  Flyr1
//
//  Created by Rachel Pinsker on 12/20/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import "EventDetailViewController.h"
#import <MapKit/MapKit.h>


#define FONT_STRING @"AvenirNext-Medium"
#define FONT_CAPTION_STRING_SIZE 15
#define BUTTON_HEIGHT 60
#define GO_OR_NO_BUTTON_STRING_SIZE 23

@interface EventDetailViewController ()

@property (nonatomic, strong) UIButton *GoButton;
@property (nonatomic, strong) UIButton *NoButton;

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
    MKMapView *map = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,mainScreenBounds.size.width, mainScreenBounds.size.height/2)];
    map.zoomEnabled = YES;
    map.scrollEnabled = NO;
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks) {
            CLPlacemark *placemark = placemarks[0];
            MKPlacemark *mkplacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
            [map addAnnotation:mkplacemark];
            MKCoordinateRegion region;
            region.center = mkplacemark.coordinate;
            region.span = MKCoordinateSpanMake(.005, .005);
            map.region = region;
        }
    }];
    
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
    
    [self.view addSubview:detailTextView];
    
    // make buttons
    self.GoButton = [[UIButton alloc] initWithFrame:CGRectMake(0,mainScreenBounds.size.height - BUTTON_HEIGHT, mainScreenBounds.size.width/2, BUTTON_HEIGHT)];
    [self.GoButton addTarget:self
                          action:@selector(openMap)
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

- (void) openMap
{
    self.GoButton.enabled = NO;
    // TODO: change this to show the actual address from the above geocoder (make mkplacemark not a local var). Be careful with threading though--here, must make sure mkplacemark has been initialized, and if it hasn't been, disable takeMeThereButton and
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        self.GoButton.enabled = YES;
        if (placemarks) {
            CLPlacemark *placemark = placemarks[0];
            MKPlacemark *mkplacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
            
            NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
            
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:mkplacemark];
            [MKMapItem openMapsWithItems: @[toLocation]
                           launchOptions:options];
        }
    }];
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
