//
//  CheckValidation.h
//  KofaxBank
//
//  Created by Rupali on 18/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <kfxLibEngines/kfxEngines.h>

@interface CheckValidation : NSObject

+ (BOOL)checkBackHasEndorsement:(NSString*)metaData;

+ (int)verifySignatureAndMicr:(NSString*)metaData isFrontSide:(BOOL)isFront;

+ (NSMutableArray*)validateSignatureOnCheckFront:(kfxKEDImage *)image isFrontSide:(BOOL)isFront;

@end
