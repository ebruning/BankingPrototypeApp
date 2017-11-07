//
//  AuthenticationDocumentClassificationModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 5/2/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthenticationDocumentClassificationModel : NSObject

@property(nonatomic,readonly)NSString *classificationClass;
@property(nonatomic,readonly)NSString *classificationClassCode;
@property(nonatomic,readonly)NSString *classificationClassName;
@property(nonatomic,readonly)NSString *isGeneric;
@property(nonatomic,readonly)NSString *issue;
@property(nonatomic,readonly)NSString *issuerCode;
@property(nonatomic,readonly)NSString *issuerName;
@property(nonatomic,readonly)NSString *issueType;
@property(nonatomic,readonly)NSString *name;
@property(nonatomic,readonly)NSString *size;

-(instancetype)initWithDictionary: (NSDictionary *)dictInfo;

@end
