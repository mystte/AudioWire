//
//  OptionsViewController.m
//  AudioWireApp
//
//  Created by Derivery Guillaume on 8/5/13.
//  Copyright (c) 2013 Derivery Guillaume. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "OptionsViewController.h"
#import "AWUserManager.h"

@implementation OptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Options", @"");
        needASubPlayer = NO;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!IS_OS_7_OR_LATER)
    {
        CGRect rectTopView = self.topView.frame;
        rectTopView.origin.y = 31;
        rectTopView.size.height += 31;
        
        [self.topView setFrame:rectTopView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpOptionViews];
}

-(void)setUpOptionViews
{
    [_topView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
    [_bottomView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
    
    _topView.layer.cornerRadius = 10;
    _bottomView.layer.cornerRadius = 10;
    
    _topView.layer.borderColor = [[UIColor blackColor]CGColor];
    _bottomView.layer.borderColor = [[UIColor blackColor]CGColor];
    
    _topView.layer.borderWidth = 1;
    _bottomView.layer.borderWidth = 1;

    [_bt_signout setTitle:NSLocalizedString(@"Sign out", @"") forState:UIControlStateNormal];
    [_bt_userInfo setTitle:NSLocalizedString(@"Modify user information", @"") forState:UIControlStateNormal];
    [_firstOption setText:NSLocalizedString(@"Turn on active sync :", @"")];
    
    [_bt_userInfo.titleLabel setFont:FONTBOLDSIZE(14)];
    [_bt_signout.titleLabel setFont:FONTBOLDSIZE(15)];
    [_firstOption setFont:FONTSIZE(15)];
    
    NSString *format = [NSString stringWithFormat:@"%@\nMade for the EIP 2013\nv1.0 beta\nForum 2013", NSLocalizedString(@"AudioWire", @"")];
    
    [_bottomLabel setText:format];
    [_bottomLabel setFont:FONTSIZE(15)];
}

- (IBAction)switchValueChanged:(id)sender
{
    // TODO sync active ?
}

- (IBAction)click_signOut:(id)sender
{
    [FBSession.activeSession closeAndClearTokenInformation];
    
    [[AWUserManager getInstance] logOut:^(BOOL success, NSString *error)
    {
        if (success)
        {
            [[AWMusicPlayer getInstance] pause];
            [self.navigationController popViewControllerAnimated:TRUE];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:error delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (IBAction)click_userInfo:(id)sender
{
    // TODO userInfo
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
