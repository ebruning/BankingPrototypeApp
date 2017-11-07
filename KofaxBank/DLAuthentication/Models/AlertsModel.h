//
//  ResultModel.h
//  KofaxMobileDemo
//
//  Created by Kofax on 2/8/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertsModel : NSObject
{
    
}

@property(nonatomic,readonly)NSString *alertDescription;
@property(nonatomic,readonly)NSString *actionOrDisposition;
@property(nonatomic,readonly)NSString *information;
@property(nonatomic,readonly)NSString *actions;


-(instancetype)initWithDictionary: (NSDictionary *)dictInfo;
-(void)prepareModels:(NSDictionary*)resultDictionary;
@end
