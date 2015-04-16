//
//  ErrorHandlingController.h
//  Flyr
//
//  Created by Rachel Pinsker on 4/16/15.
//
//

#import <Foundation/Foundation.h>

@interface ErrorHandlingController : NSObject

+ (void)handleParseError:(NSError *)error;

@end