//
//  SLAudioPlayer.h
//
//
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLAudioPlayer : NSObject
@property (assign, nonatomic) CMTime seekTime;
- (instancetype)initWithAudioFile:(NSString *)filePath;

@property (assign, nonatomic)BOOL autoPlayOff;
- (void)releaseAudioPlayer;
- (void)playSound;
- (void)pauseSound;
- (BOOL)isPlaying;
- (void)restartAudioPlayer;
- (void)updateSongVolume:(CGFloat)volume;
- (void)seekAudioPlayer:(CMTime)seekTime;


@end
