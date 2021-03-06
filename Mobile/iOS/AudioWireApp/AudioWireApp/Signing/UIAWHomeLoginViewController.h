#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"

@interface UIAWHomeLoginViewController : UIViewController <UITextFieldDelegate, FBLoginViewDelegate>
{
    FBLoginView *theLoginView;
    UIAlertView *subscribedFB;
    
    NSString *urlAvatarFacebook;
    id<FBGraphUser> userCached;
}
@property (assign) BOOL requireLogin;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UIImageView *im_logo;
@property (weak, nonatomic) IBOutlet UIImageView *im_nssn_logo;
@property (weak, nonatomic) IBOutlet UIButton *bt_subscribe;
@property (weak, nonatomic) IBOutlet UIButton *bt_login;
@property (weak, nonatomic) IBOutlet UIButton *bt_lostPassword;
@property (weak, nonatomic) IBOutlet UIButton *bt_help;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UILabel *lb_email;
@property (weak, nonatomic) IBOutlet UILabel *lb_password;
@property (weak, nonatomic) IBOutlet UILabel *lb_or;
@property (weak, nonatomic) IBOutlet UITextField *tf_email;
@property (weak, nonatomic) IBOutlet UITextField *tf_password;
@property (weak, nonatomic) IBOutlet UIScrollView *sc_scroll;
@property (weak, nonatomic) IBOutlet UIView *v_buttonFacebook;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act_facebook;

//@property (strong, nonatomic) PLGTutoViewController *tutoMasterView;

@property (assign) BOOL isSignedOut;

- (IBAction)click_subscribe:(id)sender;
- (IBAction)click_login:(id)sender;
- (IBAction)click_lostPassword:(id)sender;
- (void) selectResponder;
- (IBAction)startEditing:(UITextField *)sender;
- (IBAction)endEditing:(UITextField *)sender;

@end
