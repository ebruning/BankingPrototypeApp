//
//  SelfieAuthenticationService.m
//  KofaxMobileDemo
//
//  Created by Kofax on 1/30/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "SelfieVerificationService.h"

@interface SelfieVerificationService()<NSURLSessionDelegate>
{
    
}
@property (nonatomic) NSString *sessionID;
@property (nonatomic) void(^completionHandler)(id responseData , NSInteger status);
-(NSMutableDictionary *)getProcessIdentityDictionary:(NSDictionary *)parameters;
-(NSMutableDictionary *)getDocumentInitialisationDictionary:(NSDictionary *)parameters images:(NSArray *)imageBytesArray;
@end

@implementation SelfieVerificationService


-(void)performSelfieVerificationWithURL:(NSURL*)url forParameters:(NSDictionary*)parameters onImages:(NSArray*)imageBytesArray withCompletionHandler:(void (^)(id responseData , NSInteger status))handler{
 
    self.completionHandler = handler;
    
    NSData *jsonData = [self getJSONOutputData:parameters images:imageBytesArray];
    
    
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
        self.completionHandler(data,responseCode);
        
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
    NSData *jsonOutputData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    
    
    //NSString * myString=[[NSString alloc] initWithData:jsonOutputData   encoding:NSUTF8StringEncoding];
    return jsonOutputData;
    
}

-(NSArray*)prepareVariablesToReturn{
    
    NSArray *prepopulated = nil;
    //[[NSArray alloc]initWithObjects:@"SelfiMatchResult",@"SelfiMatchDescription",@"SelfiMatchScore",@"SelfiMatchThreshold",@"HeadShotBase64" ,nil];
   // NSArray *prepopulated = [[NSArray alloc]initWithObjects:@"SelfieRespo1nse",@"HeadShotBase64",nil];
    NSMutableArray *variablesToReturn = [[NSMutableArray alloc]init];
    
    for (int i = 0 ; i < prepopulated.count ; i++){
        NSDictionary *keyValue = [[NSDictionary alloc]initWithObjectsAndKeys:prepopulated[i],@"Name",prepopulated[i],@"Id",nil];
        [variablesToReturn addObject:keyValue];
    }
    
    return variablesToReturn;
    
}


@end
