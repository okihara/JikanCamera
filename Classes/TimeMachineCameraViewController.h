//
//  TimeMachineCameraViewController.h
//  TimeMachineCamera
//
//  Created by utan on 10/09/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MyView : UIView {
	UIImage *image;
}

@property (retain) UIImage *image;

- (void)drawRect:(CGRect)rect;

@end

@interface TimeMachineCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate> {
	UIImageView *imageView;
	MyView *myview;
}

- (void)setupCaptureSession;
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end
