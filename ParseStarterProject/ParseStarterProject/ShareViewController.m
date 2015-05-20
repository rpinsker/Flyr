//
//  ShareViewController.m
//  Flyr1
//
//  Created by Rachel Pinsker on 12/22/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import "ShareViewController.h"
#import "EventViewController.h"
#import "ContactTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>

#define CONTACTS_TABLE_VIEW_CELL_HEIGHT 58 // change CELL_HEIGHT in ContactTableViewCell.m if this changes
#define FONT_STRING @"AvenirNext-Medium"
#define FONT_SIZE 23
#define NUM_TABLE_VIEW_CELLS 2
#define TEXT 0
#define EMAIL 1
#define FACEBOOK_MESSAGE 2

@interface ShareViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSDictionary *contactsInSectionsDict;
@property (nonatomic, strong) UITableView *contactsTableView;
@property (nonatomic, strong) NSArray *alphabetArray;

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
        return;
    }
    
    //set up image view for background
    int statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(0, statusBarHeight + 10, mainBounds.size.width, mainBounds.size.height - (statusBarHeight + 10));
        //self.imageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        //self.imageView.layer.borderWidth = 10.0;
        [self.view addSubview:self.imageView ];
        [self.view sendSubviewToBack:self.imageView];
    }
    self.imageView.image = self.eventImage;
    
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
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
    
    
    //set background color
    //self.view.backgroundColor = [UIColor darkGrayColor];
    
    // set up alphabet array
    if (!self.alphabetArray) {
        self.alphabetArray = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"#"];
    }
    if (!self.contactsInSectionsDict) {
        self.contactsInSectionsDict = [[NSMutableDictionary alloc] init];
        for (NSString *letter in self.alphabetArray) {
            NSArray *contacts = [[NSArray alloc] init];
            [self.contactsInSectionsDict setValue:contacts forKey:letter];
        }
    }
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        ABAddressBookRef addrBook = ABAddressBookCreateWithOptions(NULL, nil);
        CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addrBook);
        
        CFMutableArrayRef mutableContacts = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                                     CFArrayGetCount(contacts),
                                                                     contacts);
        CFArraySortValues(mutableContacts,
                          CFRangeMake(0, CFArrayGetCount(mutableContacts)),
                          (CFComparatorFunction) ABPersonComparePeopleByName,
                          (void*) ABPersonGetSortOrdering());
        
        self.allContacts = (__bridge NSArray *)mutableContacts;
        [self putContactsInSections];

        CGRect tableViewFrame = CGRectMake(self.view.frame.origin.x, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height);
        self.contactsTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
        [self.contactsTableView registerClass:[ContactTableViewCell class]
                 forCellReuseIdentifier:@"ContactTableViewCell"];
        self.contactsTableView.dataSource = self;
        self.contactsTableView.delegate = self;
        self.contactsTableView.rowHeight = CONTACTS_TABLE_VIEW_CELL_HEIGHT;
        self.contactsTableView.backgroundColor = [UIColor colorWithRed:.89 green:.39 blue:.39 alpha:1.0];
        self.contactsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        UIView *headerView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.frame];
        UILabel *tableTitleLabel = [[UILabel alloc] initWithFrame:headerView.frame];
        tableTitleLabel.text = @"Share Event";
        tableTitleLabel.font = [UIFont fontWithName:FONT_STRING size:FONT_SIZE];
        tableTitleLabel.backgroundColor = [UIColor clearColor];
        tableTitleLabel.textColor = [UIColor whiteColor];
        tableTitleLabel.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:tableTitleLabel];
        self.contactsTableView.tableHeaderView = headerView;
        [self.contactsTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [self.contactsTableView setSectionIndexColor:[UIColor whiteColor]];
        [self.view addSubview:self.contactsTableView];
        
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                // get info about screen size
                CGRect mainBounds = [UIScreen mainScreen].bounds;
                
                //set up table view
                int optionsTableViewHeight = 100; // if you change this, change caption height in EventTableViewCell
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
            }
            else {
                ABAddressBookRef addrBook = ABAddressBookCreateWithOptions(NULL, nil);
                
                CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addrBook);
                
                CFMutableArrayRef mutableContacts = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                                             CFArrayGetCount(contacts),
                                                                             contacts);
                CFArraySortValues(mutableContacts,
                                  CFRangeMake(0, CFArrayGetCount(mutableContacts)),
                                  (CFComparatorFunction) ABPersonComparePeopleByName,
                                  (void*) ABPersonGetSortOrdering());
                
                
                self.allContacts = (__bridge NSArray *)mutableContacts;
                [self putContactsInSections];
                CGRect tableViewFrame = CGRectMake(self.view.frame.origin.x, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height);
                self.contactsTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
                [self.contactsTableView registerClass:[ContactTableViewCell class]
                               forCellReuseIdentifier:@"ContactTableViewCell"];
                self.contactsTableView.dataSource = self;
                self.contactsTableView.delegate = self;
                self.contactsTableView.rowHeight = CONTACTS_TABLE_VIEW_CELL_HEIGHT;
                self.contactsTableView.backgroundColor = [UIColor colorWithRed:.89 green:.39 blue:.39 alpha:1.0];
                self.contactsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                UIView *headerView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.frame];
                UILabel *tableTitleLabel = [[UILabel alloc] initWithFrame:headerView.frame];
                tableTitleLabel.text = @"Share Event";
                tableTitleLabel.font = [UIFont fontWithName:FONT_STRING size:FONT_SIZE];
                tableTitleLabel.backgroundColor = [UIColor clearColor];
                tableTitleLabel.textColor = [UIColor whiteColor];
                tableTitleLabel.textAlignment = NSTextAlignmentCenter;
                [headerView addSubview:tableTitleLabel];
                self.contactsTableView.tableHeaderView = headerView;
                [self.contactsTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
                [self.contactsTableView setSectionIndexColor:[UIColor whiteColor]];
                [self.view addSubview:self.contactsTableView];
            }
        });
    }
    else {
        // get info about screen size
        CGRect mainBounds = [UIScreen mainScreen].bounds;
        
        //set up table view
        int optionsTableViewHeight = 100; // if you change this, change caption height in EventTableViewCell
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
    }
    
}

