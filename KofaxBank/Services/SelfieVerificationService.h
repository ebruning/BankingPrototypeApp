//
//  SelfieAuthenticationService.h
//  KofaxMobileDemo
//
//  Created by Kofax on 1/30/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "AuthenticationService.h"

@interface SelfieVerificationService : AuthenticationService
{
    
}

-(void)performSelfieVerificationWithURL:(NSURL*)url forParameters:(NSDictionary*)parameters onImages:(NSArray*)imageBytesArray withCompletionHandler:(void (^)(id responseData , NSInteger status))handler;

@end
