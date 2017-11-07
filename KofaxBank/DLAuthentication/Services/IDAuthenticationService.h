//
//  IDAuthenticationService.h
//  KofaxMobileDemo
//
//  Created by Kofax on 1/30/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import "AuthenticationService.h"

@interface IDAuthenticationService : AuthenticationService
{
    
}

/*-(void)performIDAuthenticationWithURL:(NSURL*)url forParameters:(NSDictionary*)parameters onImages:(NSArray*)imageBytesArray withType:(authenticationGenre)genre withCompletionHandler:(void (^)(id responseData , NSInteger status , NSError* error))handler;*/

-(void)performIDAuthenticationWithURL:(NSURL*)url forParameters:(NSDictionary*)parameters onImages:(NSArray*)imageBytesArray  withCompletionHandler:(void (^)(id responseData , NSInteger status , NSError* error))handler;

@end
