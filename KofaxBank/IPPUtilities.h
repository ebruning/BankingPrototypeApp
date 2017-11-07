//
//  IPPUtilities.h
//  KofaxMobileDemo
//
//  Created by Kofax on 20/03/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum
{
    CHECKDEPOSIT,
    BILLPAY,
    IDCARD,
    CREDITCARD,
    PASSPORT,
    CUSTOM
    
} componentType;


@interface IPPUtilities : NSObject



+(NSString *)getEVRSImagePerfectionStringFromSettings:(NSDictionary*)evrsSettings ofComponentType:(componentType)componentType isFront:(BOOL)isFront withScaleSize: (CGSize ) scaleSize withFrontImageWidth:(NSString *)strFrontWidth isODEActive:(BOOL)isODEActive;

@end
