//
//  main.m
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ParseStarterProjectAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ParseStarterProjectAppDelegate class]));
    }
}

//FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//                              initWithGraphPath:@"/me/friends"
//                              parameters:params
//                              HTTPMethod:@"GET"];
//[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
//                                      id result,
//                                      NSError *error) {
//    // Handle the result
//}];