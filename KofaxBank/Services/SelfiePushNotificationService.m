//
//  SelfiePushNotificationService.m
//  KofaxMobileDemo
//
//  Created by Kofax on 10/05/17.
//  Copyright © 2017 Kofax. All rights reserved.
//


#import "SelfiePushNotificationService.h"


@interface SelfiePushNotificationService()<NSURLSessionDelegate>
{
    
}
@property (nonatomic) NSString *sessionID;
@property (nonatomic) void(^completionHandler)(id responseData , NSInteger status);
-(NSMutableDictionary *)getProcessIdentityDictionary:(NSDictionary *)parameters;

@end

@implementation SelfiePushNotificationService


-(void)performSelfiePushNotficationServiceWithURL:(NSURL*)url forParameters:(NSDictionary*)parameters withHeadshotImage:(UIImage*)headshotImage withSelfieImage:(UIImage*)selfieImage withCompletionHandler:(void (^)(id responseData , NSInteger status))handler{
    
    self.completionHandler = handler;
    
    NSData *jsonData = [self getJSONOutputData:parameters withHeadshotImage:headshotImage withSelfieImage:selfieImage];
    
    
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

- (NSMutableDictionary*)getJobInitialisationDictionary:(NSDictionary*)parameters withHeadshotImage:(UIImage*)headshotImage withSelfieImage:(UIImage*)selfieImage
{
    NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
    [jobDict setValue:[NSNull null] forKey:@"StartDate"];
    [jobDict setValue:[self getInputVariablesFromParameters:parameters withHeadshotImage:headshotImage withSelfieImage:selfieImage] forKey:@"InputVariables"];
    
    return jobDict;
}

- (NSMutableArray*)getInputVariablesFromParameters:(NSDictionary*)parameters withHeadshotImage:(UIImage*)headshotImage withSelfieImage:(UIImage*)selfieImage
{
    NSMutableArray *inputVariablesArray = [[NSMutableArray alloc] init];
    AppUtilities *utilities = [[AppUtilities alloc] init];
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [inputVariablesArray addObject:@{@"Id":@"PushNotifyToken",
                                     @"Value":appdelegate.pushDeviceToken}];
    [inputVariablesArray addObject:@{@"Id":@"DocumentPhotoBase64",
                                     @"Value":[utilities getBase64StringOfImage:headshotImage]}];
    [inputVariablesArray addObject:@{@"Id":@"Platform",
                                     @"Value":@"ios"}];
    [inputVariablesArray addObject:@{@"Id":@"TransactionID",
                                     @"Value":[parameters valueForKey:@"TransactionId"]}];
    [inputVariablesArray addObject:@{@"Id":@"LivePhotoBase64",
                                     @"Value":[utilities getBase64StringOfImage:selfieImage]}];
    [inputVariablesArray addObject:@{@"Id":@"FRResults",
                                     @"Value":@"Attention"}];
    [inputVariablesArray addObject:@{@"Id":@"FRScore",
                                     @"Value":[parameters valueForKey:@"FRScore"]}];

    return inputVariablesArray;
}

//This method prepares JSON dictionary for HTTPBody from the parameters and imageBytesArray.
-(NSData *)getJSONOutputData:(NSDictionary *)parameters withHeadshotImage:(UIImage*)headshotImage withSelfieImage:(UIImage*)selfieImage{
    
    NSMutableDictionary *jsonDict=[[NSMutableDictionary alloc]init];
    [jsonDict setValue:self.sessionID forKey:@"sessionId"];
    [jsonDict setValue:[self getProcessIdentityDictionary:parameters] forKey:@"processIdentity"];
    [jsonDict setValue:[[NSMutableArray alloc]init] forKey:@"variablesToReturn"];
    [jsonDict setValue:[self getJobInitialisationDictionary:parameters withHeadshotImage:(UIImage*)headshotImage withSelfieImage:(UIImage*)selfieImage] forKey:@"jobInitialization"];
    
    NSError *error = nil;
    NSData *jsonOutputData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    return jsonOutputData;
    
}

@end
