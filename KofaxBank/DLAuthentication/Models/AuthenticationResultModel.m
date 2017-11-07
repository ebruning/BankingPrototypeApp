//
//  AuthenticationResultModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 2/8/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "AuthenticationResultModel.h"
#import "DocumentTestsModel.h"

#define RETURNED_DOCUMENT_FIELDS_LOCAL @"ReturnedDocumentFields"
#define ROOTKEY_D_LOCAL @"d"
#define JOB_IDENTITY_LOCAL @"JobIdentity"
#define DOCUMENT_ID_LOCAL @"DocumentId"
#define VERIFICATION_RESULT_LOCAL @"VerificationResult"
#define VERIFICATION_TRANSACTION_ID_LOCAL @"VerificationTransactionID"
#define VERIFICATION_PHOTO64_LOCAL @"VerificationPhoto64"
#define VERIFICATION_RESERVED_LOCAL @"VerificationReserved"
#define VERIFICATION_ERROR_INFO_LOCAL @"VerificationErrorInfo"
#define ID_LOCAL @"Id"
#define VALUE_LOCAL @"Value"
#define ERROR_MESSAGE_LOCAL @"ErrorMessage"
#define DOCUMENT_INFO_LOCAL @"DocumentInfo"
#define DOCUMENT_ALERTS_LOCAL @"DocumentAlerts"
#define DOCUMENT_TESTS_LOCAL @"DocumentTests"
#define DOCUMENT_IMAGE_ANALYSIS_LOCAL @"DocumentImageAnalysis"
#define DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL @"DocumentRiskVectorAnalysis"
#define DOCUMENT_CLASSISFICATION_LOCAL @"DocumentClassification"

@interface AuthenticationResultModel ()




@end


@implementation AuthenticationResultModel


-(id)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
    
}


/*-(void)prepareModels:(NSDictionary*)resultDictionary{
  NSArray *authenticationResultsArray = [[resultDictionary valueForKey:@"d"]valueForKey:@"ReturnedVariables"];
    
     //  NSMutableArray *authenticationResultsArray = [[[[resultDictionary valueForKey:@"d"]valueForKey:@"ReturnedDocumentFields"] firstObject] valueForKey:@"ReturnedDocumentFields"];
    
    
    _jobIdentity = [[[resultDictionary valueForKey:@"d"] valueForKey:@"JobIdentity"] valueForKey:@"Id"];
    
    
    
    if(authenticationResultsArray.count > 0){
        NSString *valueString = [[authenticationResultsArray objectAtIndex:0] valueForKey:@"Value"];
        
        NSData *objectData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *returnedOutput = [NSJSONSerialization JSONObjectWithData:objectData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:nil];
        _authenticationResult = returnedOutput[@"Result"];
        _transactionID = returnedOutput[@"TransactionId"];
        _canGoForSelfie = [returnedOutput[@"CanGoForSelfie"] boolValue];
        _errorInfo = returnedOutput[@"ErrorInfo"];
        if([[returnedOutput allKeys] containsObject:@"DocumentAlerts"]){
            NSString *documentAlerts = [returnedOutput valueForKey:@"DocumentAlerts"];
            NSData *objectData = [documentAlerts dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
            _authenticationReasons = [[AuthenticationReasonsModel alloc] initWithDictionary:json];
        }
    }
    
    
    
}*/


