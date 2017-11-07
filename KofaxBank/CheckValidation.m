//
//  CheckValidation.m
//  KofaxBank
//
//  Created by Rupali on 18/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

#import "CheckValidation.h"

#define ADVANCEDSETTINGS @"advancedsettings"
#define USEHANDPRINT @"usehandprint"
#define CHECKFORDUPLICATES @"checkforduplicates"
#define SEARCHMICR @"searchmicr"
#define CHECKVALIDATIONSERVER @"checkvalidationatserver"
#define SHOWCHECKINFO @"showcheckinfo"
#define SHOWCHECKGUIDINGDEMO @"showcapturedemo"
#define SHOWGUIDINGDEMO @"showcapturedemo"
#define CHECKEXTRACTION @"checkextraction"
#define SHOWINSTRUCTION @"showinstruction"
#define DOCUMENTSNUMBER @"numberofdocumentstocapture"
#define SHOWINSTRUCTIONSCREEN @"showinstructionscreen"
#define FIRSTTIMELAUNCHDEMO @"isfirsttimecheckdemo" // This instance is used to track if the app is launched for the forst time . This value goes to false when the user sees the check demo for front and back atleast once or if the user manually switches off the Settings for Guiding Demo .

@interface CheckValidation()

@end


@implementation CheckValidation

 NSString *localMICR;

+ (BOOL)checkBackHasEndorsement:(NSString*)metaData{
    
    NSError *jsonError;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    CGFloat width=0, height=0;
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        
        if([[jsonDict allKeys] containsObject:@"Output Image Attributes"]){
            
            jsonDict = [jsonDict objectForKey:@"Output Image Attributes"];
            
            height = [[jsonDict objectForKey:@"Height"] floatValue];
            width = [[jsonDict objectForKey:@"Width"] floatValue];
        }
    }
    
    jsonDict = [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    CGRect signatureRect = CGRectMake(0, 0, width, height);
    CGPoint BL, BR, TL, TR;
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        
        if([[jsonDict allKeys] containsObject:@"Text Lines"]){
            
            jsonDict = [jsonDict objectForKey:@"Text Lines"];
            
            if([[jsonDict allKeys] containsObject:@"Lines"]){
                
                NSArray *tempArray = [jsonDict objectForKey:@"Lines"];
                
                for (NSDictionary *tempDict in tempArray) {
                    
                    if([[tempDict valueForKey:@"Type"] isEqualToString:@"HP"]){
                        // Signature Found
                        BL = CGPointMake([[tempDict valueForKey:@"BLx"] floatValue], [[tempDict valueForKey:@"BLy"] floatValue]);
                        BR = CGPointMake([[tempDict valueForKey:@"BRx"] floatValue], [[tempDict valueForKey:@"BRy"] floatValue]);
                        TL = CGPointMake([[tempDict valueForKey:@"TLx"] floatValue], [[tempDict valueForKey:@"TLy"] floatValue]);
                        TR = CGPointMake([[tempDict valueForKey:@"TRx"] floatValue], [[tempDict valueForKey:@"TRy"] floatValue]);
                        
                        if(CGRectContainsPoint(signatureRect, BL) && CGRectContainsPoint(signatureRect, BR)  &&
                           CGRectContainsPoint(signatureRect, TL) && CGRectContainsPoint(signatureRect, TR)) {
                            
                            // Signature Found
                            return YES;
                        }
                        else{
                            
                            //Signature not found
                            NSLog(@"Signature not found\n");
                        }
                    }
                }
                
            }
        }
    }
    
    return NO;
    
}


/*
 This method is used to check if Signature & MICR exist on the check.
 */
