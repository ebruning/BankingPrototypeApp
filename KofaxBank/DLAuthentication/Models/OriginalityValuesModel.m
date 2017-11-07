//
//  OriginalityValuesModel.m
//  IDVerification
//
//  Created by Kofax on 2/15/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "OriginalityValuesModel.h"
#import "ModelUtilities.h"
@interface OriginalityValuesModel()

@property (nonatomic) NSString *tampered;
@property (nonatomic) NSString *natural;

@end

@implementation OriginalityValuesModel

-(id)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)dictInfo {
    
    self.natural = [ModelUtilities getStringForKey:@"Natural" withDictionary:dictInfo];
    self.tampered = [ModelUtilities getStringForKey:@"Tampered" withDictionary:dictInfo];
    
}

@end
