//
//  SelfieValidationResultModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 2/13/17.
//  Copyright © 2017 Kofax. All rights reserved.
//
#import "ImageOriginalityValuesModel.h"

@interface SelfieVerificationResultModel : NSObject
{
    
}

@property(nonatomic,readonly)  NSString *selfieMatchScore;
@property(nonatomic,readonly)  NSString *jobIdentity; //
@property(nonatomic,readonly)  NSString *transactionID;
@property(nonatomic,readonly)  NSString *selfieMatchResult;
@property(nonatomic,readonly)  NSString *selfieDescription;
@property(nonatomic,readonly)  NSString  *selfieLowThreshold,*selfieMediumThreshold,*selfieHighThreshold;
@property(nonatomic,readonly) NSString *documentID;
@property(nonatomic,readonly) NSString *jsonStringForSelfieReserved;
@property(nonatomic,readonly)  NSInteger statusCode;
@property(nonatomic,readonly)  NSString *errorInfo; //
@property (nonatomic,readonly) NSString *headShotBase64ImageString;
@property (nonatomic , readonly) NSArray *documentTests;
@property(nonatomic,readonly) NSArray *documentRisks;
@property(nonatomic,readonly) ImageOriginalityValuesModel *selfieImageAnalysisModel;
//..-(id)initWithDictionary: (NSDictionary *)dictInfo;
-(id)initWithDictionary: (NSDictionary *)dictInfo andHeadShot:(NSString*)headShotBase64;
@end
