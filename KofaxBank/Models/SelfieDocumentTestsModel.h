//
//  SelfieDocumentTestsModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 2/24/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "SelfieOriginalityValuesModel.h"

@interface SelfieDocumentTestsModel : NSObject

@property(nonatomic,readonly) NSString *documentTestTitle;
@property(nonatomic,readonly) SelfieOriginalityValuesModel *frontOriginality;
@property(nonatomic) NSString *result;
-(instancetype)initWithDictionary: (NSDictionary *)dictInfo withTestName:(NSString *)testName;
@end
