//
//  AuthenticationService.m
//  KofaxMobileDemo
//
//  Created by Kofax on 1/30/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "AuthenticationService.h"
#import "KofaxBank-Swift.h"

@interface AuthenticationService()<NSURLSessionDelegate>
{
    
}


@property (nonatomic) NSString *sessionID;

@end


@implementation AuthenticationService

-(id)initWithSessionId:(NSString*)sessionID{
    self = [super init];
    if (self) {
        self.sessionID = sessionID;
    }
    return self;
}

//This method prepares JSON dictionary for ProcessIdentity
-(NSMutableDictionary *)getProcessIdentityDictionary:(NSDictionary *)parameters{
    
    NSMutableDictionary *processIdentityDict=[[NSMutableDictionary alloc]init];
    [processIdentityDict setValue:[NSNull null] forKey:@"Id"];
    [processIdentityDict setValue:[parameters valueForKey:@"processIdentityName"] forKey:@"Name"]; // KofaxMobileIDAuthentication //[parameters valueForKey:@"processIdentityName"]
    [processIdentityDict setValue:[NSNumber numberWithInt:0] forKey:@"Version"];
    return processIdentityDict;
    
}

-(NSMutableDictionary *)getDocumentInitialisationDictionary:(NSDictionary *)parameters images:(NSArray *)imageBytesArray{
    
    NSMutableDictionary *documentInitialisationDictionary = [[NSMutableDictionary alloc]init];
   
    ServerConstants* serverConstants = [[ServerConstants alloc]init];

    if([parameters valueForKey:serverConstants.STOREFOLDER_AND_DOCUMENTS]){
        
        
        [documentInitialisationDictionary setValue:[parameters valueForKey:serverConstants.STOREFOLDER_AND_DOCUMENTS] forKey:@"StoreFolderAndDocuments"];
    }
    else{
        [documentInitialisationDictionary setValue:@"false" forKey:@"StoreFolderAndDocuments"];
    }
    
    
    
    
    
    [documentInitialisationDictionary setValue:[self getInputVariablesArray:parameters] forKey:@"InputVariables"];
    [documentInitialisationDictionary setValue:[NSNull null] forKey:@"StartDate"];
   
         [documentInitialisationDictionary setValue:[self getRuntimeDocumentCollection:parameters images:imageBytesArray] forKey:@"Documents"];
    //RuntimeDocumentCollection
    
    return documentInitialisationDictionary;
    
    
}

// Sub Queries

-(NSMutableArray *)getInputVariablesArray:(NSDictionary *)parameters{
    
    
    NSMutableDictionary *dictInputVariables = [[NSMutableDictionary alloc]initWithDictionary:parameters];
    [dictInputVariables removeObjectForKey:@"username"];
    [dictInputVariables removeObjectForKey:@"password"];
    [dictInputVariables removeObjectForKey:@"processIdentityName"];
    [dictInputVariables removeObjectForKey:@"documentGroupName"];
    [dictInputVariables removeObjectForKey:@"documentName"];
    [dictInputVariables removeObjectForKey:@"sessionId"];
    [dictInputVariables removeObjectForKey:@"storeFolderAndDocuments"];
    
    //Create an empty array
    NSMutableArray *arrInputVariables = [[NSMutableArray alloc]init];
    
    //Iterate through all the keys and set values for Id and Value
    for( NSString *strKey in dictInputVariables.allKeys){
        
        NSDictionary * dictInput = [NSDictionary dictionaryWithObjectsAndKeys:strKey,@"Id",[dictInputVariables valueForKey:strKey],@"Value", nil];
        
        [arrInputVariables addObject:dictInput];
    }
    
    
    return arrInputVariables;
}


-(NSMutableArray *)getRuntimeDocumentCollection:(NSDictionary*)parameters images:(NSArray *)imageBytesArray{
    
    NSMutableDictionary *documentDictionary=[[NSMutableDictionary alloc]init];
    [documentDictionary setValue:[NSNull null] forKey:@"Base64Data"];//
    [documentDictionary setValue:[NSNull null] forKey:@"Data"];//
    [documentDictionary setValue:[NSNull null] forKey:@"DocumentTypeId"];//
    [documentDictionary setValue:[NSNull null] forKey:@"FieldsToReturn"];//
    [documentDictionary setValue:[NSNull null] forKey:@"FilePath"];//
    [documentDictionary setValue:[NSNull null] forKey:@"FolderId"];//
    [documentDictionary setValue:[NSNull null] forKey:@"FolderTypeId"];//
    [documentDictionary setValue:[self imageMimeTypeFromData:[imageBytesArray objectAtIndex:0]] forKey:@"MimeType"];//
    [documentDictionary setValue:[NSNull null] forKey:@"PageImageDataCollection"];//
    [documentDictionary setValue:[NSNull null] forKey:@"RuntimeFields"];//
    [documentDictionary setValue:[NSNumber numberWithBool:false] forKey:@"ReturnFullTextOcr"];
    
    NSMutableDictionary *documentGroupDictionary=[[NSMutableDictionary alloc]init];
    [documentGroupDictionary setValue:[NSNull null] forKey:@"Id"];
    
    [documentGroupDictionary setValue:[NSNull null] forKey:@"Name"];
    [documentGroupDictionary setValue:[NSNumber numberWithInt:0] forKey:@"Version"];
    
    [documentDictionary setValue:documentGroupDictionary forKey:@"DocumentGroup"];//
    documentGroupDictionary=nil;
    
    [documentDictionary setValue:[NSNull null] forKey:@"DocumentName"];//
    
    [documentDictionary setValue:[NSNumber numberWithBool:true] forKey:@"ReturnAllFields"];//
    
    [self addPages:imageBytesArray toDocument:documentDictionary];
    
    
    NSMutableArray *arrDocuments=[[NSMutableArray alloc]init];
    [arrDocuments addObject:documentDictionary];
    
    return arrDocuments;
    
}

/*Image Bytes Array contains the array of Base64 converted Data  */
-(void)addPages:(NSArray *)imageBytesArray toDocument:(NSDictionary*)documentDict{
    
    NSMutableArray *pagesList = [[NSMutableArray alloc]init];
    
    for(NSData* imageData in imageBytesArray)
    {
        NSString *imageType = [self imageMimeTypeFromData:imageData];
        NSString *base64String = [imageData base64EncodedStringWithOptions:0];
        
        [pagesList addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"Data",base64String,@"Base64Data",imageType,@"MimeType",[NSDictionary dictionary],@"RuntimeFields", nil]];
    }
    
    [documentDict setValue:pagesList forKey:@"PageDataList"];//
    
}


#pragma mark - Internal
-(NSString *)imageMimeTypeFromData:(NSData *)imageData
{
    uint8_t c;
    [imageData getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
}


#pragma mark NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
    
}

#pragma mark App Stats Recording for KTA Server Calls

-(void)recordEvent:(NSString*)event withReponse:(NSString*)responseString{
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    kfxKUTAppStatsSessionEvent * evt = [[kfxKUTAppStatsSessionEvent alloc] init];
    
    evt.type = event;
    
    //Escape apostrophe from the string
    responseString = [responseString stringByReplacingOccurrencesOfString:@"'" withString:@"\u2019"];
    
    evt.response=responseString;
    
    int code = [stats logSessionEvent:evt];
    
    if(code != KMC_SUCCESS){
        NSLog(@"App Stats record error %@",[kfxError findErrDesc:code]);
    }
}

@end
