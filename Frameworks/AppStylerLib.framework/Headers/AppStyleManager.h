//
//  InsertManager.h
//  CustomThemeLib
//
//  Created by Rupali on 10/01/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SplashStyler.h"
#import "NavigationbarStyler.h"
#import "AppScreenStyler.h"
#import "ButtonStyler.h"


@interface AppStyleManager : NSObject

+ (instancetype)sharedInstance;

- (void)showStyler:(UINavigationController *)navController;

- (NavigationbarStyler*)get_navigationbar_styler;

- (SplashStyler*)get_splash_styler;

- (AppScreenStyler*)get_app_screen_styler;

- (ButtonStyler*)get_button_styler;

- (void)import_profile:(UINavigationController*) navController fileUrl:(NSURL*)fileUrl;

@end
