//
//  ButtonStyler.h
//  AppStylerLib
//
//  Created by Rupali on 02/03/17.
//  Copyright © 2017 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ButtonStyler : NSObject

- (UIButton*)configure_primary_button:(UIButton*)button;
- (UIButton*)configure_secondary_button:(UIButton*)button;

@end
