//
//  TimeMachineCameraViewController.m
//  TimeMachineCamera
//
//  Created by utan on 10/09/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimeMachineCameraViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "CaptureWrapper.h"


@implementation TimeMachineCameraViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
//	NSLog(@"%s", __FUNCTION__);
//}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];

	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,480,320)];
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0f);
	transform = CGAffineTransformTranslate(transform, 60, 80); // ?
	imageView.transform = transform;
	[self.view addSubview:imageView];
	
	CaptureWrapper *captureWrapper = [[CaptureWrapper alloc] initWithImageView:imageView];
	[captureWrapper setupCaptureSession];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
