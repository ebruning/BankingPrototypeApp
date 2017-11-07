//
//  IDAuthenticationService.m
//  KofaxMobileDemo
//
//  Created by Kofax on 1/30/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "IDAuthenticationService.h"

@class AuthenticationService;
@interface IDAuthenticationService()<NSURLSessionDelegate>
{
    
}
@property (nonatomic) NSString *sessionID;
//@property(nonatomic)  authenticationGenre genre;
@property (nonatomic) void(^completionHandler)(id responseData , NSInteger status , NSError* error);
-(NSMutableDictionary *)getProcessIdentityDictionary:(NSDictionary *)parameters;
-(NSMutableDictionary *)getDocumentInitialisationDictionary:(NSDictionary *)parameters images:(NSArray *)imageBytesArray;
//-(void)recordEvent:(NSString*)event withReponse:(NSString*)responseString;
@end

@implementation IDAuthenticationService


/*-(void)performIDAuthenticationWithURL:(NSURL*)url forParameters:(NSDictionary*)parameters onImages:(NSArray*)imageBytesArray withType:(authenticationGenre)genre withCompletionHandler:(void (^)(id responseData , NSInteger status , NSError* error))handler{*/
    
    -(void)performIDAuthenticationWithURL:(NSURL*)url forParameters:(NSDictionary*)parameters onImages:(NSArray*)imageBytesArray  withCompletionHandler:(void (^)(id responseData , NSInteger status , NSError* error))handler{
    
    self.completionHandler = handler;
    //self.genre = genre;
    NSData *jsonData = [self getJSONOutputData:parameters images:imageBytesArray];
    // Record Data for App Stats
    [self prepareResponseForAppStats:jsonData];
        
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url]; //[NSURL URLWithString:AuthenticIDURL]
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    defaultConfigObject.URLCache = nil;
    defaultConfigObject.timeoutIntervalForRequest = 90.0;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue new]];
    
    NSURLSessionDataTask * dataTask =  [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        NSLog(@"%s", [data bytes]);
        
        NSInteger responseCode = [((NSHTTPURLResponse *)response) statusCode];
        // [kfxError findErrDesc:(int)responseCode];
        NSLog(@"%@",[NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
        if(responseCode == 200){
        // Success , record app stats with DocumentID and JobID
        
        [self prepareSuccessResponseForAppStats:data];
    
            
        }
        else{
        // Failed ,record app stats for failure
        NSString *errorDescription = [NSHTTPURLResponse localizedStringForStatusCode:(NSInteger)responseCode];
            // Record the Event for the failed status
            //[self recordEvent:KTA_RESPONSE_STATUS withReponse:@"Error"];
            
            // Record the Event for the error description
            //[self recordEvent:KTA_RESPONSE withReponse:errorDescription];
        }
        self.completionHandler(data,responseCode ,error);
        
    }];
    
    [dataTask resume];
}

//This method prepares JSON dictionary for HTTPBody from the parameters and imageBytesArray.
-(NSData *)getJSONOutputData:(NSDictionary *)parameters images:(NSArray *)imageBytesArray{
    
    NSMutableDictionary *jsonDict=[[NSMutableDictionary alloc]init];
    [jsonDict setValue:self.sessionID forKey:@"sessionId"];
    [jsonDict setValue:[self getProcessIdentityDictionary:parameters] forKey:@"processIdentity"];
    [jsonDict setValue:[self prepareVariablesToReturn] forKey:@"variablesToReturn"];
    [jsonDict setValue:[self getDocumentInitialisationDictionary:parameters images:imageBytesArray] forKey:@"jobWithDocsInitialization"];
    
    
    NSError *error = nil;
    //.. NSString *jsonString = [NSString stringWithFormat:@"%@", jsonDict];
    NSData *jsonOutputData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    
    
    //NSString * myString=[[NSString alloc] initWithData:jsonOutputData   encoding:NSUTF8StringEncoding];
    return jsonOutputData;
    
}




