//
//  ContactTableViewCell.h
//  Flyr
//
//  Created by Rachel Pinsker on 5/19/15.
//
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *image;

- (void) setEmailsArray:(NSArray *)emailsArray;
- (void) setPhoneNumbersArray:(NSArray *)phoneNumbersArray;
- (void) setPhoneNumbersTypeArray:(NSArray *)phoneNumbersTypeArray;
- (NSArray *) getPhoneNumbersTypeArray;
- (NSArray *) getPhoneNumbersArray;

@end
