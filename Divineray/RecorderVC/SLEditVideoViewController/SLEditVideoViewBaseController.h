//
//  SLEditVideoViewBaseController.h
//  Divinerayly
//
//  Created by ""  on 08/03/19.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SLActivePopupView)  {
    SLActivePopupViewMixer = 1,
    SLActivePopupViewCropMusic,
    SLActivePopupViewFilter,
    SLActivePopupViewNone
};
typedef void (^MusicCompletionBllock)(id musicPath, id fileTitle, BOOL isSucess);
@interface SLEditVideoViewBaseController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *gmpuImageContainer;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *addSoundButton;
@property (weak, nonatomic) IBOutlet UIButton *equlizerButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *virticalView;
@property (weak, nonatomic) IBOutlet UIButton *cutSoundButton;
@property (nonatomic, assign) SLActivePopupView activePopupView;
@property (copy, nonatomic) MusicCompletionBllock completionBlock;


- (void)setupOutletsUI;
- (void)_hidePopupViews;
- (void)_showHeaderFooterMenus;

@end

