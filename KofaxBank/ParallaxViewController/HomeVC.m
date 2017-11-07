//
//  HomeVC.m
//  KofaxBank
//
//  Created by Rupali on 16/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

#import "HomeVC.h"
#import <MessageUI/MessageUI.h>

typedef enum {
    NONE = 0,
    DOWN = 1,
    UP = 2
}Direction;

@interface HomeVC ()<UIScrollViewDelegate, MFMailComposeViewControllerDelegate>


/**
 @property bottomScroll
 @description UIScrollView place at bottom of View holding labels and text and other controls one want to place on it
 */
@property(nonatomic, weak) IBOutlet UIScrollView *bottomScroll;

/**
 @property topScroll
 @description UIScrollView place at top of View holding post image
 */
@property(nonatomic, weak) IBOutlet UIScrollView *topScroll;
/**
 @property scrollDirectionValue
 @description holding value to determine scroll direction
 */
@property(nonatomic, assign) double lastScrollOffset;

/**
 @property yoffset
 @description set scroll contentoffset based on this offest value
 */
//@property(nonatomic, assign) float yoffset;

@property(nonatomic, assign) double scrollOffset;

@property(nonatomic, assign) double screenHeight;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


@property (weak, nonatomic) IBOutlet UIStackView *stackViewUserDetails;

@property (weak, nonatomic) IBOutlet UIView *bottomBarView;

/**
 @property alphaValue
 @description alpha to  fade in fade out nav color
 */
@property(nonatomic, assign) double alphaValue;
/**
 @property bottomViewTopConstraint
 @description constraint for aligning bottom view as per our post imageview height
 */
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *bottomViewTopConstraint;


@end

@implementation HomeVC

int bottomBarHeight;
int bottombarViewOriginalYPosition;

double divisionCounter;

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //for iOS 10
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    _screenHeight = UIScreen.mainScreen.bounds.size.height;
    
   // UIView *view = [[[NSBundle mainBundle]loadNibNamed:@"HomeScreen" owner:self options:nil] objectAtIndex:0];
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _screenHeight);
    //[self.view insertSubview:view atIndex:0];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.bottomScroll.delegate = self;
    [self resetScreenParams];
}


- (void)resetScreenParams {

    _scrollOffset = 0.70 * _screenHeight;
    
    _visualEffectView.alpha = 0;
    _stackViewUserDetails.alpha = 0;
    
    self.headerImageViewHeight.constant = _screenHeight * 0.30; //30% of screen height
    self.bottomViewTopConstraint.constant = _screenHeight;
    self.contentViewHeight.constant = _screenHeight;

    bottomBarHeight = _bottomBarView.frame.size.height;
    
    bottombarViewOriginalYPosition = _bottomBarView.frame.origin.y;
  
    divisionCounter = bottombarViewOriginalYPosition;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES];
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _screenHeight);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//[[self navigationController] setNavigationBarHidden:YES animated:NO];
    //navigationController?.setNavigationBarHidden(true, animated: false)
//    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _screenHeight);

    //[[self navigationController] setNavigationBarHidden:YES];

    CGRect scrollBounds = self.bottomScroll.bounds;
    scrollBounds.origin = CGPointMake(0, _scrollOffset);
    
   // self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _screenHeight);

    self.bottomScroll.bounds = scrollBounds;
}


-(void)adjustContentViewHeight{
    
    
}


