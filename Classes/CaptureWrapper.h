//
//  CaptureWrapper.h
//  TimeMachineCamera
//
//  Created by okhra on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CaptureWrapper : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession *session_;
	UIImageView *imageView_;
}

@property (retain) AVCaptureSession *session;
@property (retain) UIImageView *imageView;

- (id)initWithImageView:(UIImageView*)imageView;
- (void)setupCaptureSession;
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end
