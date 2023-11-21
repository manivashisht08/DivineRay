//
//  AddSoundTableCell.h

#import <UIKit/UIKit.h>

@class SLMusicData;



@protocol AddSoundDelegate <NSObject>
- (void)soundIndexDidClicked:(NSInteger)index;
@end

@interface AddSoundTableCell : UITableViewCell
@property (assign, nonatomic) NSInteger audioIndex;
- (void)configureMusicCell:(SLMusicData *)musicModel;
- (void)updateAudioCellWithInfo:(SLMusicData *)musicModel;


- (void)updateMusicPlayingCell:(BOOL)isPlaying;
@property (assign, nonatomic) id<AddSoundDelegate> delegate;

@end

