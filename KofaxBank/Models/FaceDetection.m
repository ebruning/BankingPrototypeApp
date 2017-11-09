//
//  FaceDetection.m
//  selfie
//
//  Created by Kofax on 13/12/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "FaceDetection.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>



#pragma mark-

@interface FaceDetection () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    BOOL isUserClosedEyes;   //These bool values used for blink detection.
    BOOL isUserOpenedEyes;
    BOOL isCaptureingStilImage;
}

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIImage* lastStillImage;

@end

static dispatch_queue_t cameraOpQueue;
static dispatch_once_t cameraInitAction;

@implementation FaceDetection

- (void)setupAVCapture
{
    
    dispatch_once(&cameraInitAction, ^{
        cameraOpQueue = dispatch_queue_create("kfxKUIImageCaptureOpQueue", NULL);
    });
    
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //in real app you would use camera that user chose
    if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if ([d position] == AVCaptureDevicePositionFront)
                device = d;
        }
    }
    else
        exit(0);
    
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(error != nil)
    {
        exit(0);
    }
    
    if ([self.session canAddInput:deviceInput])
        [self.session addInput:deviceInput];
    
    // Make a video data output
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA)};
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    if ( [self.session canAddOutput:self.videoDataOutput] )
        [self.session addOutput:self.videoDataOutput];
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [self.previewView layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
    
    [self setupImageCapture];
    [self.session startRunning];
}

-(void)setupImageCapture
{
       
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary* outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [self.session addOutput:self.stillImageOutput];
}


-(void) captureStillImage
{
    if (self.stillImageOutput == nil) {
        return;
    }
 
    isCaptureingStilImage = YES;
    AVCaptureConnection* videoConnection = nil;
    for (AVCaptureConnection* connection in [self.stillImageOutput connections]) {
        for (AVCaptureInputPort* port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    __weak FaceDetection * wself = self;
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError* error) {
        
        [wself captureStillImageOutput:imageSampleBuffer error:error];
    }];
}


- (void)captureStillImageOutput:(CMSampleBufferRef)sampleBuffer error:(NSError*)error
{
    @autoreleasepool {
        if (sampleBuffer == nil) {
            return;
        }
        
        NSData* imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        UIImage* img = [[UIImage alloc] initWithData:imageData];
        imageData = nil;
        
        UIImage* newImage = img;
        img = nil;
        
        self.lastStillImage = [FaceDetection rotate:newImage];
        newImage = nil;
        
        [self performSelectorOnMainThread:@selector(processStillImage) withObject:nil waitUntilDone:NO];
    }
}

-(void)processStillImage
{
    isCaptureingStilImage = NO;
    
    NSLog(@"self.delegate:%@", self.delegate);
    if (self.delegate && [self.delegate respondsToSelector:@selector(capturedStillImage:)]) {
        [self.delegate capturedStillImage:self.lastStillImage];
    }
}

+ (UIImage*) rotate:(UIImage*)image
{
    return [[UIImage alloc] initWithCGImage:image.CGImage
                                      scale:1.0
                                orientation:[FaceDetection getImageOrientation]];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (isCaptureingStilImage)
    {
        return;
    }
    // got an image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    if (attachments)
        CFRelease(attachments);
    
    
    
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    
    int exifOrientation = 6; //   6  =  0th row is on the right, and 0th column is the top.
    
    
    
    NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation),
                                   CIDetectorEyeBlink : @YES,
                                   CIDetectorAccuracy : CIDetectorAccuracyHigh};
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage options:imageOptions];
    
    for (CIFaceFeature *ff in features) {
        // find the correct position for the square layer within the previewLayer
        // the feature box originates in the bottom left of the video frame.
        // (Bottom right if mirroring is turned on)
        
        
        //Checking whether user is closed eyes or not.
        
        BOOL areEyesClosed = (ff.leftEyeClosed && ff.rightEyeClosed);
        if (areEyesClosed) {
            isUserClosedEyes = YES;
        }
        
        //Checking whether user is opened eyes or not after closing the eyes then only will take a picture.
        
        BOOL areOpened = (ff.leftEyeClosed == NO && ff.rightEyeClosed == NO);
        if(isUserClosedEyes && (areOpened)) {
            isUserOpenedEyes = YES;
        }
        
        if (isUserClosedEyes && isUserOpenedEyes) {
            
            //Resetting bool values only user blinked the eyes.
            
            isUserOpenedEyes = NO;
            isUserClosedEyes = NO;
            
            [self captureStillImage];

        }
    }

}

- (void)startDetection
{
    [self setupAVCapture];
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    NSDictionary *detectorOptions = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
}

- (void)stopDetection
{
    [self.videoDataOutput setSampleBufferDelegate:nil queue:nil];
    [self.session stopRunning];
    
    self.session = nil;
    self.videoDataOutput = nil;
    self.previewLayer = nil;
    self.videoDataOutputQueue = nil;
}



- (UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer orientation:(UIImageOrientation)orientation
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height,
                                                 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage* image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:orientation];
    CGImageRelease(quartzImage);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}


+ (UIImageOrientation) getImageOrientation
{
    UIInterfaceOrientation devOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIImageOrientation imgOrientation = UIImageOrientationUp;
    
    switch (devOrientation) {
        case UIInterfaceOrientationPortrait:
            imgOrientation = UIImageOrientationRight;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            imgOrientation = UIImageOrientationLeft;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            imgOrientation = UIImageOrientationDown;
            break;
        default:
            break;
    }
    
    return imgOrientation;
}

@end
