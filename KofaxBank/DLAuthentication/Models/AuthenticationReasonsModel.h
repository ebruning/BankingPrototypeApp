//
//  AuthenticationReasonsModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 2/8/17.
//  Copyright © 2017 Kofax. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface AuthenticationReasonsModel : NSObject
{
    
}

@property(nonatomic,readonly) NSArray *passedResults;
@property(nonatomic,readonly) NSArray *failedResults;
@property(nonatomic,readonly) NSArray *attentionResults;
@property(nonatomic,readonly) NSArray *cautionResults;

-(id)initWithDictionary: (NSDictionary *)dictInfo;

@end
