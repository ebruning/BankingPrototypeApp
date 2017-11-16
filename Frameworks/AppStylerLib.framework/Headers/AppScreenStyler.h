//
//  AppScreenStyler.h
//  AppStylerLib
//
//  Created by Rupali on 02/03/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppScreenStyler : NSObject

- (UIView*)configure_primary_view_background:(UIView*)view;
- (UIColor*)get_secondary_background_color;
- (UIColor*)get_primary_text_color;
- (UIColor*)get_secondary_text_color;
- (UIColor*)get_accent_color;

@end
