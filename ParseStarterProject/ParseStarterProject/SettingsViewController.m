//
//  SettingsViewController.m
//  Flyr1
//
//  Created by Rachel Pinsker on 1/17/15.
//  Copyright (c) 2015 ___rpinsker___. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>

@interface SettingsViewController ()

@property (nonatomic, strong) UISlider *radiusSlider;
@property (nonatomic, strong) UILabel *radiusSliderLabel;
@property (nonatomic) CGFloat oldRadiusSliderValue;
@property (nonatomic, strong) PFUser *currentUser;

@end

#define FONT_STRING @"AvenirNext-Medium"

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    self.navigationItem.title = @"Settings";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:.05 alpha:1];
    self.navigationController.navigationBar.alpha = .8;
    self.navigationController.navigationBar.titleTextAttributes = @{FONT_STRING : NSFontAttributeName,
                                                                    NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                    };

    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                                         style:UIBarButtonItemStylePlain
                                                                                                        target:self
                                                                                                        action:@selector(backButtonPressed)];
    [self.navigationController.navigationBar.topItem.backBarButtonItem setAction:@selector(backButtonPressed)];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.currentUser = [PFUser currentUser];
    
    // variables for setting up the view
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    int navBarHeight = self.navigationController.navigationBar.frame.size.height;
    int indentWidth = 30;
    int heightFromNavBar = 20;
    int radiusSliderHeight = 30;
    
    // set up slider
    self.radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(indentWidth, statusBarFrame.size.height + navBarHeight + heightFromNavBar, self.view.frame.size.width - 2*indentWidth, radiusSliderHeight)];
    self.radiusSlider.tintColor = [UIColor darkGrayColor];
    self.radiusSlider.minimumValue = 1;
    self.radiusSlider.maximumValue = 20;
    [self.radiusSlider addTarget:self
                          action:@selector(sliderChanged)
                forControlEvents:UIControlEventAllTouchEvents];
    self.radiusSlider.value = [self.currentUser[@"radius"] floatValue];; // TODO: set this to the actual current value
    
    // set up slider label
    self.radiusSliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(indentWidth, self.radiusSlider.frame.origin.y + 30, self.view.frame.size.width - 2*indentWidth, radiusSliderHeight)];
    self.radiusSliderLabel.text = [NSString stringWithFormat:@"Show events within: %.01f miles",self.radiusSlider.value];
    self.radiusSliderLabel.textAlignment = NSTextAlignmentCenter;
    self.radiusSliderLabel.font = [UIFont fontWithName:FONT_STRING size:17.0];
    self.radiusSliderLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:self.radiusSlider];
    [self.view addSubview:self.radiusSliderLabel];
    
    // save old slider value
    self.oldRadiusSliderValue = [self.currentUser[@"radius"] floatValue];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    float radius = self.radiusSlider.value;
    if (radius != self.oldRadiusSliderValue) { // need to update user's radius
            self.currentUser[@"radius"] = [NSNumber numberWithFloat:radius];
            [self.currentUser saveInBackground];
        }
}

#pragma mark - slider

- (void) sliderChanged
{
    [self.radiusSliderLabel setText:[NSString stringWithFormat:@"Show events within: %.01f miles",self.radiusSlider.value]];
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