-(NSArray*)prepareVariablesToReturn{
    //@"AuthenticReason",@"TransactionID",@"GoforSelfi",
    NSArray *prepopulated;
    /*if(self.genre == AUTHENTICATION_WITH_ODE){
        prepopulated = nil; //[[NSArray alloc]initWithObjects:@"AuthenticResult", nil];
    }
    else{
        
        prepopulated = nil; //[[NSArray alloc]initWithObjects:@"AuthenticResult",@"ExtractionResponse", nil];
    }*/
    prepopulated = nil;
    NSMutableArray *variablesToReturn = [[NSMutableArray alloc]init];
    
    for (int i = 0 ; i < prepopulated.count ; i++){
        NSDictionary *keyValue = [[NSDictionary alloc]initWithObjectsAndKeys:prepopulated[i],@"Name",prepopulated[i],@"Id",nil];
        [variablesToReturn addObject:keyValue];
    }
    
    return variablesToReturn;
    
}

-(void)prepareResponseForAppStats:(NSData*)requestData{
 NSString * appStatsDataString = [[NSString alloc] initWithData:requestData   encoding:NSUTF8StringEncoding];
 //[self recordEvent:KTA_REQUEST withReponse:appStatsDataString];
    
}

-(void)prepareSuccessResponseForAppStats:(NSData*)responseData{
    // Record the Event for the Success status
    //[self recordEvent:KTA_RESPONSE_STATUS withReponse:@"Completed"];
    
   
    
    // Record The Event for DocumentID
    NSData *data = [NSData dataWithData:responseData];
    id extractionOutput = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if([extractionOutput isKindOfClass:[NSDictionary class]]){
        NSString *documentID = [[extractionOutput valueForKey:@"d"]valueForKey:@"DocumentId"];
       // [self recordEvent:KTA_DOCUMENT_ID withReponse:documentID];
        
        //recording the Job ID of the response
        NSString* jobID = [[[extractionOutput valueForKey:@"d"] valueForKey:@"JobIdentity"] valueForKey:@"Id"];
//        [self recordEvent:KTA_JOB_ID withReponse:jobID];
       
       // Extraction response
        
        NSMutableArray *fieldsArr = [NSMutableArray arrayWithArray:[[[[extractionOutput valueForKey:@"d"]valueForKey:@"ReturnedDocumentFields"] firstObject] valueForKey:@"ReturnedDocumentFields"]];
        

        // Fetch Verification Reserved and formt the JSON which is currently String JSON , also format the JSON String present in DocumentFieldAlternatives.
        
        [self formatJSONForVerificationReserved:fieldsArr];
        
        // End of formating Verification Reserved
        
        
        
        // Fetch VerificationErrorInfo and formt the JSON which is currently String JSON , also format the JSON String present in DocumentFieldAlternatives
        
        [self formatJSONForVerificationErrorInfo:fieldsArr];
        
        // End of formating VerificationErrorInfo
   // Reassign the updated fieldsArr by traversing the response structure and fetch mutable copies so that the updatated object can be replaced.
        
        NSMutableDictionary *rootObject = [[extractionOutput valueForKey:@"d"] mutableCopy];
        NSMutableDictionary *returnDocumentFieldsObject = [[[rootObject valueForKey:@"ReturnedDocumentFields"]firstObject] mutableCopy];
        
        [returnDocumentFieldsObject setObject:fieldsArr forKey:@"ReturnedDocumentFields"];
        
        [rootObject setObject:@[returnDocumentFieldsObject] forKey:@"ReturnedDocumentFields"];
        
        extractionOutput = @{@"d":rootObject};
        

        
        fieldsArr = nil;
        rootObject = nil;
        returnDocumentFieldsObject = nil;
        
        NSData *dataFromDict = [NSJSONSerialization dataWithJSONObject:extractionOutput
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
        NSString *responseString = [[NSString alloc]initWithData:dataFromDict encoding:NSUTF8StringEncoding];
        // Record the Event for the Success Response as String
//        [self recordEvent:KTA_RESPONSE withReponse:responseString];
  
        
    }
}

-(void)formatJSONForVerificationReserved:(NSMutableArray*)fieldsArray{
    NSInteger indexOfObject;
    NSDictionary *verificationReserved = [[self fetchInfoForKey:@"VerificationReserved" withArray:fieldsArray] mutableCopy];
    
    if([verificationReserved isKindOfClass:[NSDictionary class]]){
        indexOfObject = [fieldsArray indexOfObject:verificationReserved];
        NSString *value = [[verificationReserved valueForKey:@"Value"] isKindOfClass:[NSNull class]]?nil:[verificationReserved valueForKey:@"Value"];
        if(value){
            id json = [self fetchJSONFromString:value];
            if([json isKindOfClass:[NSDictionary class]]){
                [verificationReserved setValue:json forKey:@"Value"];
            }
            NSMutableArray *documentFieldsAlternatives = [[NSMutableArray alloc] init];
            
            //[NSMutableArray arrayWithArray:[verificationReserved valueForKey:@"DocumentFieldAlternatives"]]; //;
            for (NSDictionary *dict in [verificationReserved valueForKey:@"DocumentFieldAlternatives"]){
                NSMutableDictionary *entry = [dict mutableCopy];
                NSString *text = [entry valueForKey:@"Text"];
                id json = [self fetchJSONFromString:text];
                if([json isKindOfClass:[NSDictionary class]]){
                    [entry setValue:json forKey:@"Text"];
                    [documentFieldsAlternatives addObject:entry];
                }
            }
            [verificationReserved setValue:documentFieldsAlternatives forKey:@"DocumentFieldAlternatives"];
            documentFieldsAlternatives = nil;
        }
        if(indexOfObject <= fieldsArray.count-1)
            [fieldsArray replaceObjectAtIndex:indexOfObject withObject:verificationReserved];
        
    }
    verificationReserved = nil;
}

-(void)formatJSONForVerificationErrorInfo:(NSMutableArray*)fieldsArray{
    NSDictionary *verificationErrorInfo = [[self fetchInfoForKey:@"VerificationErrorInfo" withArray:fieldsArray] mutableCopy];
    NSInteger indexOfObject;
    if([verificationErrorInfo isKindOfClass:[NSDictionary class]]){
        indexOfObject = [fieldsArray indexOfObject:verificationErrorInfo];
        NSString *value = [[verificationErrorInfo valueForKey:@"Value"] isKindOfClass:[NSNull class]]?nil:[verificationErrorInfo valueForKey:@"Value"];
        if(value){
            id json = [self fetchJSONFromString:value];
            if([json isKindOfClass:[NSDictionary class]]){
                [verificationErrorInfo setValue:json forKey:@"Value"];
            }
            NSMutableArray *documentFieldsAlternatives = [[NSMutableArray alloc] init];
            
            //[NSMutableArray arrayWithArray:[verificationReserved valueForKey:@"DocumentFieldAlternatives"]]; //;
            for (NSDictionary *dict in [verificationErrorInfo valueForKey:@"DocumentFieldAlternatives"]){
                NSMutableDictionary *entry = [dict mutableCopy];
                NSString *text = [entry valueForKey:@"Text"];
                id json = [self fetchJSONFromString:text];
                if([json isKindOfClass:[NSDictionary class]]){
                    [entry setValue:json forKey:@"Text"];
                    [documentFieldsAlternatives addObject:entry];
                }
            }
            [verificationErrorInfo setValue:documentFieldsAlternatives forKey:@"DocumentFieldAlternatives"];
            documentFieldsAlternatives = nil;
        }
        if(indexOfObject <= fieldsArray.count-1)
            [fieldsArray replaceObjectAtIndex:indexOfObject withObject:verificationErrorInfo];
        
    }
    verificationErrorInfo = nil;
}

-(NSDictionary *)fetchInfoForKey:(NSString *)key withArray:(NSArray *)array
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Name = %@",key];
    NSArray *tempArray = [array filteredArrayUsingPredicate:predicate];
    if (tempArray.count) {
        return tempArray[0];
    }
    return nil;
}

-(id)fetchJSONFromString:(NSString*)jsonString{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return json;
}

@end
