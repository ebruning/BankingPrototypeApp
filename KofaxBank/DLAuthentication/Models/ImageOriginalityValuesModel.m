//
//  ImageOriginalityValuesModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 4/20/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "ImageOriginalityValuesModel.h"
#import "ModelUtilities.h"

@interface ImageOriginalityValuesModel()

@property (nonatomic) NSString *colorSpace;
@property (nonatomic) NSString *dpi;
@property (nonatomic) NSString *faceCount;
@property(nonatomic)  NSString *result;
@end

@implementation ImageOriginalityValuesModel

-(id)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)dictInfo {
    
    self.colorSpace = [ModelUtilities getStringForKey:@"ColorSpace" withDictionary:dictInfo];
    self.dpi = [ModelUtilities getStringForKey:@"DPI" withDictionary:dictInfo];
    self.faceCount = [ModelUtilities getStringForKey:@"FaceCount" withDictionary:dictInfo];
    self.result = [ModelUtilities getStringForKey:@"Result" withDictionary:dictInfo];
}



@end
