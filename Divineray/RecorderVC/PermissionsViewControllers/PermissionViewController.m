//
//  PermissionViewController.m
//  Vivek Dharmai
//
//  Created by     on 28/02/19.
//

#import "PermissionViewController.h"
#import "MHGetPermission.h"

@interface PermissionViewController ()
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UIImageView *microIcon;
@property (weak, nonatomic) IBOutlet UIImageView *camIcon;
@property (weak, nonatomic) IBOutlet UIView *internalView;
@property (weak, nonatomic) IBOutlet UIView *camView;
@property (weak, nonatomic) IBOutlet UIView *microPhoneView;
@property (weak, nonatomic) IBOutlet UIButton *allowActionBtn;

@end

@implementation PermissionViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUIAndAction];
}
-(void)setUIAndAction
{
    

        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if(appName)
        {
        self.messageLbl.text = [NSString stringWithFormat:@"%@ needs access to your camera, and microphone to able to create video or to live broadcast",appName];
        }else
        {
            self.messageLbl.text = @"Needs access to your camera, and microphone to able to create video or to live broadcast";
        }
    
//    self.camIcon.image = SLKlugSharedImagePath(@"photoCamera3");
//    self.microIcon.image = SLKlugSharedImagePath(@"microphoneBlackShape");
    self.allowActionBtn.layer.cornerRadius =    self.allowActionBtn.frame.size.height/2;
    self.allowActionBtn.layer.borderWidth =  1.0;
    self.allowActionBtn.layer.borderColor = [UIColor colorWithRed:173.0/255.0 green:173.0/255.0 blue:173.0/255.0 alpha:1].CGColor;
    self.allowActionBtn.clipsToBounds = YES;
    [self setpermissionColor];
    
}
-(void)setpermissionColor
{
//    if(self.isVideoAuthorize)
//    {
//        self.camView.backgroundColor =  [UIColor greenColor];
//    }else
//    {
        self.camView.backgroundColor =  [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1];
    //}
//    if(self.isAudioAuthorize)
//    {
//    self.microPhoneView.backgroundColor =  [UIColor greenColor];
//    }else
//    {
    self.microPhoneView.backgroundColor =  [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1];
   // }
}
- (IBAction)allowAcessBtnAction:(id)sender
{
    if(!self.isVideoAuthorize && !self.isAudioAuthorize)
    {
    [MHGetPermission getCaptureAndRecodPermission:^(BOOL hasCapturePermiss, BOOL asRecodPermiss)
     {
         self.isAudioAuthorize = asRecodPermiss;
         self.isVideoAuthorize = hasCapturePermiss;
         if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isAllowPopup"] intValue] == 1)
         {
             [self disMissWithBack];
         }else
         {
             [self disMissWithBack];

         }
         [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isAllowPopup"];
         [[NSUserDefaults standardUserDefaults]synchronize];
         
     }];
    }else if (!self.isAudioAuthorize)
    {
        [MHGetPermission getAudioRecordPermission:^(BOOL has) {
            self.isAudioAuthorize = has;
            self.isVideoAuthorize = YES;
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isAllowPopup"] intValue] == 1)
            {
                [self disMissWithBack];
            }
            else
            {
                [self disMissWithBack];
                
            }
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isAllowPopup"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }];
    }
    else if (!self.isVideoAuthorize)
    {
        [MHGetPermission getCaptureDevicePermission:^(BOOL has) {
            self.isAudioAuthorize = YES;
            self.isVideoAuthorize = has;
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isAllowPopup"] intValue] == 1)
            {
                [self disMissWithBack];
            }
            else
            {
                [self disMissWithBack];
                
            }
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isAllowPopup"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }];
    }
}

-(void)disMissWithBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(isPermissionDelegate:)])
        {
            if(self.isAudioAuthorize && self.isVideoAuthorize)
            {
            [self.delegate isPermissionDelegate:1];
            }
            else  if(!self.isAudioAuthorize)
            {
                [self.delegate isPermissionDelegate:2];
            }
            else  if(self.isAudioAuthorize && !self.isVideoAuthorize)
            {
                [self.delegate isPermissionDelegate:3];
            }else
            {
                [self.delegate isPermissionDelegate:4];
            }
        }
    }];
}
-(void)disMissMissDOnotAllow
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)hideAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