- (void) putContactsInSections
{
    if (ABPersonGetSortOrdering() == kABPersonSortByFirstName) {
        NSUInteger numContacts = [self.allContacts count];
        NSUInteger currentLetterCounter = 0;
        NSMutableArray *contactsForCurrentLetter = [[NSMutableArray alloc] init];
        NSString *currentLetter;
        for (int i = 0; i < numContacts; i++) {
            currentLetter = self.alphabetArray[currentLetterCounter];
            ABRecordRef ref = (__bridge ABRecordRef)(self.allContacts[i]);
            CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            if (!firstName)
                firstName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            NSString *firstNameLetter = (__bridge NSString *)firstName;
            NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
            for (NSUInteger i = 0; i < [firstNameLetter length]; i++) {
                if ([letters characterIsMember:[firstNameLetter characterAtIndex:i]]) {
                    firstNameLetter = [NSString stringWithFormat:@"%C",[firstNameLetter characterAtIndex:i]];
                }
            }
            if ([firstNameLetter isEqualToString:currentLetter] || [[firstNameLetter lowercaseString] isEqualToString:currentLetter] || [firstNameLetter isEqualToString:@"*"]) {
                [contactsForCurrentLetter addObject:(__bridge id)(ref)];
            }
            else { // new letter
                [self.contactsInSectionsDict setValue:[contactsForCurrentLetter copy] forKey:currentLetter];
                contactsForCurrentLetter = [[NSMutableArray alloc] init];
                currentLetterCounter++;
                while (![firstNameLetter isEqualToString:self.alphabetArray[currentLetterCounter]] && ![[firstNameLetter lowercaseString] isEqualToString:self.alphabetArray[currentLetterCounter]] && ![firstNameLetter isEqualToString:@"*"]) {
                    currentLetterCounter++;
                }
                [contactsForCurrentLetter addObject:(__bridge id)(ref)];
                
            }
        }
        [self.contactsInSectionsDict setValue:[contactsForCurrentLetter copy] forKey:currentLetter];
    }
    else { // sort by last name
        NSUInteger numContacts = [self.allContacts count];
        NSUInteger currentLetterCounter = 0;
        NSMutableArray *contactsForCurrentLetter = [[NSMutableArray alloc] init];
        NSString *currentLetter;
        for (int i = 0; i < numContacts; i++) {
            currentLetter = self.alphabetArray[currentLetterCounter];
            ABRecordRef ref = (__bridge ABRecordRef)(self.allContacts[i]);
            CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            if (!lastName)
                lastName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            NSString *firstNameLetter = (__bridge NSString *)lastName;
            NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
            for (NSUInteger i = 0; i < [firstNameLetter length]; i++) {
                if ([letters characterIsMember:[firstNameLetter characterAtIndex:i]]) {
                    firstNameLetter = [NSString stringWithFormat:@"%C",[firstNameLetter characterAtIndex:i]];
                }
            }
            if ([firstNameLetter isEqualToString:currentLetter] || [[firstNameLetter lowercaseString] isEqualToString:currentLetter] || [firstNameLetter isEqualToString:@"*"]) {
                [contactsForCurrentLetter addObject:(__bridge id)(ref)];
            }
            else { // new letter
                [self.contactsInSectionsDict setValue:[contactsForCurrentLetter copy] forKey:currentLetter];
                contactsForCurrentLetter = [[NSMutableArray alloc] init];
                currentLetterCounter++;
                NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
                while (![firstNameLetter isEqualToString:self.alphabetArray[currentLetterCounter]] && ![[firstNameLetter lowercaseString] isEqualToString:self.alphabetArray[currentLetterCounter]] && ![letters characterIsMember:firstNameLetter]) {
                    currentLetterCounter++;
                }
                [contactsForCurrentLetter addObject:(__bridge id)(ref)];
                
            }
        }
        [self.contactsInSectionsDict setValue:[contactsForCurrentLetter copy] forKey:currentLetter];
    }
    
}

