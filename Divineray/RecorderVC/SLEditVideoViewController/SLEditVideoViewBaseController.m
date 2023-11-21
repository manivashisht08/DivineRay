//
//  SLEditVideoViewBaseController.m
//  Divinerayly
//
//  Created by ""  on 08/03/19.
//

#import "SLEditVideoViewBaseController.h"
#import "SLGlobalShared.h"
#import "UIView+Tools.h"


@interface SLEditVideoViewBaseController ()

@end

@implementation SLEditVideoViewBaseController

- (void)setupOutletsUI {
    
    [_cutSoundButton setImage:[UIImage imageNamed:@"musicCut.png"] forState:UIControlStateNormal];
//    [_backButton setImage:[UIImage imageNamed:@"popup_close.png"] forState:UIControlStateNormal];
//    _backButton.showsTouchWhenHighlighted = YES;
    
    [_addSoundButton setImage:[UIImage imageNamed:@"compact_disc.png"] forState:UIControlStateNormal];
    [_equlizerButton setImage:[UIImage imageNamed:@"equalizer.png"] forState:UIControlStateNormal];
    
    _nextButton.layer.cornerRadius = 2.0;
    _nextButton.layer.masksToBounds = YES;
    _nextButton.showsTouchWhenHighlighted = YES;
    _nextButton.layer.borderColor = [UIColor colorWithRed:27.0/255.0 green:66.0/255.0 blue:141.0/255.0 alpha:1.0].CGColor;
    _nextButton.layer.borderWidth = 2;
    [_nextButton setTitleColor:[UIColor colorWithRed:27.0/255.0 green:66.0/255.0 blue:141.0/255.0 alpha:1.0] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

/**
 Popviews
 */
- (void)_hidePopupViews {
    [self.headerView Divineray_fadeOut];
    [self.virticalView Divineray_fadeOut];
}

- (void)_showHeaderFooterMenus {
    [self.headerView Divineray_fadeIn];
    [self.virticalView Divineray_fadeIn];
}


@end
