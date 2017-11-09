//
//  SelfiePushNotificationService.h
//  KofaxMobileDemo
//
//  Created by Kofax on 10/05/17.
//  Copyright © 2017 Kofax. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "AuthenticationService.h"

@interface SelfiePushNotificationService : AuthenticationService


-(void)performSelfiePushNotficationServiceWithURL:(NSURL*)url forParameters:(NSDictionary*)parameters withHeadshotImage:(UIImage*)headshotImage withSelfieImage:(UIImage*)selfieImage withCompletionHandler:(void (^)(id responseData , NSInteger status))handler;

@end
