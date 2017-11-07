//
//  RiskVectorOriginalityModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 5/11/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RiskVectorOriginalityModel : NSObject

@property (nonatomic,readonly) NSString *result;
@property (nonatomic,readonly) NSString *exifData;

-(id)initWithDictionary: (NSDictionary *)dictInfo;

@end
