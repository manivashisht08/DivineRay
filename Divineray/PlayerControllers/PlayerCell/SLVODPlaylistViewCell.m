//
//  SLVODPlaylistViewCell.m
//  Divineray
//
//  Created by ""  on 25/11/18.
//

#import "SLVODPlaylistViewCell.h"
#import "UIImageView+WebCache.h"
#import "VideoUtilities.h"
#import "SLAudioScrollingView.h"
#import "Masonry.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define kDuration 34.0
#define kTrans SCREEN_WIDTH/kDuration

@interface SLVODPlaylistViewCell () {
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btStop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *normalitleConst;
@property (strong, nonatomic, nullable) SLAudioScrollingView *textScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleContst;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (strong, nonatomic) NSDictionary *videoDict;

@end

@implementation SLVODPlaylistViewCell

- (void)awakeFromNib {
    [super awakeFromNib];//
    
    self.likeBtn.image = [UIImage imageNamed:@"htS"];;
    
    self.titleLbl.textColor =  [UIColor whiteColor];
    self.titleLbl.numberOfLines =  10;
    self.btStop.constant =  55.0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        self.btStop.constant =  55.0 + bottomPadding ;
    }
    _cellItemIndex = 0;
}

- (void)configurePlaylistCell:(NSDictionary *)dict withSims:(BOOL)isAnimate{
    [self layoutIfNeeded];
    if([dict valueForKey:@"media"] != nil) {
        [_posterImage sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"thumbImage"]]
                        placeholderImage:[UIImage imageNamed:@"logo1"]];
        _posterImage.contentMode = UIViewContentModeScaleAspectFill;
        self.leftView.hidden = YES;
        self.normaltitleLbl.text = [dict valueForKey:@"description"];
        if([dict valueForKey:@"title"] && [[dict valueForKey:@"title"] isKindOfClass:[NSString class]]) {
            self.titleLbl.text = [dict valueForKey:@"title"];
        }else {
            self.titleLbl.text = @"--------";
        }
        self.normaltitleLbl.numberOfLines = 10l;
        self.titleLbl.numberOfLines = 10l;
        CGFloat tagHeight =  [VideoUtilities getLabelHeight: self.titleLbl];
        if(tagHeight < 20)
            tagHeight =  20;
        self.titleContst.constant =  tagHeight;
        CGFloat tagHeightNormal =  [VideoUtilities getLabelHeight: self.normaltitleLbl];
        if(tagHeightNormal < 20)
            tagHeightNormal =  20;
        self.normalitleConst.constant =  tagHeightNormal;
        
    }else  {
        [_posterImage sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"postImage"]]
                        placeholderImage:[UIImage imageNamed:@"logo1"]];
        _posterImage.frame =  CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        BOOL aspectFill = YES;
        NSString *width = [dict valueForKey:@"postWidth"];
        NSString *height = [dict valueForKey:@"postHeight"];
        if(width && height) {
            if([VideoUtilities calculateMode:width withHeight:height] == UIViewContentModeScaleAspectFill) {
                aspectFill = YES;
            }else {
                aspectFill = NO;
            }
        }
        if(aspectFill) {
            _posterImage.contentMode = UIViewContentModeScaleAspectFill;
        }
        else {
            _posterImage.contentMode = UIViewContentModeScaleAspectFit;
        }
        _posterImage.backgroundColor = [UIColor clearColor];
        NSDictionary *dictUserDetails = [dict valueForKey:@"userDetails"];
        [_profileImageView sd_setImageWithURL:[NSURL URLWithString:[dictUserDetails valueForKey:@"photo"]]
                             placeholderImage:[UIImage imageNamed:@"user"]];
        self.normaltitleLbl.text = [dict valueForKey:@"description"];
        if([dict valueForKey:@"tags"] && [[dict valueForKey:@"tags"] isKindOfClass:[NSString class]]) {
            if([[dict valueForKey:@"tags"] hasPrefix:@"#"]){
                self.titleLbl.text = [dict valueForKey:@"tags"];
            }else{
                self.titleLbl.text = [NSString stringWithFormat:@"#%@",[dict valueForKey:@"tags"]];
            }
        }else {
            self.titleLbl.text = @"--------";
        }
        self.normaltitleLbl.numberOfLines = 10l;
        self.titleLbl.numberOfLines = 10l;
        CGFloat tagHeight =  [VideoUtilities getLabelHeight: self.titleLbl];
        if(tagHeight < 20)
            tagHeight =  20;
        self.titleContst.constant =  tagHeight;
        CGFloat tagHeightNormal =  [VideoUtilities getLabelHeight: self.normaltitleLbl];
        if(tagHeightNormal < 20)
            tagHeightNormal =  20;
        self.normalitleConst.constant =  tagHeightNormal;
        self.viewCountLbl.text = [dict valueForKey:@"totalViews"];
        self.likeCountLbl.text = [dict valueForKey:@"totalLike"];
        self.shareCountlbl.text = [dict valueForKey:@"totalShare"];
        self.commentLbl.text = [dict valueForKey:@"totalComments"];
        
        if([[dict valueForKey:@"isLiked"] intValue] == 0){
            self.likeBtn.selected = NO;
        }else {
            self.likeBtn.selected = YES;
        }
        if(isAnimate) {
            NSString *nsf = @"";
            if([dictUserDetails valueForKey:@"name"]) {
                nsf = [dictUserDetails valueForKey:@"name"];
            }
            NSString *usetName = [NSString stringWithFormat:@"original voice - %@", nsf];
            
            if([dict valueForKey:@"musicId"] && ![[dict valueForKey:@"musicId"] isEqualToString:@""]  && [[dict valueForKey:@"musicName"] isKindOfClass:[NSString class]] && ![[dict valueForKey:@"musicName"] isEqualToString:@""]) {
                usetName = [NSString stringWithFormat:@"Music - %@", [dict valueForKey:@"musicName"]];
            }
            __weak typeof(self) _self = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createSroollingText:usetName];
                [_self  startLogoSpin:YES];
            });
        }
    }
    [self layoutIfNeeded];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updatePlayerView:(UIView*)playerContainerView {
    [_posterImage addSubview:playerContainerView];
    playerContainerView.frame =  CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
}

- (void)updateRecordingStatusPaused:(BOOL)hasPaused {
    
}


- (void)hideCoverImage {
    self.posterImage.alpha = 0.0;
}
- (void)createSroollingText:(NSString *)marqueText {
    
    if (self.textScrollView && [self.textScrollView superview]) {
        [self.textScrollView  removeFromSuperview];
    }
    self.textScrollView = nil;
    self.textScrollView = [[SLAudioScrollingView alloc]init];
    [self.audioContainerView addSubview:_textScrollView];
    [self.textScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.audioContainerView);
    }];
    
    _textScrollView.text = marqueText;
}
- (void)startLogoSpin:(BOOL)isPlaying {
    if(isPlaying) {
        [_textScrollView startOrResumeAnimate];
    }
}

- (void)stopLogoSpin {
    [_textScrollView pauseAnimate];
}

@end
