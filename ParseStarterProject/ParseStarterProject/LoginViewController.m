//
//  LoginViewController.m
//  Flyr1
//
//  Created by Rachel Pinsker on 1/14//Users/Rachel/Downloads/parse-starter-project-1/ParseStarterProject/ParseStarterProject/SignUpViewController.m15.
//  Copyright (c) 2015 ___rpinsker___. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "SignUpViewController.h"

#import "ShareViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;

@end

#define FONT_STRING @"AvenirNext-Medium"
#define TITLE_FONT_STRING @"AvenirNext-Medium"

@implementation LoginViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
/* FOR MAKING TEST EVENTS 
    // make events
    for (int i = 0; i < 9; i++) {
        PFObject *event = [PFObject objectWithClassName:@"Event"];
        event[@"eventName"] = [NSString stringWithFormat:@"Event 1%d",i];
        event[@"eventDescription"] = [NSString stringWithFormat:@"%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n",i,i,i,i,i,i,i,i,i,i,i,i,i,i,i];
        
        // start date
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.month = 4;
        dateComponents.day = 2;
        dateComponents.hour = i+12;
        dateComponents.year = 2015;
        //dateComponents.timeZone = [NSTimeZone timeZoneWithName:@"US/Central"];
        dateComponents.minute = 0;
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *startDate = [gregorian dateFromComponents:dateComponents];
        event[@"startTime"] = startDate;
        dateComponents.hour = i+12+2;
        NSDate *endDate = [gregorian dateFromComponents:dateComponents];
        event[@"endTime"] = endDate;
        event[@"stringLocation"] = @"1003 E 61st street Chicago IL, 60637";
        [event save];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:@"1003 E 61st street chicago IL, 60637" completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks) {
                CLPlacemark *placemark = placemarks[0];
                PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLocation:placemark.location];
                event[@"location"] = geopoint;
                [event save];
            }
        }];
        
    }
  
   */

    self.view = [[UIControl alloc] initWithFrame:self.view.frame];
    [(UIControl *)(self.view) addTarget:self
                                 action:@selector(backgroundTapped)
                       forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor colorWithRed:.89 green:.39 blue:.39 alpha:1.0];
    
    // text field location variables
    CGRect viewFrame = self.view.frame;
    int textFieldHeight = 35;
    int textFieldWidth = viewFrame.size.width / 2;
    int usernameTextFieldY = viewFrame.size.height / 3;
    int passwordTextFieldY = usernameTextFieldY + 3*textFieldHeight;
    
    //set up text fields
    self.usernameTextField = [[UITextField alloc] init];
    self.usernameTextField.frame = CGRectMake(0, 0, textFieldWidth, textFieldHeight);
    self.usernameTextField.center = CGPointMake(viewFrame.size.width / 2, usernameTextFieldY + (textFieldHeight/2));
    self.usernameTextField.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    self.usernameTextField.textColor = [UIColor whiteColor];
    self.usernameTextField.font = [UIFont fontWithName:FONT_STRING size:17];
    self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.usernameTextField];
    
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.frame = CGRectMake(0, 0, textFieldWidth, textFieldHeight);
    self.passwordTextField.center = CGPointMake(viewFrame.size.width / 2, passwordTextFieldY + (textFieldHeight / 2));
    self.passwordTextField.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    self.passwordTextField.textColor = [UIColor whiteColor];
    self.passwordTextField.font = [UIFont fontWithName:FONT_STRING size:17];
    self.passwordTextField.secureTextEntry = YES;
    [self.view addSubview:self.passwordTextField];
    
    // set up text labels
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textFieldWidth, textFieldHeight)];
    usernameLabel.center = CGPointMake(viewFrame.size.width / 2, usernameTextFieldY - (textFieldHeight));
    usernameLabel.text = @"username:";
    usernameLabel.textColor = [UIColor whiteColor];
    usernameLabel.textAlignment = NSTextAlignmentCenter;
    usernameLabel.font = [UIFont fontWithName:FONT_STRING size:20];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textFieldWidth, textFieldHeight)];
    passwordLabel.center = CGPointMake(viewFrame.size.width / 2, passwordTextFieldY - (textFieldHeight));
    passwordLabel.text = @"password:";
    passwordLabel.textColor = [UIColor whiteColor];
    passwordLabel.textAlignment = NSTextAlignmentCenter;
    passwordLabel.font = [UIFont fontWithName:FONT_STRING size:20];
    
    
    [self.view addSubview:usernameLabel];
    [self.view addSubview:passwordLabel];
    
    // set up buttons -- login and signup
    // Login button
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textFieldWidth/2, textFieldHeight)];
    loginButton.center = CGPointMake(viewFrame.size.width / 2, passwordTextFieldY + 2*textFieldHeight);
    loginButton.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    loginButton.layer.cornerRadius = 10.0;
    [loginButton setTitle:@"login" forState:UIControlStateNormal];
    loginButton.titleLabel.textColor = [UIColor whiteColor];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    loginButton.titleLabel.font = [UIFont fontWithName:FONT_STRING size:20];
    
    [loginButton addTarget:self
                    action:@selector(loginPressed)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
    
    // Signup button
    UIButton *signupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2*textFieldHeight)];
    signupButton.center = CGPointMake(viewFrame.size.width / 2, self.view.frame.size.height - textFieldHeight);
    signupButton.backgroundColor = [UIColor colorWithRed:.933 green:1.0 blue:.42 alpha:1.0];
    signupButton.layer.cornerRadius = 10.0;
    [signupButton setTitle:@"sign up" forState:UIControlStateNormal];
    signupButton.titleLabel.textColor = [UIColor darkGrayColor];
    signupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signupButton.titleLabel.font = [UIFont fontWithName:FONT_STRING size:20];
    
    [signupButton addTarget:self
                     action:@selector(signupPressed)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:signupButton];
    
    
    // FLYR text
    UILabel *flyrLabel;
    if ([UIScreen mainScreen].bounds.size.height == 480) { // different for an iPhone 4
        int yForFlyrLabel = (usernameLabel.bounds.origin.y - self.navigationController.navigationBar.frame.size.height) / 2.0;
        flyrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yForFlyrLabel, viewFrame.size.width, 3*textFieldHeight)];
    }
    else {
        flyrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, usernameTextFieldY / 4.0, viewFrame.size.width, 3*textFieldHeight)];
    }
    //flyrLabel.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    flyrLabel.text = @"flyr";
    flyrLabel.font = [UIFont fontWithName:TITLE_FONT_STRING size:65.0];
    flyrLabel.textAlignment = NSTextAlignmentCenter;
    flyrLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:flyrLabel];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser.username) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ShareViewController alloc] init]];
        [self presentViewController:nav animated:NO completion:nil];
    } else {
        // show the signup or login screen
    }
}

- (void) backgroundTapped
{
    if ([self.usernameTextField isFirstResponder])
        [self.usernameTextField resignFirstResponder];
    else if ([self.passwordTextField isFirstResponder])
        [self.passwordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void) loginPressed
{
    self.view.userInteractionEnabled = NO;
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ShareViewController alloc] init]];
                                            [self presentViewController:nav animated:NO completion:nil];
                                        } else {
                                            // The login failed. Check error to see why.
                                            self.view.userInteractionEnabled = YES;
                                        }
                                    }];
    
    
}

- (void) signupPressed
{
    SignUpViewController *signUpVC = [[SignUpViewController alloc] init];
    [self presentViewController:signUpVC animated:YES completion:NULL];
}



/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
