//
//  ImageOriginalityValuesModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 4/20/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageOriginalityValuesModel : NSObject

@property(nonatomic,readonly) NSString *colorSpace;
@property(nonatomic,readonly) NSString *dpi;
@property(nonatomic,readonly) NSString *faceCount;
@property(nonatomic,readonly) NSString *result;
-(id)initWithDictionary: (NSDictionary *)dictInfo;

@end
