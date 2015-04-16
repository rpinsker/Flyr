//
//  ShareViewController.h
//  Flyr1
//
//  Created by Rachel Pinsker on 12/22/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ShareViewController : UIViewController

@property (strong, nonatomic) UIViewController *eventVC;
@property (nonatomic) BOOL isLogout;

@property (strong, nonatomic) PFObject *event;
@property (strong, nonatomic) UIImage *eventImage;

@end
