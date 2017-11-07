//
//  DocumentImageAnalysisModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 4/20/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageOriginalityValuesModel.h"
@interface DocumentImageAnalysisModel : NSObject

@property(nonatomic,readonly) ImageOriginalityValuesModel *frontOriginality;
@property(nonatomic,readonly) ImageOriginalityValuesModel *backOriginality;
@property(nonatomic,readonly) NSString *result;
-(instancetype)initWithDictionary: (NSDictionary *)dictInfo;
@end
