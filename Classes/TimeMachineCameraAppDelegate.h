//
//  TimeMachineCameraAppDelegate.h
//  TimeMachineCamera
//
//  Created by utan on 10/09/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeMachineCameraViewController;

@interface TimeMachineCameraAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TimeMachineCameraViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TimeMachineCameraViewController *viewController;

@end

