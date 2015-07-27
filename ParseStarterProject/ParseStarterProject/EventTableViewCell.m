//
//  EventTableViewCell.m
//  Flyr1
//
//  Created by Rachel Pinsker on 12/24/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import "EventTableViewCell.h"
#import "EventViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

#define TITLE_LABEL_HEIGHT 30
#define HEIGHT_EDGE_INSET 23
#define CAPTION_TEXT_VIEW_HEIGHT 100 // if you change this, change height of options table view height in shareViewController
#define FONT_STRING @"AvenirNext-Medium"
#define FONT_CAPTION_STRING_SIZE 15
#define FONT_TITLE_STRING_SIZE 20



@interface EventTableViewCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *eventTitleLabel;
@property (nonatomic, strong) UIImageView *eventImageView;
@property (nonatomic, strong) UITextView *eventCaptionTextView;
@property (nonatomic, strong) UIScrollView *sv;
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation EventTableViewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        // image view set up
        self.eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        //self.eventImageView.layer.borderWidth = 10.0;
        //self.eventImageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        //[self addSubview:self.eventImageView];
        
        self.sv = [[UIScrollView alloc] init];
        self.sv.scrollEnabled = YES;
        self.sv.backgroundColor = [UIColor redColor];
        self.sv.bounces = NO;
        self.sv.delegate = self;
        self.sv.userInteractionEnabled = NO;
        [self addSubview:self.sv];
        [self.sv addSubview:self.eventImageView];
        
        // title label set up
        self.eventTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - CAPTION_TEXT_VIEW_HEIGHT - TITLE_LABEL_HEIGHT, self.frame.size.width, TITLE_LABEL_HEIGHT)];
        self.eventTitleLabel.backgroundColor = [UIColor colorWithRed:.89 green:.39 blue:.39 alpha:.8];
        self.eventTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.eventTitleLabel.textColor = [UIColor whiteColor];
        self.eventTitleLabel.font = [UIFont fontWithName:FONT_STRING size:FONT_TITLE_STRING_SIZE];
        [self addSubview:self.eventTitleLabel];
        
        // caption text view set up
        self.eventCaptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - CAPTION_TEXT_VIEW_HEIGHT, self.frame.size.width, CAPTION_TEXT_VIEW_HEIGHT)];
        self.eventCaptionTextView.backgroundColor = [UIColor colorWithRed:.89 green:.39 blue:.39 alpha:.8];
        self.eventCaptionTextView.textColor = [UIColor whiteColor];
        self.eventCaptionTextView.userInteractionEnabled = NO;
        self.eventCaptionTextView.font = [UIFont fontWithName:FONT_STRING size:FONT_CAPTION_STRING_SIZE];
        [self addSubview:self.eventCaptionTextView];
        
        self.motionManager = [[CMMotionManager alloc] init];
        
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
    [self.eventImageView setFrame:CGRectMake(0, 0, image.size.width, self.frame.size.height)];
    self.eventImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect imageViewFrame = AVMakeRectWithAspectRatioInsideRect(image.size, self.eventImageView.frame);
    [self.eventImageView setFrame:CGRectMake(0, 0, imageViewFrame.size.width, imageViewFrame.size.height)];
    
    self.sv.contentSize = imageViewFrame.size;
    self.sv.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.sv.contentOffset = CGPointMake(self.eventImageView.frame.size.width / 2.0, 0);
    
    //Gyroscope
    if([self.motionManager isGyroAvailable])
    {
        /* Start the gyroscope if it is not active already */
        if([self.motionManager isGyroActive] == NO)
        {
            /* Update us 2 times a second */
            [self.motionManager setGyroUpdateInterval:1.0f / 60.0f];
            
            /* Add on a handler block object */
            CGFloat motionMovingRate = 8;
            
            //get the max and min offset x value
            int maxXOffset = self.sv.contentSize.width - self.sv.frame.size.width;
            int minXOffset = 0;
            /* Receive the gyroscope data on this block */
            [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMGyroData *gyroData, NSError *error)
             {
                 if (fabs(gyroData.rotationRate.y) >= 0.1) {
                     CGFloat targetX = self.sv.contentOffset.x - gyroData.rotationRate.y * motionMovingRate;
                     //check if the target x is less than min or larger than max
                     //if do, use min or max
                     if(targetX > maxXOffset)
                         targetX = maxXOffset;
                     else if (targetX < minXOffset)
                         targetX = minXOffset;
                     
                     //set up the content off
                     self.sv.contentOffset = CGPointMake(targetX, 0);
                 }
             }];
        }
    }
    else
    {
        NSLog(@"Gyroscope not Available!");
    }
    
    // 1. scaleAspectFill
    // 2. nothing
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
