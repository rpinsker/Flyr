//
//  CreateEventViewController.m
//  Flyr
//
//  Created by Rachel Pinsker on 4/1/15.
//
//

#import "CreateEventViewController.h"
#import <Parse/Parse.h>

@interface CreateEventViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *addressStringTextField;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIDatePicker *startTimeDatePicker;
@property (nonatomic, strong) UIDatePicker *endTimeDatePicker;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIButton *takeAPhotoButton;
@property (nonatomic, strong) UIScrollView *sv;
@property (nonatomic, strong) UIButton *nextPageButton;

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
    
    // set up scroll view
    self.sv = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.sv.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height);
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    tapGR.numberOfTapsRequired = 1;
    [self.sv addGestureRecognizer:tapGR];
    // TODO: manually slide sv and add next and back buttons
    // TODO: fix GR on page 2 of sv
    self.sv.pagingEnabled = YES;
    self.sv.directionalLockEnabled = YES;
    self.sv.delegate = self;
    
    
    [self.view addSubview:self.sv];
    
    // text field location variables
    CGRect viewFrame = self.sv.frame;
    int textFieldHeight = 35;
    int textViewHeight = 2.5 * textFieldHeight;
    int textFieldWidth = viewFrame.size.width - 2*textFieldHeight;
    //int nameTextFieldY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height +  textFieldHeight/5;
    int nameTextFieldY = viewFrame.origin.y + textFieldHeight/3;
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
    [self.sv addSubview:self.nameTextField];
    
    self.addressStringTextField = [[UITextField alloc] init];
    self.addressStringTextField.frame = CGRectMake(0, 0, textFieldWidth, textFieldHeight);
    self.addressStringTextField.center = CGPointMake(viewFrame.size.width / 2, addressStringTextFieldY + (textFieldHeight / 2));
    self.addressStringTextField.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    self.addressStringTextField.textColor = [UIColor whiteColor];
    self.addressStringTextField.font = [UIFont fontWithName:FONT_STRING size:17];
    placeholderText = [[NSAttributedString alloc]initWithString:@"address description" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    self.addressStringTextField.attributedPlaceholder = placeholderText;
    self.addressStringTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self.sv addSubview:self.addressStringTextField];

    // set up picture stuff
    int imageViewInsetWidth = 25;
    int imageViewHeight = 250;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewInsetWidth, addressStringTextFieldY + 1.5*textFieldHeight, self.view.frame.size.width - 2*imageViewInsetWidth, imageViewHeight)];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    [self.sv addSubview:self.imageView];
    
    
    
    self.takeAPhotoButton = [[UIButton alloc] initWithFrame:self.imageView.frame];
    UIFont *font = [UIFont fontWithName:FONT_STRING size:20];
    NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:@"take a photo" attributes:@{font : NSFontAttributeName, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.takeAPhotoButton setTitle:[buttonTitle string] forState:UIControlStateNormal];
    [self.takeAPhotoButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.sv addSubview:self.takeAPhotoButton];
    
    // set up description text view
    self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, textFieldWidth, textViewHeight)];
    self.descriptionTextView.center = CGPointMake(3 * viewFrame.size.width / 2, nameTextFieldY + (textViewHeight/2));
    self.descriptionTextView.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    UIFont *descriptionFont = [UIFont fontWithName:FONT_STRING size:17];
    NSAttributedString *text = [[NSAttributedString alloc]initWithString:@"event description" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName : descriptionFont}];
    self.descriptionTextView.attributedText = text;
    self.descriptionTextView.delegate = self;
    [self.sv addSubview:self.descriptionTextView];
    
    
    // next page button
    int imageViewBottomY = self.imageView.frame.origin.y + imageViewHeight;
    self.nextPageButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width/2, imageViewBottomY + 1.5*textFieldHeight, viewFrame.size.width / 2, textFieldHeight)];
    UIFont *buttonTitleFont = [UIFont fontWithName:FONT_STRING size:20];
    NSAttributedString *nextButtonTitle = [[NSAttributedString alloc] initWithString:@"next page ----->" attributes:@{buttonTitleFont : NSFontAttributeName, NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.nextPageButton setTitle:[nextButtonTitle string] forState:UIControlStateNormal];
    [self.nextPageButton addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.sv addSubview:self.nextPageButton];
    
    // set up date pickers and their labels
    self.startTimeDatePicker = [[UIDatePicker alloc] init];
    self.startTimeDatePicker.frame = CGRectMake(viewFrame.size.width, self.imageView.frame.origin.y, self.startTimeDatePicker.frame.size.width, self.startTimeDatePicker.frame.size.height);
    [self.sv addSubview:self.startTimeDatePicker];
    
    UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.sv.frame.size.width, textFieldHeight/1.5)];
    startTimeLabel.center = CGPointMake(3 * self.sv.frame.size.width / 2, self.startTimeDatePicker.frame.origin.y);
    startTimeLabel.font = descriptionFont;
    startTimeLabel.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    startTimeLabel.textColor = [UIColor lightGrayColor];
    startTimeLabel.textAlignment = NSTextAlignmentCenter;
    startTimeLabel.text = @"start time:";
    [self.sv addSubview:startTimeLabel];
    
    self.endTimeDatePicker = [[UIDatePicker alloc] init];
    self.endTimeDatePicker.frame = CGRectMake(viewFrame.size.width, self.startTimeDatePicker.frame.size.height + self.startTimeDatePicker.frame.origin.y, self.endTimeDatePicker.frame.size.width, self.endTimeDatePicker.frame.size.height);
    [self.sv addSubview:self.endTimeDatePicker];
    
    UILabel *endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.sv.frame.size.width, textFieldHeight/1.5)];
    endTimeLabel.center = CGPointMake(3 * self.sv.frame.size.width / 2, self.endTimeDatePicker.frame.origin.y);
    endTimeLabel.font = descriptionFont;
    endTimeLabel.backgroundColor = [UIColor colorWithWhite:.1 alpha:.7];
    endTimeLabel.textColor = [UIColor lightGrayColor];
    endTimeLabel.textAlignment = NSTextAlignmentCenter;
    endTimeLabel.text = @"end time:";
    [self.sv addSubview:endTimeLabel];
    
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
    newEvent[@"eventDescription"] = self.descriptionTextView.text;
    
    /* start image */
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.85f);
    
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    [imageFile saveInBackground];
    
    [newEvent setObject:imageFile forKey:@"image"];
    
    /* end image */

    
    
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

