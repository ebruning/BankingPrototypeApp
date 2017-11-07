//
//  AuthenticationReasonsModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 2/8/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "AuthenticationReasonsModel.h"
#import "PassedAlertsModel.h"
#import "FailedAlertsModel.h"
#import "AttentionAlertsModel.h"
#import "CautionAlertsModel.h"

#define PASSED_RESULTS  @"PassedResults"
#define FAILED_RESULTS  @"FailedResults"
#define ATTENTION_RESULTS  @"AttentionResults"
#define CAUTION_RESULTS  @"CautionResults"

@interface AuthenticationReasonsModel()

@property(nonatomic) NSMutableArray *passedResults;
@property(nonatomic) NSMutableArray *failedResults;
@property(nonatomic) NSMutableArray *attentionResults;
@property(nonatomic) NSMutableArray *cautionResults;

@end



@implementation AuthenticationReasonsModel

-(id)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)resultDictionary{
    
    _passedResults = [[NSMutableArray alloc]init];
    _failedResults = [[NSMutableArray alloc]init];
    _attentionResults =[[NSMutableArray alloc]init];
    _cautionResults = [[NSMutableArray alloc]init];
    
    for(NSDictionary *result in resultDictionary[PASSED_RESULTS]){
        [_passedResults addObject: [[PassedAlertsModel alloc] initWithDictionary:result]];
      
    }
  
    for(NSDictionary *result in resultDictionary[FAILED_RESULTS]){
        [_failedResults addObject: [[FailedAlertsModel alloc] initWithDictionary:result]];
        
    }

    
    for(NSDictionary *result in resultDictionary[ATTENTION_RESULTS]){
        [_attentionResults addObject: [[AttentionAlertsModel alloc] initWithDictionary:result]];
        
    }

    for(NSDictionary *result in resultDictionary[CAUTION_RESULTS]){
        [_cautionResults addObject: [[CautionAlertsModel alloc] initWithDictionary:result]];
        
    }


}
@end
