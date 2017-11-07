//
//  DocumentRiskVectorAnalysisModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 4/20/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "DocumentRiskVectorAnalysisModel.h"
#import "RiskVectorOriginalityModel.h"
@interface DocumentRiskVectorAnalysisModel()

@property(nonatomic) NSString *documentRiskVectorTitle;
@property(nonatomic) RiskVectorOriginalityModel *frontOriginality;
@property(nonatomic) RiskVectorOriginalityModel*backOriginality;
@property(nonatomic) NSString *result;


@end

@implementation DocumentRiskVectorAnalysisModel

/*-(id)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)resultDictionary{

    _name = [[resultDictionary valueForKey:@"Name"] isKindOfClass:[NSNull class]]?@"":[resultDictionary valueForKey:@"Name"];
    _imageSide = [[resultDictionary valueForKey:@"ImageSide"] isKindOfClass:[NSNull class]]?@"":[resultDictionary valueForKey:@"ImageSide"];
    _exifData = [[resultDictionary valueForKey:@"ExifData"] isKindOfClass:[NSNull class]]?@"":[resultDictionary valueForKey:@"ExifData"];
    _result = [[resultDictionary valueForKey:@"Result"] isKindOfClass:[NSNull class]]?@"":[resultDictionary valueForKey:@"Result"];
}*/
-(instancetype)initWithSelfieRiskAnalysisDictionary: (NSDictionary *)dictInfo withName:(NSString *)name{
    
    if(self = [super init])
    {
        [self prepareSelfieRiskAnalysisModels:dictInfo withName:name];
        
        
    }
    return self;
}

-(instancetype)initWithDictionary: (NSDictionary *)dictInfo withName:(NSString *)name{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo withName:name];
        
        
    }
    return self;
    
}

-(void)prepareModels:(NSDictionary*)resultDictionary withName:(NSString *)name{
    
    self.documentRiskVectorTitle = name;
    
    NSDictionary *dictOriginality = [[resultDictionary valueForKey:name] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:name];
    
    if([dictOriginality isKindOfClass:[NSDictionary class]]){
        NSDictionary *dictFrontOriginality = [[dictOriginality valueForKey:@"Front"] isKindOfClass:[NSNull class]]?nil:[dictOriginality valueForKey:@"Front"];
        NSDictionary *dictBackOriginality = [[dictOriginality valueForKey:@"Back"] isKindOfClass:[NSNull class]]?nil:[dictOriginality valueForKey:@"Back"];
        
        if([dictFrontOriginality isKindOfClass:[NSDictionary class]]){
        self.frontOriginality = [[RiskVectorOriginalityModel alloc]initWithDictionary:dictFrontOriginality];
        }
        if([dictBackOriginality isKindOfClass:[NSDictionary class]]){
        self.backOriginality =  [[RiskVectorOriginalityModel alloc]initWithDictionary:dictBackOriginality];
        }
    }
    else if ([[name uppercaseString] isEqualToString:@"RESULT"]){
        
        self.result = [[resultDictionary valueForKey:name] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:name];
        
    }
}

-(void)prepareSelfieRiskAnalysisModels:(NSDictionary*)resultDictionary withName:(NSString *)name{
   
    self.documentRiskVectorTitle = name;
    
    
    if([resultDictionary isKindOfClass:[NSDictionary class]]){
        NSDictionary *dictOriginality = [[resultDictionary valueForKey:name] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:name];
        if([dictOriginality isKindOfClass:[NSDictionary class]]){
        self.frontOriginality = [[RiskVectorOriginalityModel alloc]initWithDictionary:dictOriginality];
        }
        else if ([[name uppercaseString] isEqualToString:@"RESULT"]){
            self.result = [[resultDictionary valueForKey:name] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:name];
            
        }
    }  
    
}
@end
