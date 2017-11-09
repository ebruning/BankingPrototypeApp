//
//  SelfieOriginalityValuesModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 2/24/17.
//  Copyright © 2017 Kofax. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface SelfieOriginalityValuesModel : NSObject

@property (nonatomic,readonly) NSString *natural;
@property (nonatomic,readonly) NSString *screencap;

-(id)initWithDictionary: (NSDictionary *)dictInfo;

@end
