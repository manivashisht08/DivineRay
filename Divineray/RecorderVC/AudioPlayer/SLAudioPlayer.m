//
//  SLAudioPlayer.m
//
//

#import "SLAudioPlayer.h"

@interface SLAudioPlayer() {
  AVPlayerItem *audioPlayerItem;
}

@property (strong, nonatomic) NSString *soundFilePath;
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, assign) BOOL audioHasInitialized;
@property (nonatomic, assign) CGFloat volume;       // default is 1
@property (strong, nonatomic) AVURLAsset *asset;
@end

@implementation SLAudioPlayer

- (instancetype)initWithAudioFile:(NSString *)filePath {
    self = [super init];
    _audioPlayer = [[AVPlayer alloc ]init];
    _volume = 1;
     [_audioPlayer setVolume:_volume];
    _soundFilePath = filePath;
    _seekTime = kCMTimeZero;
    [self createPlayer];
    return self;
}

#pragma mark - Audio Functionality
- (void)playMusic {
    if (![_soundFilePath isEqualToString:@""]) {
        if (_audioPlayer.rate ==0) {
            [_audioPlayer play];
        } else {
            [_audioPlayer pause];
        }
    }
}
- (void)createPlayer {
    
   // [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    
    _soundFilePath = [NSString stringWithFormat:@"%@",_soundFilePath];
    NSURL *url = [[NSURL alloc] initFileURLWithPath: _soundFilePath];
    
    self.asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:_asset];
    _audioPlayer = [AVPlayer playerWithPlayerItem:anItem];
    [_audioPlayer setVolume:1.0];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_audioPlayer currentItem]];
    [_audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
}

- (void)releaseAudioPlayer {
    @try {
        if(_audioPlayer){
            [_audioPlayer pause];
            [_audioPlayer removeObserver:self forKeyPath:@"status"];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    } @catch (NSException *exception) {
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    if (_soundFilePath) {
        [_audioPlayer seekToTime:kCMTimeZero];
        [_audioPlayer play];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (_audioPlayer.status == AVPlayerStatusFailed) {
        } else if (_audioPlayer.status == AVPlayerStatusReadyToPlay) {
            if (_autoPlayOff) {
                [_audioPlayer pause];
            }
            _audioHasInitialized=YES;
        }
    }
}
- (void)playSound {
    [_audioPlayer play];
}
- (void)pauseSound {
    [_audioPlayer pause];
}

- (BOOL)isPlaying {
    if(!self.audioPlayer) return NO;
    return (self.audioPlayer.rate != 0.0);
}

- (void)restartAudioPlayer {
    if (_soundFilePath) {
        [_audioPlayer seekToTime:_seekTime];
        [_audioPlayer play];
    }
}

- (void)updateSongVolume:(CGFloat)volume {
      _volume = volume;
    if (_volume <=0.0f) {
        self.audioPlayer.muted = YES;
    } else {
        self.audioPlayer.muted = NO;
        [self.audioPlayer setVolume:_volume];
    }
    NSArray *audioTracks = [_asset tracksWithMediaType:AVMediaTypeAudio];
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];

}


- (void)seekAudioPlayer:(CMTime)seekTime {
    if (_soundFilePath) {
        _seekTime = seekTime;
        [_audioPlayer seekToTime:_seekTime];
    }
}
@end
