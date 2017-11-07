//
//  OriginalityValuesModel.h
//  IDVerification
//
//  Created by Kofax on 2/15/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OriginalityValuesModel : NSObject

@property (nonatomic,readonly) NSString *tampered;
@property (nonatomic,readonly) NSString *natural;

-(id)initWithDictionary: (NSDictionary *)dictInfo;


@end
