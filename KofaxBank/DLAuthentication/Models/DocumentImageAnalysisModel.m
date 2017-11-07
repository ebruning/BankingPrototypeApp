//
//  DocumentImageAnalysisModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 4/20/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "DocumentImageAnalysisModel.h"
#import "ImageOriginalityValuesModel.h"

@interface DocumentImageAnalysisModel()

@property(nonatomic) ImageOriginalityValuesModel *frontOriginality;
@property(nonatomic) ImageOriginalityValuesModel *backOriginality;
@property(nonatomic) NSString *result;
@end

@implementation DocumentImageAnalysisModel

-(instancetype)initWithDictionary: (NSDictionary *)dictInfo{
   
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
}

-(void)prepareModels:(NSDictionary*)resultDictionary{
    
    NSDictionary *dictFrontOriginality = [[resultDictionary valueForKey:@"Front"] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:@"Front"];//resultDictionary[@"Front"];
    NSDictionary *dictBackOriginality =  [[resultDictionary valueForKey:@"Back"] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:@"Back"];//resultDictionary[@"Back"];
    self.result = [[resultDictionary valueForKey:@"Result"] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:@"Result"];
    self.frontOriginality = [[ImageOriginalityValuesModel alloc]initWithDictionary:dictFrontOriginality];
    self.backOriginality =  [[ImageOriginalityValuesModel alloc]initWithDictionary:dictBackOriginality];
    
}

@end
