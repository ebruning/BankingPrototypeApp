//
//  DocumentRiskVectorAnalysisModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 4/20/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RiskVectorOriginalityModel.h"
@interface DocumentRiskVectorAnalysisModel : NSObject

/*@property(nonatomic,readonly)NSString *name;
@property(nonatomic,readonly)NSString *imageSide;
@property(nonatomic,readonly)NSString *exifData;
@property(nonatomic,readonly)NSString *result;

-(id)initWithDictionary: (NSDictionary *)dictInfo;*/

@property(nonatomic,readonly) NSString *documentRiskVectorTitle;
@property(nonatomic,readonly) RiskVectorOriginalityModel *frontOriginality;
@property(nonatomic,readonly) RiskVectorOriginalityModel *backOriginality;
@property(nonatomic,readonly) NSString *result;
-(instancetype)initWithSelfieRiskAnalysisDictionary: (NSDictionary *)dictInfo withName:(NSString *)name;
-(instancetype)initWithDictionary: (NSDictionary *)dictInfo withName:(NSString *)name;

@end
