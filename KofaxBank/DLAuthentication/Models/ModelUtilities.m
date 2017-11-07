//
//  ModelUtilities.m
//  KofaxBank
//
//  Created by Rupali on 30/10/17.
//  Copyright © 2017 kofax. All rights reserved.
//

#import "ModelUtilities.h"

@implementation ModelUtilities

+(NSString*)getStringForKey:(NSString*)key withDictionary:(NSDictionary*)inputDictionary{
    
    NSString *stringValue = [[inputDictionary valueForKey:key] isKindOfClass:[NSNull class]]?nil:[[inputDictionary valueForKey:key] isKindOfClass:[NSString class]]?[inputDictionary valueForKey:key]:[[inputDictionary valueForKey:key] stringValue];
    
    return stringValue;
}


@end
