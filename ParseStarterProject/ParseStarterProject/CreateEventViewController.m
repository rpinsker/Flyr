//
//  CreateEventViewController.m
//  Flyr
//
//  Created by Rachel Pinsker on 4/1/15.
//
//

#import "CreateEventViewController.h"
#import <Parse/Parse.h>

@interface CreateEventViewController ()

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *addressStringTextField;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIDatePicker *startTimeDatePicker;
@property (nonatomic, strong) UIDatePicker *endTimeDatePicker;

@end

#define FONT_STRING @"AvenirNext-Medium"
#define TITLE_FONT_STRING @"AvenirNext-Medium"

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[UIControl alloc] initWithFrame:self.view.frame];
    [(UIControl *)(self.view) addTarget:self
                                 action:@selector(backgroundTapped)
                       forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    // add save button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePressed)];
    
    // text field location variables
    CGRect viewFrame = self.view.frame;
    int textFieldHeight = 35;
    int textFieldWidth = viewFrame.size.width - 2*textFieldHeight;
    int nameTextFieldY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height +  textFieldHeight/5;
    int addressStringTextFieldY = nameTextFieldY + 1.5*textFieldHeight;
    
    //set up text fields
    self.nameTextField = [[UITextField alloc] init];
    self.nameTextField.frame = CGRectMake(0, 0, textFieldWidth, textFieldHeight);
    self.nameTextField.center = CGPointMake(viewFrame.size.width / 2, nameTextFieldY + (textFieldHeight/2));
    self.nameTextField.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    self.nameTextField.textColor = [UIColor whiteColor];
    self.nameTextField.font = [UIFont fontWithName:FONT_STRING size:17];
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    NSAttributedString *placeholderText = [[NSAttributedString alloc]initWithString:@"event name" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    self.nameTextField.attributedPlaceholder = placeholderText;
    [self.view addSubview:self.nameTextField];
    
    self.addressStringTextField = [[UITextField alloc] init];
    self.addressStringTextField.frame = CGRectMake(0, 0, textFieldWidth, textFieldHeight);
    self.addressStringTextField.center = CGPointMake(viewFrame.size.width / 2, addressStringTextFieldY + (textFieldHeight / 2));
    self.addressStringTextField.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    self.addressStringTextField.textColor = [UIColor whiteColor];
    self.addressStringTextField.font = [UIFont fontWithName:FONT_STRING size:17];
    placeholderText = [[NSAttributedString alloc]initWithString:@"address description" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    self.addressStringTextField.attributedPlaceholder = placeholderText;
    self.addressStringTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self.view addSubview:self.addressStringTextField];

    // set up date pickers
    self.startTimeDatePicker = [[UIDatePicker alloc] init];
    self.startTimeDatePicker.frame = CGRectMake(0, addressStringTextFieldY + 1.5*textFieldHeight, self.startTimeDatePicker.frame.size.width, self.startTimeDatePicker.frame.size.height);
    [self.view addSubview:self.startTimeDatePicker];
    
    self.endTimeDatePicker = [[UIDatePicker alloc] init];
    self.endTimeDatePicker.frame = CGRectMake(0, self.startTimeDatePicker.frame.size.height + self.startTimeDatePicker.frame.origin.y, self.endTimeDatePicker.frame.size.width, self.endTimeDatePicker.frame.size.height);
    [self.view addSubview:self.endTimeDatePicker];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) savePressed
{
    self.view.userInteractionEnabled = NO;
    
    PFObject *newEvent = [PFObject objectWithClassName:@"Event"];
    newEvent[@"eventName"] = self.nameTextField.text;
    newEvent[@"startTime"] = self.startTimeDatePicker.date;
    newEvent[@"endTime"] = self.endTimeDatePicker.date;
    newEvent[@"stringLocation"] = self.addressStringTextField.text;
    
    [newEvent saveInBackground];
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.addressStringTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks) {
            CLPlacemark *placemark = placemarks[0];
            PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLocation:placemark.location];
            newEvent[@"location"] = geopoint;
            [newEvent saveInBackground];
        }
    }];
    
    self.view.userInteractionEnabled = YES;
    [self.navigationController popViewControllerAnimated:YES];
    

}

- (void) backgroundTapped
{
    if ([self.nameTextField isFirstResponder])
        [self.nameTextField resignFirstResponder];
    else if ([self.addressStringTextField isFirstResponder])
        [self.addressStringTextField resignFirstResponder];
    
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
