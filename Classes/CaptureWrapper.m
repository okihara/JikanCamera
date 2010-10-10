//
//  CaptureWrapper.m
//  TimeMachineCamera
//
//  Created by okhra on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CaptureWrapper.h"


@implementation CaptureWrapper

@synthesize session=session_;
@synthesize imageView=imageView_;

-(id)initWithImageView:(UIImageView*)imageView
{
	if ( (self=[super init])) {
		self.imageView = imageView;
	}
	return self;
}

// Create and configure a capture session and start it running
- (void)setupCaptureSession 
{
    NSError *error = nil;
	
    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	
    // Configure the session to produce lower resolution video frames, if your 
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPresetMedium;
	
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
							   defaultDeviceWithMediaType:AVMediaTypeVideo];
	
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device 
																		error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [session addInput:input];
	
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [session addOutput:output];
	
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
	
    // Specify the pixel format
    output.videoSettings = 
	[NSDictionary dictionaryWithObject:
	 [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
								forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	
    // If you wish to cap the frame rate to a known value, such as 15 fps, set 
    // minFrameDuration.
    output.minFrameDuration = CMTimeMake(1, 30);
	
    // Start the session running to start the flow of data
    [session startRunning];
	
    // Assign session to an ivar.
    [self setSession:session];
}

#define MY_HEIGHT 360
#define MY_WIDTH  480
#define MAX_BUFFERS 90
#define BYTES_PER_ROW MY_WIDTH*4
#define BYTES_IMAGE BYTES_PER_ROW*MY_HEIGHT
static UInt8 buffer[MAX_BUFFERS][BYTES_IMAGE];
static UInt8 displayBuffer[BYTES_IMAGE];
static UInt8 currentBufferIndex = 0;

- (UInt8*)transImage:(UInt8*)pixels {
	unsigned int bytesPerRow = BYTES_PER_ROW;
	unsigned int height = MY_HEIGHT;
	
	memcpy(buffer[currentBufferIndex], pixels, BYTES_IMAGE);
	
	for(int i = 0; i < height; i++) {
		uint index = MAX_BUFFERS - MAX_BUFFERS * i / height;
		
		uint offset = bytesPerRow * i;
		char *srcAddress = (char*)buffer[(currentBufferIndex + index) % MAX_BUFFERS];
		
		memcpy(displayBuffer + offset, srcAddress + offset, bytesPerRow);
	}
	
	currentBufferIndex = (currentBufferIndex + 1) % MAX_BUFFERS;
	
	return displayBuffer;
}

- (UInt8*)transImage2:(UInt8*)pixels {
	unsigned int bytesPerRow = BYTES_PER_ROW;
	unsigned int height = MY_HEIGHT;
	
	memcpy(buffer[currentBufferIndex], pixels, BYTES_IMAGE);
	
	for(int i = 0; i < height; i++) {
		uint index;
		if (i < 140) {
			index = 0;
		} else if (i < 220) {
			//index = MAX_BUFFERS / 2;
			index = MAX_BUFFERS - MAX_BUFFERS *  (i -140) / 80;
		} else {
			index = 1;
		}
		
		uint offset = bytesPerRow * i;
		char *srcAddress = (char*)buffer[(currentBufferIndex + index) % MAX_BUFFERS];
		
		memcpy(displayBuffer + offset, srcAddress + offset, bytesPerRow);
	}
	
	currentBufferIndex = (currentBufferIndex + 1) % MAX_BUFFERS;
	
	return displayBuffer;
}


- (CGImageRef)transCGImage:(CGImageRef)cgImage {
	uint width = 480;
	uint height = 360;
	
	// 変換
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
	UInt8 *input = (UInt8*)CFDataGetBytePtr(data);
	UInt8 *output = [self transImage:input];
	//UInt8 *output = [self transImage2:input];
	CFRelease(data);
	
	// 
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	// Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, output, BYTES_IMAGE, 
															  NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef outImage = 
	CGImageCreate(width,
				  height,
				  8,
				  32,
				  BYTES_PER_ROW,
				  colorSpace,
				  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
				  provider,
				  NULL,
				  true,
				  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
	//
	[(id)outImage autorelease];
	
	return outImage;
}

- (CGImageRef)imageRotatedFromCGImage:(CGImageRef)imageRef {
	CGFloat targetWidth = 480;
	CGFloat targetHeight = 360;
	
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
	if (bitmapInfo == kCGImageAlphaNone) {
		bitmapInfo = kCGImageAlphaNoneSkipLast;
	}
	
	//CGContextRef bitmap = CGBitmapContextCreate(NULL, 360, 480, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
	CGContextRef bitmap = CGBitmapContextCreate(NULL, 360, 480, CGImageGetBitsPerComponent(imageRef), 4*360, colorSpaceInfo, bitmapInfo);
	
	CGContextRotateCTM (bitmap,  -M_PI/2.0);
	CGContextTranslateCTM (bitmap, -targetWidth, 0);
	CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
	
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	
	CGContextRelease(bitmap);
	[(id)ref autorelease];
	
	return ref; 
}

- (void)updateImage:(UIImage*)image {
	//CGImageRef rotatedImage = [self imageRotatedFromCGImage:image.CGImage];
	//CGImageRef outputImage = [self transCGImage:rotatedImage];
	
	CGImageRef outputImage = [self transCGImage:image.CGImage];
	
	//CGImageRef outputImage = rotatedImage;
	
	//CGImageRef outputImage = image.CGImage;
	
	[self.imageView.layer setContents:(id)outputImage];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection
{ 
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
	
	//< Add your code here that uses theimage >
	[self performSelectorOnMainThread:@selector(updateImage:) withObject:image waitUntilDone:YES];
}


// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    if (!colorSpace) 
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
	
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer); 
	
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, 
															  NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage = 
	CGImageCreate(width,
				  height,
				  8,
				  32,
				  bytesPerRow,
				  colorSpace,
				  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
				  provider,
				  NULL,
				  true,
				  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
	
    // Create and return an image object representing the specified Quartz image
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
    return image;
}

@end
