//
//  RiskVectorOriginalityModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 5/11/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "RiskVectorOriginalityModel.h"
#import "ModelUtilities.h"

@interface RiskVectorOriginalityModel()

@property (nonatomic) NSString *result;
@property (nonatomic) NSString *exifData;

@end

@implementation RiskVectorOriginalityModel

-(id)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)dictInfo {
    
    if([dictInfo isKindOfClass:[NSDictionary class]]){
        self.result = [ModelUtilities getStringForKey:@"Result" withDictionary:dictInfo];
        self.exifData = [ModelUtilities getStringForKey:@"ExifData" withDictionary:dictInfo];
    }
}

@end
