//
//  CDIPPUtilities.m
//  KofaxMobileDemo
//
//  Created by Kofax on 20/03/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "CDIPPUtilities.h"
#import "IPPConstants.h"

@implementation CDIPPUtilities

+ (NSString*)getDefaultIPPString:(BOOL)isFront withstrFrontWidth:(NSString*)strFrontWidth
{
    NSString *defaultOperationString = @"";
    
    if(isFront){ //check front
        
        defaultOperationString = default_CheckDepositFront_IPPString;
    }
    else{ // check back
        
        defaultOperationString = [defaultOperationString stringByAppendingString:@"_DeviceType_2__DoSkewCorrectionPage__DoCropCorrection__DoScaleImageToDPI_200__Do90DegreeRotation_9__DoFindTextHP__DoBinarization__ProcessCheckBack_"];
        
        if (strFrontWidth.length>0) {
            defaultOperationString = [defaultOperationString stringByAppendingString:[NSString stringWithFormat:@"_DocDimLarge_%@",strFrontWidth]];
        }
        defaultOperationString = [defaultOperationString stringByAppendingString:default_CheckDepositLoadLine];
    }
    return defaultOperationString;
    
}


@end
