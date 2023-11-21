//
//  AddSoundTableCell.m


#import "AddSoundTableCell.h"
#import "SLMusicData.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "ZScrollLabel.h"

@interface AddSoundTableCell() {
    
}
@property (weak, nonatomic) IBOutlet ZScrollLabel *titleScroll;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingOffset;
@property (weak, nonatomic) IBOutlet UIButton *selectedMusic;
@property (weak, nonatomic) IBOutlet UIImageView *musicImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoader;
@property (weak, nonatomic) IBOutlet UIView *loaderContainer;

@end

@implementation AddSoundTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.hidden = YES;
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
     [_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    _selectedMusic.layer.cornerRadius = 5;
    _selectedMusic.layer.masksToBounds = YES;
    _selectedMusic.layer.borderWidth = 1;
    _selectedMusic.layer.borderColor = [UIColor whiteColor].CGColor;
    _loaderContainer.hidden = YES;
    [_activityLoader startAnimating];
    self.titleScroll.textColor = [UIColor blackColor];
    [self.titleScroll setFont:[UIFont systemFontOfSize:15]];
}

- (void)animateSelectedButton:(SLMusicData *)musicModel {
    _selectedMusic.hidden = YES;
    _trailingOffset.constant = -300;
    [self layoutIfNeeded];
    
    __weak typeof(self) _self = self;
    if (musicModel.isSelected) {
        _selectedMusic.hidden = NO;
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                _self.trailingOffset.constant = 10;
                                [_self layoutIfNeeded];
                            }
                         completion:^(BOOL finished) {
                             //Completion Block
                         }];
    }
    [self.musicImageView setNeedsDisplay];
     [_loaderContainer bringSubviewToFront:_activityLoader];
}

- (void)updateAudioCellWithInfo:(SLMusicData *)musicModel {
    _playButton.hidden = NO;
    if (musicModel.playerState == SLAudioStatePlaying) {
        _loaderContainer.hidden = YES;
        [_playButton setSelected:YES];
    } else if (musicModel.playerState == SLAudioStatePaused) {
        _loaderContainer.hidden = YES;
        [_playButton setSelected:NO];
    } else if (musicModel.playerState == SLAudioStateLoading) {
        _loaderContainer.hidden = NO;
        [_activityLoader startAnimating];
        [self->_loaderContainer bringSubviewToFront:_activityLoader];
        self->_playButton.hidden = YES;
    }
}

- (void)configureMusicCell:(SLMusicData *)musicModel {

    
    self.titleScroll.text = musicModel.name;
    self.titleLabel.text = musicModel.name;
    _categoryLabel.text = musicModel.category;
    _playButton.userInteractionEnabled =false;
    [_musicImageView sd_setImageWithURL:[NSURL URLWithString:musicModel.iconPath]
                       placeholderImage:[UIImage imageNamed:@""]];
    [self updateAudioCellWithInfo:musicModel];
   [self animateSelectedButton:musicModel];

}

- (void)updateMusicPlayingCell:(BOOL)isPlaying {
    [_playButton setSelected:NO];
    if (isPlaying) {
        [_playButton setSelected:YES];
    }
}

- (IBAction)musicDidClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(soundIndexDidClicked:)]) {
        [self.delegate soundIndexDidClicked:_audioIndex];
    }
}


@end
