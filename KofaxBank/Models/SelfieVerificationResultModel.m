//
//  SelfieValidationResultModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 2/13/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "SelfieVerificationResultModel.h"
#import "SelfieDocumentTestsModel.h"
#import "DocumentRiskVectorAnalysisModel.h"
#import "ModelUtilities.h"

#define RETURNED_DOCUMENT_FIELDS_LOCAL @"ReturnedDocumentFields"
#define ROOTKEY_D_LOCAL @"d"
#define ID_LOCAL @"Id"
#define VALUE_LOCAL @"Value"
#define JOB_IDENTITY_LOCAL @"JobIdentity"
#define DOCUMENT_ID_LOCAL @"DocumentId"
#define FR_MATCH_SCORE_LOCAL @"FRMatchScore"
#define FR_MATCH_RESULT_LOCAL @"FRMatchResult"
#define FR_TRANSACTION_ID_LOCAL @"FRTransactionID"
#define VERIFICATION_PHOTO64_LOCAL @"VerificationPhoto64"
#define FR_RESERVED_LOCAL @"FRReserved"
#define LOW_FR_THRESHOLD_LOCAL @"LowFRThreshold"
#define MEDIUM_FR_THRESHOLD_LOCAL @"MediumFRThreshold"
#define HIGH_FR_THRESHOLD_LOCAL @"HighFRThreshold"
#define ERROR_MESSAGE_LOCAL @"ErrorMessage"
#define FR_ERROR_INFO_LOCAL @"FRErrorInfo"
#define SELFIE_TESTS_LOCAL @"SelfieTests"
#define DOCUMENT_IMAGE_ANALYSIS_LOCAL @"DocumentImageAnalysis"
#define DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL @"DocumentRiskVectorAnalysis"

@interface SelfieVerificationResultModel ()


@property(nonatomic)NSMutableArray *documentTests,*documentRisks;
@end

@implementation SelfieVerificationResultModel

-(id)initWithDictionary: (NSDictionary *)dictInfo andHeadShot:(NSString*)headShotBase64{
    if(self = [super init])
    {
        _headShotBase64ImageString = headShotBase64;
        [self prepareModels:dictInfo];
        
        
    }
    return self;
}


