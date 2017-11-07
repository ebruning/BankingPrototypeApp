//
//  HomeVC.h
//  KofaxBank
//
//  Created by Rupali on 16/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeVC : UIViewController

/**
 @property contentViewHeight
 @description height for contentview palced in bottom scroll so that we can make it scrollable by increasing this height value
 */
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewHeight;


/**
 @property headerImageView
 @description showing header image view for the post
 */
@property(nonatomic, weak) IBOutlet UIImageView *headerImageView;

/**
 @property contentView
 @description view where we add our other controls
 */
@property(nonatomic, weak)  IBOutlet UIView *contentView;

/**
 @property headerImageViewHeight
 @description value for setting header image height
 */
@property(nonatomic, weak)  IBOutlet NSLayoutConstraint *headerImageViewHeight; //default half of screen size


/**
 @method adjustContentViewHeight
 @description this will adjust content view height
 */
-(void)adjustContentViewHeight;


@end
