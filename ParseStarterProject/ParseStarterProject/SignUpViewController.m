//
//  SignUpViewController.m
//  ParseStarterProject
//
//  Created by Rachel Pinsker on 4/1/15.
//
//

#import "SignUpViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextField *activeField;

@end

#define FONT_STRING @"AvenirNext-Medium"
#define TITLE_FONT_STRING @"AvenirNext-Medium"

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view = [[UIControl alloc] initWithFrame:self.view.frame];
    [(UIControl *)(self.view) addTarget:self
                                 action:@selector(backgroundTapped)
                       forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    // set up scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.contentSize = self.view.frame.size;
    self.scrollView.scrollEnabled = YES;
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(backgroundTapped)]];
    [self.view addSubview:self.scrollView];
    
    
    // text field location variables
    CGRect viewFrame = self.view.frame;
    int textFieldHeight = 35;
    int textFieldWidth = viewFrame.size.width / 2;
    int usernameTextFieldY = viewFrame.size.height / 3;
    int passwordTextFieldY = usernameTextFieldY + 3*textFieldHeight;
    int emailTextFieldY = passwordTextFieldY + 3*textFieldHeight;
    
    //set up text fields
    self.usernameTextField = [[UITextField alloc] init];
    self.usernameTextField.frame = CGRectMake(0, 0, textFieldWidth, textFieldHeight);
    self.usernameTextField.center = CGPointMake(viewFrame.size.width / 2, usernameTextFieldY + (textFieldHeight/2));
    self.usernameTextField.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    self.usernameTextField.textColor = [UIColor whiteColor];
    self.usernameTextField.font = [UIFont fontWithName:FONT_STRING size:17];
    self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.scrollView addSubview:self.usernameTextField];
    
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.frame = CGRectMake(0, 0, textFieldWidth, textFieldHeight);
    self.passwordTextField.center = CGPointMake(viewFrame.size.width / 2, passwordTextFieldY + (textFieldHeight / 2));
    self.passwordTextField.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    self.passwordTextField.textColor = [UIColor whiteColor];
    self.passwordTextField.font = [UIFont fontWithName:FONT_STRING size:17];
    self.passwordTextField.secureTextEntry = YES;
    [self.scrollView addSubview:self.passwordTextField];
    
    self.emailTextField = [[UITextField alloc] init];
    self.emailTextField.frame = CGRectMake(0, 0, textFieldWidth, textFieldHeight);
    self.emailTextField.center = CGPointMake(viewFrame.size.width / 2, emailTextFieldY + (textFieldHeight / 2));
    self.emailTextField.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    self.emailTextField.textColor = [UIColor whiteColor];
    self.emailTextField.font = [UIFont fontWithName:FONT_STRING size:17];
    [self.scrollView addSubview:self.emailTextField];
    
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
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textFieldWidth, textFieldHeight)];
    emailLabel.center = CGPointMake(viewFrame.size.width / 2, emailTextFieldY - (textFieldHeight));
    emailLabel.text = @"email:";
    emailLabel.textColor = [UIColor whiteColor];
    emailLabel.textAlignment = NSTextAlignmentCenter;
    emailLabel.font = [UIFont fontWithName:FONT_STRING size:20];
    
    
    [self.scrollView addSubview:usernameLabel];
    [self.scrollView addSubview:passwordLabel];
    [self.scrollView addSubview:emailLabel];
    
    // set up buttons -- login and signup
    // Login button
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textFieldWidth/2, textFieldHeight)];
    loginButton.center = CGPointMake(viewFrame.size.width * 6 / 7, self.view.frame.size.height - textFieldHeight);
    loginButton.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    loginButton.layer.cornerRadius = 10.0;
    [loginButton setTitle:@"login" forState:UIControlStateNormal];
    loginButton.titleLabel.textColor = [UIColor whiteColor];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    loginButton.titleLabel.font = [UIFont fontWithName:FONT_STRING size:20];
    
    [loginButton addTarget:self
                    action:@selector(loginPressed)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:loginButton];

    
    // Signup button
    UIButton *signupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textFieldWidth/2, textFieldHeight)];
    signupButton.center = CGPointMake(viewFrame.size.width / 2, self.view.frame.size.height - 3*textFieldHeight);
    signupButton.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    signupButton.layer.cornerRadius = 10.0;
    [signupButton setTitle:@"sign up" forState:UIControlStateNormal];
    signupButton.titleLabel.textColor = [UIColor whiteColor];
    signupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signupButton.titleLabel.font = [UIFont fontWithName:FONT_STRING size:20];
    
    [signupButton addTarget:self
                     action:@selector(signupPressed)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:signupButton];
    
    
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
    flyrLabel.text = @"sign up";
    flyrLabel.font = [UIFont fontWithName:TITLE_FONT_STRING size:65.0];
    flyrLabel.textAlignment = NSTextAlignmentCenter;
    flyrLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:flyrLabel];
    
    [self registerForKeyboardNotifications];
    
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 1.2*kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}


- (void)signupPressed {
    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.emailTextField.text;
    
    user[@"radius"] = [NSNumber numberWithDouble:10.0];
    user[@"setUpDone"] = @NO;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
        } else {
            [PFUser logOut];
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@",errorString);
        }
    }];
}

- (void) loginPressed {
    LoginViewController *loginVC = (LoginViewController *)self.presentingViewController;
    loginVC.cameFromSignup = TRUE;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void) backgroundTapped
{
    if ([self.usernameTextField isFirstResponder])
        [self.usernameTextField resignFirstResponder];
    else if ([self.passwordTextField isFirstResponder])
        [self.passwordTextField resignFirstResponder];
    else if ([self.emailTextField isFirstResponder])
        [self.emailTextField resignFirstResponder];
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
