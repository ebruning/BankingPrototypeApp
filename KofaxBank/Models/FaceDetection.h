//
//  FaceDetection.h
//  selfie
//
//  Created by Kofax on 13/12/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FaceDetectionDelegate <NSObject>

@required

- (void)capturedStillImage:(UIImage*)capturedImage;

@end

@interface FaceDetection : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UIView *previewView;

- (void)startDetection;
- (void)stopDetection;
- (void)captureStillImage;

@end