-(void)prepareModels:(NSDictionary*)resultDictionary{
    
    NSMutableArray *selfieResultsArray = [[[[resultDictionary valueForKey:ROOTKEY_D_LOCAL]valueForKey:RETURNED_DOCUMENT_FIELDS_LOCAL] firstObject] valueForKey:RETURNED_DOCUMENT_FIELDS_LOCAL];
    
    _jobIdentity = [[[[resultDictionary valueForKey:ROOTKEY_D_LOCAL] valueForKey:JOB_IDENTITY_LOCAL] valueForKey:ID_LOCAL] isKindOfClass:[NSNull class]]?nil:[[[resultDictionary valueForKey:ROOTKEY_D_LOCAL] valueForKey:JOB_IDENTITY_LOCAL] valueForKey:ID_LOCAL];
    
    _documentID = [[[resultDictionary valueForKey:ROOTKEY_D_LOCAL] valueForKey:DOCUMENT_ID_LOCAL] isKindOfClass:[NSNull class]]?nil:[[resultDictionary valueForKey:ROOTKEY_D_LOCAL] valueForKey:DOCUMENT_ID_LOCAL];
    
    if(selfieResultsArray.count > 0){
        
        _transactionID = [[[self extractionInfoForKey:FR_TRANSACTION_ID_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:FR_TRANSACTION_ID_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL];
        
        _selfieMatchResult = [[[self extractionInfoForKey:FR_MATCH_RESULT_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:FR_MATCH_RESULT_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL];
        
        
        _selfieMatchScore = [[[self extractionInfoForKey:FR_MATCH_SCORE_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:FR_MATCH_SCORE_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL];
        
        
        // Need to parse the String response for Error Info
        
        NSString *errorInfoText = [[[self extractionInfoForKey:FR_ERROR_INFO_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:FR_ERROR_INFO_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL];
        
        if(errorInfoText.length > 0){
            NSData *objectData = [errorInfoText dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *errorInfoDictionary = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:nil];
            if([errorInfoDictionary isKindOfClass:[NSDictionary class]]){
                _errorInfo = [[errorInfoDictionary valueForKey:ERROR_MESSAGE_LOCAL] isKindOfClass:[NSNull class]]?nil:[errorInfoDictionary valueForKey:ERROR_MESSAGE_LOCAL];
            }
            
        }
        
        // End of Error Response parsing
        
        
        _jsonStringForSelfieReserved = [[[self extractionInfoForKey:FR_RESERVED_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:FR_RESERVED_LOCAL withArray:selfieResultsArray] valueForKey:VALUE_LOCAL];
        if(_jsonStringForSelfieReserved.length > 0){
            NSData *objectData = [_jsonStringForSelfieReserved dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *returnedOutput = [NSJSONSerialization JSONObjectWithData:objectData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:nil];
            if([returnedOutput isKindOfClass:[NSDictionary class]]){
                [self fetchAllThresholds:returnedOutput];
                [self prepareDocumentTest:returnedOutput];
                [self prepareImageAnalysis:returnedOutput];
                [self prepareRiskVectorAnalysis:returnedOutput];
                
            }
        }
        /* for (NSDictionary *resposeEntity in selfieResultsArray){
         
         if([[resposeEntity valueForKey:@"Name"] isEqualToString:@"SelfieResponse"]){
         if([[resposeEntity valueForKey:@"Value"] isKindOfClass:[NSNull class]]){
         break;
         }
         else{
         NSString *valueString = [resposeEntity valueForKey:@"Value"];
         
         NSData *objectData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *returnedOutput = [NSJSONSerialization JSONObjectWithData:objectData
         options:NSJSONReadingMutableContainers
         error:nil];
         
         if([returnedOutput valueForKey:@"TransactionId"]){
         _transactionID = [[returnedOutput valueForKey:@"TransactionId"] isKindOfClass:[NSNull class]]?@"":[returnedOutput valueForKey:@"TransactionId"];
         }
         else{
         _transactionID = @"";
         }
         
         if([returnedOutput valueForKey:@"MatchResult"]){
         _selfieMatchResult = [[returnedOutput valueForKey:@"MatchResult"] isKindOfClass:[NSNull class]]?@"":[returnedOutput valueForKey:@"MatchResult"];
         }
         else{
         _selfieMatchResult = @"";
         }
         
         if([returnedOutput valueForKey:@"ErrorInfo"]){
         _errorInfo = [[returnedOutput valueForKey:@"ErrorInfo"] isKindOfClass:[NSNull class]]?@"":[[returnedOutput valueForKey:@"ErrorInfo"] valueForKey:@"ErrorMessage"];
         }
         else{
         _errorInfo = @"";
         }
         
         if([returnedOutput valueForKey:@"Description"]){
         _selfieDescription = [[returnedOutput valueForKey:@"Description"] isKindOfClass:[NSNull class]]?@"":[returnedOutput valueForKey:@"Description"];
         }
         else{
         _selfieDescription = @"";
         }
         
         if([returnedOutput valueForKey:@"MatchScore"]){
         
         _selfieMatchScore = returnedOutput[@"MatchScore"];
         }
         else{
         _selfieMatchScore = @"";
         }
         if([returnedOutput valueForKey:@"Threshold"]){
         
         _selfieThreshold = returnedOutput[@"Threshold"];
         }
         else{
         _selfieThreshold = @"";
         }
         
         [self prepareDocumentTest:returnedOutput];
         [self prepareImageAnalysis:returnedOutput];
         [self prepareRiskVectorAnalysis:returnedOutput];
         
         
         }
         
         }
         
         
         }*/
        
        
    }
    
}

-(void)fetchAllThresholds:(NSDictionary*)returnedOutput{
    if([[returnedOutput allKeys] containsObject:LOW_FR_THRESHOLD_LOCAL]){
        _selfieLowThreshold = [ModelUtilities getStringForKey:LOW_FR_THRESHOLD_LOCAL withDictionary:returnedOutput];
    }
    
    if([[returnedOutput allKeys] containsObject:MEDIUM_FR_THRESHOLD_LOCAL]){
        _selfieMediumThreshold = [ModelUtilities getStringForKey:MEDIUM_FR_THRESHOLD_LOCAL withDictionary:returnedOutput];
    }
    
    if([[returnedOutput allKeys] containsObject:HIGH_FR_THRESHOLD_LOCAL]){
        _selfieHighThreshold = [ModelUtilities getStringForKey:HIGH_FR_THRESHOLD_LOCAL withDictionary:returnedOutput];
    }
}

-(void)prepareDocumentTest:(NSDictionary *)returnedOutput {
    
    if([[returnedOutput allKeys] containsObject:SELFIE_TESTS_LOCAL]){ // For others its DocumentTests.
        
        NSDictionary *json = [[returnedOutput valueForKey:SELFIE_TESTS_LOCAL] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:SELFIE_TESTS_LOCAL];
        
        
        if(![json isKindOfClass:[NSNull class]] && [json isKindOfClass:[NSDictionary class]]){
            _documentTests = [[NSMutableArray alloc]init];
            
            NSArray *arrKeys = json.allKeys;
            
            for (int i =0 ; i<arrKeys.count ; i++){
                
                SelfieDocumentTestsModel *documentTestModel = [[SelfieDocumentTestsModel alloc]initWithDictionary:json withTestName:arrKeys[i]];
                // if(documentTestModel.frontOriginality)
                [_documentTests addObject:documentTestModel];
                
            }
        }
        else{
            _documentTests = nil;
        }
        
    }
    
}

-(void)prepareImageAnalysis:(NSDictionary*)returnedOutput{
    if([[returnedOutput allKeys] containsObject:DOCUMENT_IMAGE_ANALYSIS_LOCAL]){
        
        NSDictionary *json = [[returnedOutput valueForKey:DOCUMENT_IMAGE_ANALYSIS_LOCAL] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:DOCUMENT_IMAGE_ANALYSIS_LOCAL];
        
        
        if(![json isKindOfClass:[NSNull class]] && [json isKindOfClass:[NSDictionary class]]){
            _selfieImageAnalysisModel = [[ImageOriginalityValuesModel alloc] initWithDictionary:json];
        }
        else{
            _selfieImageAnalysisModel = nil;
        }
        
    }
    
    
}

-(void)prepareRiskVectorAnalysis:(NSDictionary*)returnedOutput{
    
    /*  if  ([[returnedOutput allKeys] containsObject:@"DocumentRiskVectorAnalysis"]){
     NSArray *contents = [[returnedOutput valueForKey:@"DocumentRiskVectorAnalysis"] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:@"DocumentRiskVectorAnalysis"];
     
     _documentRisks = [[NSMutableArray alloc]init];
     
     
     for (int i =0 ; i<contents.count ; i++){
     
     DocumentRiskVectorAnalysisModel *documentRiskVectorAnalysisModel = [[DocumentRiskVectorAnalysisModel alloc] initWithDictionary:contents[i]];
     [_documentRisks addObject:documentRiskVectorAnalysisModel];
     
     }
     
     }*/
    if([[returnedOutput allKeys] containsObject:DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL]){
        NSDictionary *json = [[returnedOutput valueForKey:DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL];
        if([json isKindOfClass:[NSDictionary class]] && [json isKindOfClass:[NSDictionary class]]){
            
            _documentRisks = [[NSMutableArray alloc]init];
            
            NSArray *arrKeys = json.allKeys;
            
            for (int i =0 ; i<arrKeys.count ; i++){
                
                DocumentRiskVectorAnalysisModel *documenRiskVectorModel = [[DocumentRiskVectorAnalysisModel alloc] initWithSelfieRiskAnalysisDictionary:json withName:arrKeys[i]];
                //if(documenRiskVectorModel.frontOriginality)
                [_documentRisks addObject:documenRiskVectorModel];
                
            }
            
            
        }
    }
    
}


-(NSDictionary *)extractionInfoForKey:(NSString *)key withArray:(NSArray *)array
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Name = %@",key];
    NSArray *tempArray = [array filteredArrayUsingPredicate:predicate];
    if (tempArray.count) {
        return tempArray[0];
    }
    return nil;
}


@end
