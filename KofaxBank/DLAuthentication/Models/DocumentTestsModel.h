//
//  DocumentTestsModel.h
//  IDVerification
//
//  Created by Kofax on 2/15/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "OriginalityValuesModel.h"

@interface DocumentTestsModel : NSObject

@property(nonatomic,readonly) NSString *documentTestTitle;
@property(nonatomic,readonly) OriginalityValuesModel *frontOriginality;
@property(nonatomic,readonly) OriginalityValuesModel*backOriginality;
@property(nonatomic,readonly) NSString *result;
-(instancetype)initWithDictionary: (NSDictionary *)dictInfo withTestName:(NSString *)testName;

@end
