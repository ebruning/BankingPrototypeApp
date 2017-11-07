//
//  DocumentTestsModel.m
//  IDVerification
//
//  Created by Kofax on 2/15/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "DocumentTestsModel.h"
#import "OriginalityValuesModel.h"

@interface DocumentTestsModel()

@property(nonatomic) NSString *documentTestTitle;
@property(nonatomic) OriginalityValuesModel *frontOriginality;
@property(nonatomic) OriginalityValuesModel*backOriginality;
@property(nonatomic) NSString *result;


@end


@implementation DocumentTestsModel

-(instancetype)initWithDictionary: (NSDictionary *)dictInfo withTestName:(NSString *)testName{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo withTestName:testName];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)resultDictionary withTestName:(NSString *)testName{
    
    self.documentTestTitle = testName;
    
    NSDictionary *dictOriginality = [[resultDictionary valueForKey:testName] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:testName];
    if([dictOriginality isKindOfClass:[NSDictionary class]]){
    NSDictionary *dictFrontOriginality = [[dictOriginality valueForKey:@"Front"] isKindOfClass:[NSNull class]]?nil:[dictOriginality valueForKey:@"Front"];//dictOriginality[@"Front"];
    NSDictionary *dictBackOriginality = [[dictOriginality valueForKey:@"Back"] isKindOfClass:[NSNull class]]?nil:[dictOriginality valueForKey:@"Back"];//dictOriginality[@"Back"];
    
    self.frontOriginality = [[OriginalityValuesModel alloc]initWithDictionary:dictFrontOriginality];
    self.backOriginality =  [[OriginalityValuesModel alloc]initWithDictionary:dictBackOriginality];
    }
    else if ([[testName uppercaseString] isEqualToString:@"RESULT"]){
        
        self.result = [[resultDictionary valueForKey:testName] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:testName];
        
    }
}


@end
