//
//  AuthenticationResultModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 2/8/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "AuthenticationReasonsModel.h"
#import "DocumentImageAnalysisModel.h"
#import "DocumentRiskVectorAnalysisModel.h"
#import "AuthenticationDocumentClassificationModel.h"
@interface AuthenticationResultModel : NSObject
{
    
}
@property(nonatomic,readonly) NSString *jobIdentity;
@property(nonatomic,readonly) NSString *authenticationResult; // Passed , Failed
@property(nonatomic,readonly) NSString *transactionID;
@property(nonatomic,readonly) NSString *errorInfo;
@property(nonatomic,readonly) NSString *documentID;
@property(nonatomic,readonly) NSString *jsonStringForAuthenticationReserved;
@property (nonatomic,readonly) NSString *headShotBase64ImageString;
@property(nonatomic,readonly) AuthenticationReasonsModel *authenticationReasons;
@property(nonatomic) NSMutableArray *documentTests;
// Receives and creates drill down sub models . Properties to be read only
@property(nonatomic,readonly) DocumentImageAnalysisModel *documentImageAnalysisModel;
@property(nonatomic,readonly) AuthenticationDocumentClassificationModel *documentClassificationModel;
@property(nonatomic) NSMutableArray *documentRisks;
-(id)initWithDictionary: (NSDictionary *)dictInfo;


@end