#pragma mark UIScrollView Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    double offset=scrollView.contentOffset.y;
    double percentage=offset/_screenHeight;
    
    
    Direction direction = [self getScrollDirection: scrollView.contentOffset.y];
    
    _lastScrollOffset = offset;
    
    _visualEffectView.alpha=fabs(1-percentage);
    
   // NSLog(@"Percentage==> %f", percentage);
  //  NSLog(@"Y==> %f", self.bottomScroll.contentOffset.y);
    //NSLog(@"Image height ==> %f", self.headerImageViewHeight.constant);
  //  NSLog(@"------------------------------------------------------");
    
    
    if (percentage <= 0.15) {
        [self.bottomScroll setContentOffset:CGPointMake(0, 0.15 * _screenHeight)];
        _logoutButton.hidden = YES;
        _stackViewUserDetails.alpha = 1.0;
        _visualEffectView.alpha = 1.0;
        
        //hide bottom bar below screen
       _bottomBarView.frame = CGRectMake(_bottomBarView.frame.origin.x,
                                          _screenHeight,
                                          _bottomBarView.frame.size.width,
                                          _bottomBarView.frame.size.height);
        
    }
    else {
        // if bottomscroll is scrolled up till 70% of the screen, then set the bottomscroll y offset to 70% (calculated by screen height(headerImageViewHeight) * 0.70 as below).
        if (percentage >= 0.70) {
            
            [self.bottomScroll setContentOffset:CGPointMake(0, 0.70 * _screenHeight)];

            _logoutButton.alpha = 1.0;
            
            //_stackViewUserDetails.alpha = 1 - percentage;
            _stackViewUserDetails.hidden = YES;
            
            //hide bottom bar below screen
            _bottomBarView.frame = CGRectMake(_bottomBarView.frame.origin.x,
                                              bottombarViewOriginalYPosition,
                                              _bottomBarView.frame.size.width,
                                              _bottomBarView.frame.size.height);
        }
        else {
            // Fade/unfade logout button on scroll down/up resp.
            _logoutButton.alpha = percentage;
            _logoutButton.hidden = NO;
            
            _stackViewUserDetails.alpha = 1 - percentage;
            _stackViewUserDetails.hidden = NO;

            
            //slide bottombar view
            if (direction == UP && divisionCounter > (_screenHeight - _bottomBarView.frame.size.height)) {
                divisionCounter -= 0.786;
            }
            else {
                divisionCounter += 0.786;
            }
            
          //  NSLog(@"divisionCounter ==> %f", divisionCounter);

            // CGFloat yPosition = bottombarViewOriginalYPosition + divisionCounter;
            
            _bottomBarView.frame = CGRectMake(_bottomBarView.frame.origin.x,
                                              divisionCounter,
                                              _bottomBarView.frame.size.width,
                                              _bottomBarView.frame.size.height);

        }
        //self.yoffset = self.bottomScroll.contentOffset.y*0.3;
        //self.yoffset = 171;
        [self.topScroll setContentOffset:CGPointMake(scrollView.contentOffset.x,0) animated:NO];
        
        _headerImageViewHeight.constant = _screenHeight - self.bottomScroll.contentOffset.y;
        
    }
   

    
}

#define kVerySmallValue (0.000001)

- (Direction)getScrollDirection:(double)currentYOffset {
    
    Direction direction;

        if((_lastScrollOffset - currentYOffset) > kVerySmallValue) {
            direction = DOWN;
        }
        else {
            direction = UP;
        }

    return direction;
}

// launch accountsHome screen
- (IBAction)showMyAccounts:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    //let vc = storyboard.instantiateViewController(withIdentifier: "AccountsHomeVC") as! AccountsHomeVC
    [[self navigationController] pushViewController:vc animated:NO];
    //self.navigationController?.pushViewController(vc, animated: false)
}

- (IBAction)logoutButtonClicked:(UIButton *)sender {
    
}


// Bottombar methods

- (IBAction)showInfo:(UIButton *)sender {
    
    [self showApplicationInformation];
}


- (void)showApplicationInformation {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Kofax Bank" message:@"Version 1.0" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)contactUs:(UIButton *)sender {
    [self sendEmail];
}

- (void)sendEmail {
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"Customer: Lucy Tate - "];
        [mailer setToRecipients:[NSArray arrayWithObject:@"rupali.ghate@kofax.com"]];
        [mailer setMessageBody:@"" isHTML:NO];
        
        
        [mailer setModalPresentationStyle:UIModalPresentationFormSheet];
        
        //[self presentViewController:mailer animated:YES completion:nil];

        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        NSLog(@"Cannot send email.");
    }
    
}
//MailComposeController delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)showLocations:(UIButton *)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Map"];
    
    [self presentViewController:vc animated:YES completion:nil];
}


- (IBAction)showUserProfile:(UIButton *)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    
    [self presentViewController:vc animated:YES completion:nil];
}


@end
