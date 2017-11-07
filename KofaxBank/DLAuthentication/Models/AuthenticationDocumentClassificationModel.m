//
//  AuthenticationDocumentClassificationModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 5/2/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "AuthenticationDocumentClassificationModel.h"
#import "ModelUtilities.h"

@implementation AuthenticationDocumentClassificationModel

-(instancetype)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
}

-(void)prepareModels:(NSDictionary*)resultDictionary{
    
    _classificationClass = [ModelUtilities getStringForKey:@"Class" withDictionary:resultDictionary];
    _classificationClassCode = [ModelUtilities getStringForKey:@"ClassCode" withDictionary:resultDictionary];
    _classificationClassName = [ModelUtilities getStringForKey:@"ClassName" withDictionary:resultDictionary];
    _issue = [ModelUtilities getStringForKey:@"Issue" withDictionary:resultDictionary];
    _issuerCode = [ModelUtilities getStringForKey:@"IssuerCode" withDictionary:resultDictionary];
    _issuerName = [ModelUtilities getStringForKey:@"IssuerName" withDictionary:resultDictionary];
    _issueType = [ModelUtilities getStringForKey:@"IssueType" withDictionary:resultDictionary];
    _name = [ModelUtilities getStringForKey:@"Name" withDictionary:resultDictionary];
    _size = [ModelUtilities getStringForKey:@"Size" withDictionary:resultDictionary];
    _isGeneric = [[resultDictionary valueForKey:@"IsGeneric"] isKindOfClass:[NSNull class]]?nil:[[resultDictionary valueForKey:@"IsGeneric"] boolValue]?@"true":@"false";
    
}

@end
