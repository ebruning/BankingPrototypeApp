//
//  SplashStyler.h
//  AppStylerLib
//
//  Created by Rupali on 27/02/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SplashStyler : NSObject

- (UIView*)configure_view_background:(UIView*) view;

- (UILabel*)configure_app_title:(UILabel*)labelView;

- (UIImageView*)configure_app_logo:(UIImageView*)imageView;

- (UILabel*)configure_footer_text:(UILabel*)labelView;

- (UIImageView*)configure_footer_logo:(UIImageView*)imageView;

@end
