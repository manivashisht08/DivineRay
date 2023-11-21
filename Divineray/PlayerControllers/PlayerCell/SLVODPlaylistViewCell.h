//
//  SLVODPlaylistViewCell.h
//  Divineray
//
//  Created by ""  on 25/11/18.
//

#import <UIKit/UIKit.h>
#import "STTweetLabel.h"
#import "SYFavoriteButton.h"

@interface SLVODPlaylistViewCell : UICollectionViewCell {
    
}
@property (weak, nonatomic) IBOutlet UIButton *flagBtn;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *viewImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewCountLbl;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLbl;
@property (weak, nonatomic) IBOutlet SYFavoriteButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UIView *audioContainerView;

@property (weak, nonatomic) IBOutlet UILabel *shareCountlbl;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet STTweetLabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *normaltitleLbl;
@property (weak, nonatomic) IBOutlet UIButton *playerBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentLbl;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *musicBtn;

@property (assign, nonatomic) NSInteger cellItemIndex;
- (void)updatePlayerView:(UIView*)playerView;
- (void)updateRecordingStatusPaused:(BOOL)hasPaused;
- (void)hideCoverImage;
- (void)startLogoSpin:(BOOL)isPlaying;
- (void)configurePlaylistCell:(NSDictionary *)dict withSims:(BOOL)isAnimate;
- (void)stopLogoSpin;
@end