+ (int)verifySignatureAndMicr:(NSString*)metaData isFrontSide:(BOOL)isFront {

    NSError *jsonError;
    
    NSDictionary *jsonDict =  [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    
    CGFloat width=0, height=0, xDPI = 0, yDPI = 0;
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        
        if([[jsonDict allKeys] containsObject:@"Output Image Attributes"]){
            
            jsonDict = [jsonDict objectForKey:@"Output Image Attributes"];
            
            height = [[jsonDict objectForKey:@"Height"] floatValue];
            width = [[jsonDict objectForKey:@"Width"] floatValue];
            xDPI = [[jsonDict objectForKey:@"xDPI"] floatValue];
            yDPI = [[jsonDict objectForKey:@"yDPI"] floatValue];
            NSLog(@"---height is %f----width is %f----xdpi is %f----ydpi is %f",height,width,xDPI,yDPI);
        }
    }
    
    
    int i = 0;
    jsonDict = [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        
        if([[jsonDict allKeys] containsObject:@"Text Lines"]){
            
            jsonDict = [jsonDict objectForKey:@"Text Lines"];
            
            if([[jsonDict allKeys] containsObject:@"Lines"]){
                
                NSArray *tempArray = [jsonDict objectForKey:@"Lines"];
                
                // if tempArray does not have count means, Micr does not exist. making blank before assinging new value.
                
                localMICR = @"";
                
                for (NSDictionary *tempDict in tempArray) {
                    
                    if([[tempDict valueForKey:@"Label"] isEqualToString:@"MICR"] && [[tempDict valueForKey:@"OCR Data"] length] > 0){
                        NSString *ocrData = [tempDict valueForKey:@"OCR Data"];
                        
                        if (ocrData.length != 0) {
                            
                            i = [self checkMICR: ocrData withBLy:[[tempDict valueForKey:@"BLy"]intValue] andTLy:[[tempDict valueForKey:@"TLy"]intValue]];
                            ocrData = [[ocrData componentsSeparatedByCharactersInSet:
                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                       componentsJoinedByString:@""];
                            if (i==2) {
                                
                                if(isFront){
                                    localMICR = ocrData;
                                }
                                else{ // This covers the case where front is captured for back.
                                    return 2;
                                }
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    jsonDict = [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        if([[jsonDict allKeys] containsObject:@"Text Lines"]){
            jsonDict = [jsonDict objectForKey:@"Text Lines"];
            if([[jsonDict allKeys] containsObject:@"Lines"]){
                NSArray *tempArray = [jsonDict objectForKey:@"Lines"];
                for (NSDictionary *tempDict in tempArray) {
                    if([[tempDict valueForKey:@"Type"] isEqualToString:@"HP"]){
                        i += 1;
                        break;
                    }
                }
            }
        }
    }
    
    return i;
    
}

//Method is used to check MICR exist on the check front
+ (int)checkMICR:(NSString*)ocrData withBLy:(int)mMICRBLy andTLy:(int)mMICRTLy{
    
    int MIN_MICR_HEIGHT = 8;
    int MIN_MICR_DATA_LEN = 11;
    __block int result = 0;
    if ((mMICRBLy - mMICRTLy) >= MIN_MICR_HEIGHT) {
        if (ocrData.length >= MIN_MICR_DATA_LEN) {
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:@"C\\d{9}C"
                                          options:NSRegularExpressionCaseInsensitive
                                          error:nil];
            [regex enumerateMatchesInString:ocrData options:NSMatchingReportCompletion range:NSMakeRange(0, [ocrData length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                result = 2;
                
            }];
        }
    }
    return result;
}



// method to validate the signature on Back Check
+ (NSMutableArray*)validateSignatureOnCheckFront:(kfxKEDImage *)image isFrontSide:(BOOL)isFront {
    
    NSMutableArray *returnArr = nil;
    
    NSString *errorMessage = nil;
    NSString *errTitle = nil;
    
    int result = [self verifySignatureAndMicr:[image getImageMetaData] isFrontSide:isFront];
    //NSString *title = @"", *msg = @"Retake?";
    
    BOOL doSearchMICR = true;   //TODO: add it is configuration if required
    BOOL doUseHandPrint = true; //TODO: add it is configuration if required
    
    if(result != 3 && (doSearchMICR || doUseHandPrint)){
        
        //title = @"Signature and MICR not found";
        errorMessage = @"Unable to find both MICR and Signature. Would you like to retry?";
        
        if (result==0) {
            
            if (doUseHandPrint) {
                errTitle = @"Signature not found";
                errorMessage = @"Unable to find Signature. Would you like to retry?";
                
                
            }else if(doSearchMICR){
                errTitle = @"MICR not detected";
                errorMessage = @"Unable to find MICR. Would you like to retry?";
            }
        }
        else if(result == 1){
            if(doSearchMICR){
                errTitle = @"MICR not detected";
                errorMessage = @"Unable to find MICR. Would you like to retry?";
                
            }
        }
        else if(result == 2){
            
            if(doUseHandPrint){
                errTitle = @"Signature not found";
                errorMessage = @"Unable to find Signature. Would you like to retry?";
            }
        }
    }
//    else{

        // TODO: not checking for duplicate check in this app.
/*        if ([[advancedSettings valueForKey:CHECKFORDUPLICATES] boolValue] && [self checkMICRExistOrNot:_localMICR]) {
            
            errTitle = @"Duplicate Check";
            errorMessage = @"Would you like to retake?";
            
        }
*/
//        else{
    
    if (errTitle != nil && errorMessage != nil){
        returnArr = [[NSMutableArray alloc]initWithCapacity:2];
        [returnArr addObject:errTitle];
        [returnArr addObject:errorMessage];
    }
            //return errorMessage;
//        }
//    }
 /*
    if(![errTitle isEqualToString:@"Signature and MICR not found"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertWithTitle:title andMessage:msg andTag:3];
        });
    }
    else {
        
        if(result == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:title andMessage:msg andTag:3];
            });
            
        }
        else{
            
            return returnArr;
        }
        
    }
    */
    return returnArr;
}


@end
