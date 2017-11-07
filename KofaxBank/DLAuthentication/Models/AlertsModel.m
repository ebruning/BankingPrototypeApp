//
//  ResultModel.m
//  KofaxMobileDemo
//
//  Created by Kofax on 2/8/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "AlertsModel.h"

#define DOCUMENT_ALERT_ACTION_OR_DISPOSITION @"ActionOrDisposition"
#define DOCUMENT_ALERT_DESCRIPTION @"Description"
#define DOCUMENT_ALERT_INFORMATION @"Information"
#define DOCUMENT_ALERT_ACTIONS @"Actions"

@implementation AlertsModel


-(instancetype)initWithDictionary: (NSDictionary *)dictInfo{
    
    if(self = [super init])
    {
        [self prepareModels:dictInfo];
        
        
    }
    return self;
    
}


-(void)prepareModels:(NSDictionary*)resultDictionary{
    _alertDescription = [[resultDictionary valueForKey:DOCUMENT_ALERT_DESCRIPTION] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:DOCUMENT_ALERT_DESCRIPTION];//resultDictionary[DOCUMENT_ALERT_DESCRIPTION];
    _actionOrDisposition = [[resultDictionary valueForKey:DOCUMENT_ALERT_ACTION_OR_DISPOSITION] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:DOCUMENT_ALERT_ACTION_OR_DISPOSITION];//resultDictionary[DOCUMENT_ALERT_ACTION_OR_DISPOSITION];
    _actions = [[resultDictionary valueForKey:DOCUMENT_ALERT_ACTIONS] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:DOCUMENT_ALERT_ACTIONS];//resultDictionary[DOCUMENT_ALERT_ACTIONS];
    _information = [[resultDictionary valueForKey:DOCUMENT_ALERT_INFORMATION] isKindOfClass:[NSNull class]]?nil:[resultDictionary valueForKey:DOCUMENT_ALERT_INFORMATION];//resultDictionary[DOCUMENT_ALERT_INFORMATION];
}


@end
