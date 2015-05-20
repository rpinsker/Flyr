//
//  ContactTableViewCell.m
//  Flyr
//
//  Created by Rachel Pinsker on 5/19/15.
//
//

#import "ContactTableViewCell.h"
#import <AddressBook/AddressBook.h>

@interface ContactTableViewCell ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *imageViewForImage;
@property (strong, nonatomic) NSArray *phoneNumbersArray;
@property (strong, nonatomic) NSArray *phoneNumbersTypeArray;
@property (strong, nonatomic) NSArray *emailsArray;

@end

#define FONT_STRING @"AvenirNext-Medium"
#define FONT_SIZE 20
#define CELL_HEIGHT 58 // change CONTACTS_TABLE_VIEW_CELL_HEIGHT in ShareViewController.m if this changes

@implementation ContactTableViewCell


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:.89 green:.39 blue:.39 alpha:1.0];
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CELL_HEIGHT);
        
        self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont fontWithName:FONT_STRING size:FONT_SIZE];
        [self addSubview:self.nameLabel];
        
        int widthAndHeight = self.bounds.size.height/1.2;
        self.imageViewForImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, (CELL_HEIGHT - widthAndHeight) / 2.0 , widthAndHeight, widthAndHeight)];
        self.imageViewForImage.backgroundColor = [UIColor whiteColor];
        self.imageViewForImage.layer.cornerRadius = self.imageViewForImage.bounds.size.height / 2.0;
        self.imageViewForImage.layer.masksToBounds = YES;
        self.imageViewForImage.layer.borderWidth = 0;
        [self addSubview:self.imageViewForImage];
        
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code

}

- (void) setName:(NSString *)name
{
    _name = name;
    self.nameLabel.text = _name;
}

- (void) setImage:(UIImage *)image
{
    _image = image;
    self.imageViewForImage.image = image;
}

- (void) setPhoneNumbersArray:(NSArray *)phoneNumbersArray
{
    _phoneNumbersArray = phoneNumbersArray;
}

- (void) setPhoneNumbersTypeArray:(NSArray *)phoneNumbersTypeArray
{
    _phoneNumbersTypeArray = phoneNumbersTypeArray;
}

- (NSArray *) getPhoneNumbersArray
{
    return _phoneNumbersArray;
}

- (NSArray *) getPhoneNumbersTypeArray
{
    return _phoneNumbersTypeArray;
}




- (void) setEmailsArray:(NSArray *)emailsArray
{
    _emailsArray = emailsArray;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