-(void)prepareModels:(NSDictionary*)resultDictionary{
    NSMutableArray *authenticationResultsArray = [[[[resultDictionary valueForKey:ROOTKEY_D_LOCAL]valueForKey:RETURNED_DOCUMENT_FIELDS_LOCAL] firstObject] valueForKey:RETURNED_DOCUMENT_FIELDS_LOCAL];
    
    _jobIdentity = [[[[resultDictionary valueForKey:ROOTKEY_D_LOCAL] valueForKey:JOB_IDENTITY_LOCAL] valueForKey:ID_LOCAL] isKindOfClass:[NSNull class]]?nil:[[[resultDictionary valueForKey:ROOTKEY_D_LOCAL] valueForKey:JOB_IDENTITY_LOCAL] valueForKey:ID_LOCAL];
    
    _documentID = [[[resultDictionary valueForKey:ROOTKEY_D_LOCAL] valueForKey:DOCUMENT_ID_LOCAL] isKindOfClass:[NSNull class]]?nil:[[resultDictionary valueForKey:ROOTKEY_D_LOCAL] valueForKey:DOCUMENT_ID_LOCAL];
    
    if(authenticationResultsArray.count > 0){
        
        _authenticationResult = [[[self extractionInfoForKey:VERIFICATION_RESULT_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:VERIFICATION_RESULT_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL];
        
        _transactionID = [[[self extractionInfoForKey:VERIFICATION_TRANSACTION_ID_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:VERIFICATION_TRANSACTION_ID_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL];
        
        _headShotBase64ImageString = [[[self extractionInfoForKey:VERIFICATION_PHOTO64_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:VERIFICATION_PHOTO64_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL];
        
        _jsonStringForAuthenticationReserved = [[[self extractionInfoForKey:VERIFICATION_RESERVED_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:VERIFICATION_RESERVED_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL];
        
         // Need to parse the String response for Error Info
         
        NSString *errorInfoText = [[[self extractionInfoForKey:VERIFICATION_ERROR_INFO_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL] isKindOfClass:[NSNull class]] ?nil:[[self extractionInfoForKey:VERIFICATION_ERROR_INFO_LOCAL withArray:authenticationResultsArray] valueForKey:VALUE_LOCAL];
         
         if(errorInfoText.length > 0){
             NSData *objectData = [errorInfoText dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *errorInfoDictionary = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:nil];
             if([errorInfoDictionary isKindOfClass:[NSDictionary class]]){
                 _errorInfo = [[errorInfoDictionary valueForKey:ERROR_MESSAGE_LOCAL] isKindOfClass:[NSNull class]]?nil:[errorInfoDictionary valueForKey:ERROR_MESSAGE_LOCAL] ;
             }
             
         }
         
        // End of Error Response parsing
         
         if(_jsonStringForAuthenticationReserved){
             
             NSData *objectData = [_jsonStringForAuthenticationReserved dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *returnedOutput = [NSJSONSerialization JSONObjectWithData:objectData
                                                                            options:NSJSONReadingMutableContainers error:nil];
             if([[returnedOutput allKeys] containsObject:DOCUMENT_INFO_LOCAL]){
                 
                 NSDictionary *documentInfoOutput = [[returnedOutput valueForKey:DOCUMENT_INFO_LOCAL] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:DOCUMENT_INFO_LOCAL];
                 if([documentInfoOutput isKindOfClass:[NSDictionary class]]){
                     
                     if([[documentInfoOutput allKeys] containsObject:DOCUMENT_ALERTS_LOCAL]){
                         NSDictionary *json = [[documentInfoOutput valueForKey:DOCUMENT_ALERTS_LOCAL] isKindOfClass:[NSNull class]]?nil:[documentInfoOutput valueForKey:DOCUMENT_ALERTS_LOCAL];
                         if([json isKindOfClass:[NSDictionary class]]){
                             _authenticationReasons = [[AuthenticationReasonsModel alloc] initWithDictionary:json];
                         }
                 }
                 
                 if([[documentInfoOutput allKeys] containsObject:DOCUMENT_TESTS_LOCAL]){
                     [self prepareDocumentTest:documentInfoOutput];
                 }
                 
                 if([[documentInfoOutput allKeys] containsObject:DOCUMENT_IMAGE_ANALYSIS_LOCAL]){
                     [self prepareDocumentImageAnalysis:documentInfoOutput];
                 }
                 
                 if([[documentInfoOutput allKeys] containsObject:DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL]){
                     [self prepareDocumentRiskVectorAnalysis:documentInfoOutput];
                 }
                 
                 if([[documentInfoOutput allKeys] containsObject:DOCUMENT_CLASSISFICATION_LOCAL]){
                     [self prepareDocumentClassification:documentInfoOutput];
                 }
                 
                 
             }
         }
         }
         
       /*  for (NSDictionary *resposeEntity in authenticationResultsArray){
             
          
             if([[resposeEntity valueForKey:@"Name"] isEqualToString:@"AuthenticationResponse"]){
                 if([[resposeEntity valueForKey:@"Value"] isKindOfClass:[NSNull class]]){
                     break;
                 }
                 else{
                 NSString *valueString = [resposeEntity valueForKey:@"Value"];
                 
                 NSData *objectData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
                 NSDictionary *returnedOutput = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:nil];
                 _authenticationResult = [[returnedOutput valueForKey:@"Result"] isKindOfClass:[NSNull class]]?@"":[returnedOutput valueForKey:@"Result"];
                _transactionID = [[returnedOutput valueForKey:@"TransactionId"] isKindOfClass:[NSNull class]]?@"":[returnedOutput valueForKey:@"TransactionId"];
                 _errorInfo = [[returnedOutput valueForKey:@"ErrorInfo"] isKindOfClass:[NSNull class]]?@"":[[returnedOutput valueForKey:@"ErrorInfo"] valueForKey:@"ErrorMessage"];
                     
               // Document information
            if([[returnedOutput allKeys] containsObject:@"DocumentInfo"]){
                         
            NSDictionary *documentInfoOutput = [[returnedOutput valueForKey:@"DocumentInfo"] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:@"DocumentInfo"];
                
                 
                _headShotBase64ImageString = [[documentInfoOutput valueForKey:@"Photo"] isKindOfClass:[NSNull class]]?@"":[documentInfoOutput valueForKey:@"Photo"];
                         
                 if([[documentInfoOutput allKeys] containsObject:@"DocumentAlerts"]){
                     NSDictionary *json = [[documentInfoOutput valueForKey:@"DocumentAlerts"] isKindOfClass:[NSNull class]]?@"":[documentInfoOutput valueForKey:@"DocumentAlerts"];
                  
                     _authenticationReasons = [[AuthenticationReasonsModel alloc] initWithDictionary:json];
                 }
                 
                     if([[documentInfoOutput allKeys] containsObject:@"DocumentTests"]){
                         [self prepareDocumentTest:documentInfoOutput];
                     }
                 
                     if([[documentInfoOutput allKeys] containsObject:@"DocumentImageAnalysis"]){
                         [self prepareDocumentImageAnalysis:documentInfoOutput];
                     }
                     
                     if([[documentInfoOutput allKeys] containsObject:@"DocumentRiskVectorAnalysis"]){
                         [self prepareDocumentRiskVectorAnalysis:documentInfoOutput];
                     }
                     
                     }
                     
                 }
                 
                 
             }
             
             
         }*/
         
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

-(void)prepareDocumentClassification:(NSDictionary*)returnedOutput{
    if  ([[returnedOutput allKeys] containsObject:DOCUMENT_CLASSISFICATION_LOCAL]){
        NSDictionary *json = [[returnedOutput valueForKey:DOCUMENT_CLASSISFICATION_LOCAL] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:DOCUMENT_CLASSISFICATION_LOCAL] ;
         if([json isKindOfClass:[NSDictionary class]]){
        
        _documentClassificationModel = [[AuthenticationDocumentClassificationModel alloc] initWithDictionary:json];
         }
    }
}

-(void)prepareDocumentTest:(NSDictionary *)returnedOutput {
    
    if([[returnedOutput allKeys] containsObject:DOCUMENT_TESTS_LOCAL]){
        NSDictionary *json = [[returnedOutput valueForKey:DOCUMENT_TESTS_LOCAL] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:DOCUMENT_TESTS_LOCAL];
         if([json isKindOfClass:[NSDictionary class]]){
        
        self.documentTests = [[NSMutableArray alloc]init];
        
        NSArray *arrKeys = json.allKeys;
        
        for (int i =0 ; i<arrKeys.count ; i++){
            
            DocumentTestsModel *documentTestModel = [[DocumentTestsModel alloc]initWithDictionary:json withTestName:arrKeys[i]];
           // if(documentTestModel.frontOriginality)
            [self.documentTests addObject:documentTestModel];
            
        }
        
         }
    }
    
}

-(void)prepareDocumentImageAnalysis:(NSDictionary*)returnedOutput{
    
    if  ([[returnedOutput allKeys] containsObject:DOCUMENT_IMAGE_ANALYSIS_LOCAL]){
        NSDictionary *json = [[returnedOutput valueForKey:DOCUMENT_IMAGE_ANALYSIS_LOCAL] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:DOCUMENT_IMAGE_ANALYSIS_LOCAL] ;
    
        if([json isKindOfClass:[NSDictionary class]]){
        _documentImageAnalysisModel = [[DocumentImageAnalysisModel alloc] initWithDictionary:json];
        }
    }
}

-(void)prepareDocumentRiskVectorAnalysis:(NSDictionary*)returnedOutput{
    
 /*   if  ([[returnedOutput allKeys] containsObject:@"DocumentRiskVectorAnalysis"]){
        NSArray *contents = [[returnedOutput valueForKey:@"DocumentRiskVectorAnalysis"] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:@"DocumentRiskVectorAnalysis"];
        
        //[returnedOutput valueForKey:@"DocumentRiskVectorAnalysis"];
      
        self.documentRisks = [[NSMutableArray alloc]init];
        
        
        for (int i =0 ; i<contents.count ; i++){
            
            DocumentRiskVectorAnalysisModel *documentRiskVectorAnalysisModel = [[DocumentRiskVectorAnalysisModel alloc] initWithDictionary:contents[i]];
            [self.documentRisks addObject:documentRiskVectorAnalysisModel];
            
        }
        
    }*/
    if([[returnedOutput allKeys] containsObject:DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL]){
        NSDictionary *json = [[returnedOutput valueForKey:DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL] isKindOfClass:[NSNull class]]?nil:[returnedOutput valueForKey:DOCUMENT_RISK_VECTOR_ANALYSIS_LOCAL];
        if([json isKindOfClass:[NSDictionary class]]){
        
        self.documentRisks = [[NSMutableArray alloc]init];
        
        NSArray *arrKeys = json.allKeys;
        
        for (int i =0 ; i<arrKeys.count ; i++){
            
            DocumentRiskVectorAnalysisModel *documenRiskVectorModel = [[DocumentRiskVectorAnalysisModel alloc] initWithDictionary:json withName:arrKeys[i]];
            //if(documenRiskVectorModel.frontOriginality)
                [self.documentRisks addObject:documenRiskVectorModel];
            
        }
        
        
    }
    }
}

-(void)dealloc {
    
  
}
@end
