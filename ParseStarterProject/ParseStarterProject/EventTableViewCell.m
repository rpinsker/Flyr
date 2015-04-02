//
//  EventTableViewCell.m
//  Flyr1
//
//  Created by Rachel Pinsker on 12/24/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import "EventTableViewCell.h"
#import "EventViewController.h"
#define TITLE_LABEL_HEIGHT 30
#define HEIGHT_EDGE_INSET 23
#define CAPTION_TEXT_VIEW_HEIGHT 200 // if you change this, change height of options table view height in shareViewController


@interface EventTableViewCell ()

@property (nonatomic, strong) UILabel *eventTitleLabel;
@property (nonatomic, strong) UIImageView *eventImageView;
@property (nonatomic, strong) UITextView *eventCaptionTextView;

@end

@implementation EventTableViewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        // image view set up
        self.eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.eventImageView.layer.borderWidth = 10.0;
        self.eventImageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        [self addSubview:self.eventImageView];
        
        // title label set up
        self.eventTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - CAPTION_TEXT_VIEW_HEIGHT - TITLE_LABEL_HEIGHT, self.frame.size.width, TITLE_LABEL_HEIGHT)];
        self.eventTitleLabel.backgroundColor = [UIColor colorWithWhite:.2 alpha:.7];
        self.eventTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.eventTitleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.eventTitleLabel];
        
        // caption text view set up
        self.eventCaptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - CAPTION_TEXT_VIEW_HEIGHT, self.frame.size.width, CAPTION_TEXT_VIEW_HEIGHT)];
        self.eventCaptionTextView.backgroundColor = [UIColor colorWithWhite:.2 alpha:.7];
        self.eventCaptionTextView.textColor = [UIColor whiteColor];
        self.eventCaptionTextView.userInteractionEnabled = NO;
        [self addSubview:self.eventCaptionTextView];
        
//        // gesture recognizers set up
//        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
//                                                                                        action:@selector(showDetailView)];
//        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//        [self.view addGestureRecognizer:swipeLeft];
//        
//        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
//                                                                                         action:@selector(showShareView)];
//        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//        [self.view addGestureRecognizer:swipeRight];
        
    }
    return self;
}

- (void) setTitle:(NSString *)title
{
    _title = title;
    self.eventTitleLabel.text = self.title;
}

- (void) setImage:(UIImage *)image
{
    _image = image;
    self.eventImageView.image = image;
}

- (void) setCaption:(NSString *)caption
{
    _caption = caption;
    self.eventCaptionTextView.text = caption;
}

- (void)awakeFromNib {
    // title label

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
