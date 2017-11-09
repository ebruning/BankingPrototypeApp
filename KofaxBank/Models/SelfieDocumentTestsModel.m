//
//  SelfieDocumentTestsModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 2/24/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "SelfieDocumentTestsModel.h"

@implementation SelfieDocumentTestsModel


-(instancetype)initWithDictionary: (NSDictionary *)dictInfo withTestName:(NSString *)testName{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo withTestName:testName];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)resultDictionary withTestName:(NSString *)testName{
    
    _documentTestTitle = testName;
    
    NSDictionary *dictOriginality = [[resultDictionary valueForKey:testName] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:testName];
    if([dictOriginality isKindOfClass:[NSDictionary class]]){
    //NSDictionary *dictFrontOriginality = [[dictOriginality valueForKey:@"Front"] isKindOfClass:[NSNull class]]?nil:[dictOriginality valueForKey:@"Front"]; //dictOriginality[@"Front"];
    _frontOriginality = [[SelfieOriginalityValuesModel alloc]initWithDictionary:dictOriginality];
    }
    else if ([[testName uppercaseString] isEqualToString:@"RESULT"]){
        
        _result = [[resultDictionary valueForKey:testName] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:testName];
        
    }
}


@end
