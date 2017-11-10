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

@interface HomeVC ()<MFMailComposeViewControllerDelegate>


@property(nonatomic, weak) IBOutlet UIImageView *bannerBackgroundImage;

@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property(nonatomic, weak)  IBOutlet NSLayoutConstraint *bannerViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerContentsViewHeight;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UIStackView *stackViewUserDetails;

@property (weak, nonatomic) IBOutlet UIView *bottomBarView;


@property (weak, nonatomic) IBOutlet UIView *bannerDetailsView;

@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@property(nonatomic, assign) double topScrollOffset;

@property(nonatomic, assign) double bottomScrollOffset;

@property(nonatomic, assign) double bannerInnerOffset;

@property(nonatomic, assign) double screenHeight;   //??


@end


@implementation HomeVC

UIPanGestureRecognizer *panGestureRecognizer;

const double BANNER_AREA_PERCENT = 40.0;

double divisionCounter;

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //for iOS 10
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self setupPanGestureRecognizerOnBannerView];
    
    [self initScreenParams];
}

-(void) setupPanGestureRecognizerOnBannerView {
    panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(move:)];
    
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [_bannerView addGestureRecognizer:panGestureRecognizer];
}

- (void)initScreenParams {
    
    _screenHeight = UIScreen.mainScreen.bounds.size.height;
    
    //calculate height of banner based on decided percentage w.r.t. main screen height
    _topScrollOffset = BANNER_AREA_PERCENT/100 * _screenHeight;
    
    //canculate bottom offset upto where banner can be dragged down (in this case upto the beginning of bottom bar).
    _bottomScrollOffset = _bottomBarView.frame.origin.y;
    
    //inner offset is the bottom space(gap) between bannerContentView and banner view.
    _bannerInnerOffset = _bannerViewHeight.constant -_bannerContentsViewHeight.constant;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    //set initial height of banner while launching screen
    _bannerViewHeight.constant = _topScrollOffset;
    //adjest height of bannerContentView as per the new height of bannerView
    _bannerContentsViewHeight.constant = _bannerViewHeight.constant - _bannerInnerOffset;
    
    _stackViewUserDetails.alpha = 0;
    _visualEffectView.alpha = 0.27;
}

#pragma mark: PanGestureRecognizer selector action

-(void)move:(UIPanGestureRecognizer*)sender {
    CGPoint currentPoint = [panGestureRecognizer locationInView:self.bannerView.superview];
    
    double offset=currentPoint.y;
    double percentage=offset/_screenHeight;
    
    if (percentage >= 0.70) {
        _stackViewUserDetails.alpha = 1.0;
    } else {
        if (percentage <= 0.30) {
            _stackViewUserDetails.alpha = 0.0;
        } else {
            _stackViewUserDetails.alpha = percentage;
        }
    }
//    printf("Percentage ==> %f", percentage);
    
    _visualEffectView.alpha=fabs(percentage);
    
    // update heights of banner-view and banner-content-view as per pan value on screen
    [UIView animateWithDuration:0.01f
                     animations:^{
                         if ((currentPoint.y > _topScrollOffset) && (currentPoint.y <= _bottomScrollOffset)) {
                             _bannerViewHeight.constant = currentPoint.y;
                             _bannerContentsViewHeight.constant = _bannerViewHeight.constant - _bannerInnerOffset;
                         }
                     }];
}

// launch accountsHome screen
- (IBAction)showMyAccounts:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    [[self navigationController] pushViewController:vc animated:NO];
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
