//
//  IPPUtilities.m
//  KofaxMobileDemo
//
//  Created by Kofax on 20/03/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "IPPUtilities.h"
#import "IPPConstants.h"
#import "CDIPPUtilities.h"
//#import "DLIPPUtilities.h"
//#import "BPIPPUtilities.h"

@implementation IPPUtilities

+ (NSString *)getEVRSImagePerfectionStringFromSettings:(NSDictionary*)evrsSettings ofComponentType:(componentType)componentType isFront:(BOOL)isFront withScaleSize: (CGSize ) scaleSize withFrontImageWidth:(NSString *)strFrontWidth isODEActive:(BOOL)isODEActive
{
    //if([[evrsSettings valueForKey:USEBANKRIGHTSETTINGS] boolValue]) //Use defalut bank right settings
    //{
        return [IPPUtilities getDefaultOperationString:componentType isFront:isFront strFrontWidth:strFrontWidth scaleSize:scaleSize evrsSettings:evrsSettings isODEActive:(BOOL)isODEActive];
//    }
//    else { //User not select the default bank right profile option
     
//    }
}


+(NSString*)getDefaultOperationString:(componentType)componentType isFront:(BOOL)isFront strFrontWidth:(NSString*)strFrontWidth scaleSize:(CGSize)scaleSize evrsSettings:(NSDictionary*)evrsSettings isODEActive:(BOOL)isODEActive{
    
    NSString *defaultOperationString = @"";
    
    switch (componentType) {
        case BILLPAY:
            defaultOperationString = default_BillPay_IPPString;
            break;
        case CHECKDEPOSIT:
            defaultOperationString = [CDIPPUtilities getDefaultIPPString:isFront withstrFrontWidth:strFrontWidth];
            break;
/*        case IDCARD:
            defaultOperationString = [DLIPPUtilities getDefaultIPPStringWithscaleSize:scaleSize idType:idType evrsSettings:evrsSettings withRegion:(DLRegionAttributes*)dlRegion isODEActive:(BOOL)isODEActive];
            break;
*/
        case CREDITCARD:
            defaultOperationString = default_CreditCard_IPPString;
            break;
        case CUSTOM:
            defaultOperationString = default_CustomComponent_IPPString;
            break;
        case PASSPORT:
            defaultOperationString = default_Passport_IPPString;
            break;

        default:
            break;
    }
    return defaultOperationString;
}

@end