#pragma mark - Table View
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.contactsTableView]) {
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell"
                                                                forIndexPath:indexPath];
        
        NSString *letter = self.alphabetArray[indexPath.section];
        NSArray *contacts = self.contactsInSectionsDict[letter];
        // get name
        CFStringRef firstName, lastName;
        ABRecordRef ref = (__bridge ABRecordRef)(contacts[indexPath.row]);
        
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
        NSString *fullName;
        if (lastName && firstName) {
            fullName = [NSString stringWithFormat:@"\t%@ %@",(__bridge NSString *)firstName,(__bridge NSString *)lastName];
        }
        else if (lastName) { // just last name
            fullName = [NSString stringWithFormat:@"\t%@",(__bridge NSString *)lastName];
        }
        else { // just first name
            fullName = [NSString stringWithFormat:@"\t%@",(__bridge NSString *)firstName];
        }
        
        cell.name = fullName;
        
        
        ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        CFIndex numPhoneNumbers = ABMultiValueGetCount(phones);
        NSMutableArray *phoneNumbersMut = [[NSMutableArray alloc] init];
        NSMutableArray *phoneNumberTypesMut = [[NSMutableArray alloc] init];
        for(CFIndex i = 0; i < numPhoneNumbers; i++) {
            NSString *phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            [phoneNumbersMut addObject:phoneNumber];
            
            NSString *phoneNumberType = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
            [phoneNumberTypesMut addObject:phoneNumberType];
        }
        [cell setPhoneNumbersArray:phoneNumbersMut];
        [cell setPhoneNumbersTypeArray:phoneNumberTypesMut];
        
        return cell;
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:.89 green:.39 blue:.39 alpha:.8];
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
    if ([tableView isEqual:self.contactsTableView]) {
        //return [self.allContacts count];
        NSString *letter = self.alphabetArray[section];
        return [self.contactsInSectionsDict[letter] count];
    }
    
    return NUM_TABLE_VIEW_CELLS;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.contactsTableView]) {
        return 27;
    }
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.alphabetArray[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.contactsTableView]) {
        return self.alphabetArray;
    }
    return nil;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.contactsTableView]) {
        ContactTableViewCell *cell = (ContactTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSArray *phoneNumbers = [cell getPhoneNumbersArray];
        NSArray *phoneNumberTypes = [cell getPhoneNumbersTypeArray];
        
        NSUInteger *numPhoneNumbers = [phoneNumbers count];
        if (numPhoneNumbers != 0) {
            if ((int)numPhoneNumbers == 1) {
                [self sendTextToRecipients:phoneNumbers];
            }
            // TODO: potentially find a better system for choosing what number to send it to
            else {
                BOOL *foundANumber = NO;
                for (int i = 0; i < [phoneNumbers count]; i++) {
                    if ([phoneNumberTypes[i] isEqualToString:(NSString*)kABPersonPhoneMobileLabel] || [phoneNumberTypes[i] isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
                        foundANumber = YES;
                        [self sendTextToRecipients:@[phoneNumbers[i]]];
                    }
                }
                if (!foundANumber) { // just send it to the first number in the list...
                    [self sendTextToRecipients:@[phoneNumbers[0]]];
                }
            }
        }
        else { // no phone numbers, try email
            // TODO: set up email
        }
        
        
        
        return;
    }
    
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

- (void) sendTextToRecipients:(NSArray *)recipients
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
        
        [messageVC setRecipients:recipients];
        
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