- (void) nextPage
{
    
    CGRect pageTwo = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.sv scrollRectToVisible:pageTwo animated:YES];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void) backgroundTapped
{
    if ([self.nameTextField isFirstResponder])
        [self.nameTextField resignFirstResponder];
    else if ([self.addressStringTextField isFirstResponder])
        [self.addressStringTextField resignFirstResponder];
    
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"event description"]) {
        UIFont *descriptionFont = [UIFont fontWithName:FONT_STRING size:17];
        NSAttributedString *text = [[NSAttributedString alloc]initWithString:@"" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : descriptionFont}];
        self.descriptionTextView.attributedText = text;
    }
}

#pragma mark - photo
- (IBAction)takePicture:(id)sender
{
    // don't allow double clicking
    self.view.userInteractionEnabled = NO;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.showsCameraControls = YES;
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(180, 0, 80, 40);
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:@"To Library" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                         NSFontAttributeName: [UIFont fontWithName:@"STHeitiTC-Medium" size:17.0]}]
                          forState:UIControlStateNormal];
        imagePicker.cameraOverlayView = button;
        [button addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    self.imagePicker = imagePicker;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOverlay) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOverlay) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil];
    }];
    
    self.view.userInteractionEnabled = YES;
}

-(void)removeOverlay
{
    //camera is in editing mode; remove library button
    self.imagePicker.cameraOverlayView = nil;
}

-(void)addOverlay
{
    //camera is in picture taking mode after cancelling previous image; add library button
    NSAttributedString *buttonString = [[NSAttributedString alloc] initWithString:@"To Library" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"STHeitiTC-Medium" size:17.0], NSForegroundColorAttributeName: [UIColor whiteColor]}];
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(180, 0, 80, 40);
    [button setAttributedTitle:buttonString forState:UIControlStateNormal];
    self.imagePicker.cameraOverlayView = button;
    [button addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // get the image
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.imageView.image = image;
    
    // change the button
    UIFont *font = [UIFont fontWithName:FONT_STRING size:20];
    NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:@"retake photo" attributes:@{font : NSFontAttributeName, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.takeAPhotoButton setTitle:[buttonTitle string] forState:UIControlStateNormal];
    [self.takeAPhotoButton setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.size.height + self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height/5)];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)switchCamera:(id)sender
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
