//
//  EventTableViewCell.h
//  Flyr1
//
//  Created by Rachel Pinsker on 12/24/14.
//  Copyright (c) 2014 ___rpinsker___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell

//@property (nonatomic, strong) EVENT; TODO: set the actual event

//TODO: get rid of this stuff. Eventually, will just have the event and parsing of the event can be done in the table view cell .m class
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;

@property (nonatomic) NSInteger navBarHeight;

@end
