//
//  SelfieOriginalityValuesModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 2/24/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "SelfieOriginalityValuesModel.h"
#import "ModelUtilities.h"

@implementation SelfieOriginalityValuesModel

-(id)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)dictInfo {
    
    _screencap = [ModelUtilities getStringForKey:@"Reflect" withDictionary:dictInfo];
    _natural =  [ModelUtilities getStringForKey:@"Natural" withDictionary:dictInfo];
    
}

@end
