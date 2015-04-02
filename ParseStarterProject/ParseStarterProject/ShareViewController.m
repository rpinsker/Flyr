//
//  ShareViewController.m
//  Flyr1
//
//  Created by Rachel Pinsker on 12/22/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import "ShareViewController.h"
#import "EventViewController.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>

#define NUM_TABLE_VIEW_CELLS 2
#define TEXT 0
#define EMAIL 1
#define FACEBOOK_MESSAGE 2

@interface ShareViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation ShareViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    
    if (self.isLogout == YES)
    {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
    }
    
    if (!self.eventVC) // if app is just being opened, then want to create and push the main eventvc page
    {
        [self.navigationController pushViewController:[[EventViewController alloc] init]
                                             animated:YES];
    }
    
    //set up gesture recognizer to go back (which is actually going forward)
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(back)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
 
// TODO: (decide) could ask for contacts and implement a search function to send to people. Otherwise, could just give the option to email, text, facebook message, etc. because those have the contacts/search functionality already built in in the compose view.
//    //ask for contacts
//    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
//        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//            if (granted) {
//                NSLog(@"Access granted!");
//            } else {
//                NSLog(@"Access denied!");
//            }
//        });
//    }
    
    // get info about screen size
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    int statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
//    //set up image view for background TODO: use correct image
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.eventImage];
//    imageView.frame = CGRectMake(0, statusBarHeight + 10, mainBounds.size.width, mainBounds.size.height - (statusBarHeight + 10));
//    imageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
//    imageView.layer.borderWidth = 10.0;
//    [self.view addSubview:imageView];
    
    //set up table view
    int optionsTableViewHeight = 200; // if you change this, change caption height in EventTableViewCell
    UITableView *optionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, mainBounds.size.height - optionsTableViewHeight, mainBounds.size.width, optionsTableViewHeight)
                                                                 style:UITableViewStylePlain];
    [optionsTableView registerClass:[UITableViewCell class]
             forCellReuseIdentifier:@"UITableViewCell"];
    optionsTableView.rowHeight = optionsTableViewHeight/(NUM_TABLE_VIEW_CELLS);
    optionsTableView.scrollEnabled = NO;
    optionsTableView.dataSource = self;
    optionsTableView.delegate = self;
    optionsTableView.backgroundColor = [UIColor clearColor];
    optionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:optionsTableView];
    
    //set background color
    self.view.backgroundColor = [UIColor darkGrayColor];
    
}

#pragma mark - Table View
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:.2 alpha:.7];
    switch (indexPath.row) {
        case TEXT:
            cell.textLabel.text = @"TEXT";
            break;
        case EMAIL:
            cell.textLabel.text = @"EMAIL";
            break;
        case FACEBOOK_MESSAGE:
            cell.textLabel.text = @"FACEBOOK MESSAGE";
            break;
        default:
            break;
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_TABLE_VIEW_CELLS;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case TEXT:
            [self sendText];
            break;
        case EMAIL:
            [self sendEmail];
            break;
        case FACEBOOK_MESSAGE:
            [self sendFBMessage];
            break;
        default:
            break;
    }
}

#pragma mark - Text
- (void) sendText
{
    if ([MFMessageComposeViewController canSendText]) { // can send a text. open popup composer
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        messageVC.messageComposeDelegate = self;
        
        
        NSDateFormatter *dateFormatterForTime = [[NSDateFormatter alloc] init];
        dateFormatterForTime.timeStyle = NSDateFormatterShortStyle;
        dateFormatterForTime.dateStyle = NSDateFormatterNoStyle;
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatterForTime setLocale:usLocale];
        NSString *startTime = [dateFormatterForTime stringFromDate:self.event[@"startTime"]];
        NSString *endTime = [dateFormatterForTime stringFromDate:self.event[@"endTime"]];
        
        [messageVC setBody: [NSString stringWithFormat:@"%@ -- TIME: %@ - %@\nLOCATION: %@",self.event[@"eventName"],startTime,endTime,self.event[@"stringLocation"]]];
        
        [self presentViewController:messageVC animated:NO completion:NULL];
    }
    else { // can't send a text. show an alert view
        UIAlertController *noTextAlert = [UIAlertController alertControllerWithTitle:@"Can't send a text message right now"
                                                                             message:@"If you think this is an error, try again"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
                                           
        [noTextAlert addAction:okAction];
        [self presentViewController:noTextAlert
                           animated:YES
                         completion:nil];
    }
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultCancelled || result == MessageComposeResultSent) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
}

#pragma mark - Email
- (void) sendEmail
{
    // check if can send mail
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailvc = [[MFMailComposeViewController alloc] init];
        mailvc.mailComposeDelegate = self;
        
        NSDateFormatter *dateFormatterForTime = [[NSDateFormatter alloc] init];
        dateFormatterForTime.timeStyle = NSDateFormatterShortStyle;
        dateFormatterForTime.dateStyle = NSDateFormatterNoStyle;
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatterForTime setLocale:usLocale];
        NSString *startTime = [dateFormatterForTime stringFromDate:self.event[@"startTime"]];
        NSString *endTime = [dateFormatterForTime stringFromDate:self.event[@"endTime"]];
        
        [mailvc setMessageBody:[NSString stringWithFormat:@"%@\n\nTIME: %@ - %@\n\nLOCATION: %@\n\nDETAILS:\n%@",self.event[@"eventName"],startTime,endTime,self.event[@"stringLocation"],self.event[@"eventDescription"]] isHTML:NO];
        [mailvc setSubject:[NSString stringWithFormat:@"FLYR EVENT: %@",self.event[@"eventName"] ]];
        
        [self presentViewController:mailvc animated:YES completion:NULL];
    }

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultCancelled || result == MFMailComposeResultSent) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
}

#pragma mark - Facebook message
- (void) sendFBMessage
{
    
}

#pragma mark - AlertController


#pragma mark - navigation and memory
- (void) back
{
    //[self.navigationController popViewControllerAnimated:YES];
    if (!self.eventVC)
        [self.navigationController pushViewController:[[EventViewController alloc] init]
                                         animated:YES];
    else
        [self.navigationController pushViewController:self.eventVC
                                             animated:YES];
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
