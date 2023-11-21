//
//  SLPlayer.m
//  SLPlayer
//
//  Created by  on 16/6/28.
//  Copyright © 2016年 single. All rights reserved.
//

#import "SLPlayer.h"
#import "SLPlayerImp.h"
#import "SLPlayerMacro.h"
#import "SLPlayerNotification.h"
#import "SLDisplayView.h"
#import "SLAVPlayer.h"
#import "SLAudioManager.h"

@interface SLPlayer ()

@property (nonatomic, copy) NSURL * contentURL;
@property (nonatomic, assign) SLVideoType videoType;

@property (nonatomic, strong) SLDisplayView * displayView;
@property (nonatomic, assign) SLDecoderType decoderType;
@property (nonatomic, strong) SLAVPlayer * avPlayer;
@property (nonatomic, assign) BOOL needAutoPlay;
@property (nonatomic, assign) NSTimeInterval lastForegroundTimeInterval;
@end

@implementation SLPlayer


+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setupNotification];
        self.decoder = [SLPlayerDecoder decoderByDefault];
        self.contentURL = nil;
        self.videoType = SLVideoTypeNormal;
        self.backgroundMode = SLPlayerBackgroundModeAutoPlayAndPause;
        self.displayMode = SLDisplayModeNormal;
        self.viewGravityMode = SLGravityModeResizeAspect;
        self.playableBufferInterval = 2.f;
        self.viewAnimationHidden = YES;
        self.volume = 1;
        self.displayView = [SLDisplayView displayViewWithAbstractPlayer:self];
    }
    return self;
}

- (void)replaceVideoWithURL:(nullable NSURL *)contentURL {
    [self replaceVideoWithURL:contentURL videoType:SLVideoTypeNormal];
}


- (void)replaceVideoWithURL:(nullable NSURL *)contentURL videoType:(SLVideoType)videoType
{
    self.error = nil;
    self.contentURL = contentURL;
    self.decoderType = [self.decoder decoderTypeForContentURL:self.contentURL];
    self.videoType = videoType;
    switch (self.videoType)
    {
        case SLVideoTypeNormal:
        case SLVideoTypeVR:
            break;
        default:
            self.videoType = SLVideoTypeNormal;
            break;
    }
    
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:{
            
            if (!self.avPlayer) {
                self.avPlayer =[SLAVPlayer playerWithAbstractPlayer:self];
            }
            [self.avPlayer replaceVideo];
        }
            break;
        case SLDecoderTypeFFmpeg:
        {
            [self.avPlayer stop];
            
            
        }
            break;
        case SLDecoderTypeError:
        {
            [self.avPlayer stop];
            
        }
            break;
    }
}

- (void)play
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            [self.avPlayer play];
            break;
        case SLDecoderTypeFFmpeg:
            
            break;
        case SLDecoderTypeError:
            break;
    }
}

- (void)pause
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            [self.avPlayer pause];
            break;
        case SLDecoderTypeFFmpeg:
            
            break;
        case SLDecoderTypeError:
            break;
    }
}

- (void)stop
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self replaceVideoWithURL:nil];
}

- (BOOL)seekEnable
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.seekEnable;
            break;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.seekEnable;
        case SLDecoderTypeError:
            return NO;
    }
}

- (BOOL)seeking
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.seeking;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.seeking;
        case SLDecoderTypeError:
            return NO;
    }
}

- (void)seekToTime:(NSTimeInterval)time
{
    [self seekToTime:time completeHandler:nil];
}

- (void)seekToTime:(NSTimeInterval)time completeHandler:(nullable void (^)(BOOL))completeHandler
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            [self.avPlayer seekToTime:time completeHandler:completeHandler];
            break;
        case SLDecoderTypeFFmpeg:
            [self.avPlayer seekToTime:time completeHandler:completeHandler];
            break;
        case SLDecoderTypeError:
            break;
    }
}

- (void)setVolume:(CGFloat)volume
{
    _volume = volume;
    [self.avPlayer reloadVolume];
    
}

- (void)setPlayableBufferInterval:(NSTimeInterval)playableBufferInterval
{
    _playableBufferInterval = playableBufferInterval;
}

- (void)setViewGravityMode:(SLGravityMode)viewGravityMode
{
    _viewGravityMode = viewGravityMode;
    [self.displayView reloadGravityMode];
}

- (SLPlayerState)state
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.state;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.state;
        case SLDecoderTypeError:
            return SLPlayerStateNone;
    }
}

- (CGSize)presentationSize
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.presentationSize;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.presentationSize;
        case SLDecoderTypeError:
            return CGSizeZero;
    }
}

- (NSTimeInterval)bitrate
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.bitrate;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.bitrate;
        case SLDecoderTypeError:
            return 0;
    }
}

- (NSTimeInterval)progress
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.progress;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.progress;
        case SLDecoderTypeError:
            return 0;
    }
}

- (NSTimeInterval)duration
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.duration;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.duration;
        case SLDecoderTypeError:
            return 0;
    }
}

- (NSTimeInterval)playableTime
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.playableTime;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.playableTime;
        case SLDecoderTypeError:
            return 0;
    }
}


- (SLPLFView *)view
{
    return self.displayView;
}

- (void)setError:(SLError * _Nullable)error
{
    if (self.error != error) {
        self->_error = error;
    }
}

- (void)cleanPlayer
{
    [self.avPlayer stop];
    self.avPlayer = nil;
    [self cleanPlayerView];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.needAutoPlay = NO;
    self.error = nil;
}

- (void)cleanPlayerView
{
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof SLPLFView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

- (void)dealloc
{
    SLPlayerLog(@"SLPlayer release");
    [self cleanPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SLAudioManager manager] removeHandlerTarget:self];
}

#pragma mark - background mode
- (void)setupNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    SLWeakSelf
    SLAudioManager * manager = [SLAudioManager manager];
    [manager setHandlerTarget:self interruption:^(id handlerTarget, SLAudioManager *audioManager, SLAudioManagerInterruptionType type, SLAudioManagerInterruptionOption option) {
        SLStrongSelf
        if (type == SLAudioManagerInterruptionTypeBegin) {
            switch (strongSelf.state) {
                case SLPlayerStatePlaying:
                case SLPlayerStateBuffering:
                {
                    // fix : maybe receive interruption notification when enter foreground.
                    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
                    if (timeInterval - strongSelf.lastForegroundTimeInterval > 1.5) {
                        [strongSelf pause];
                    }
                }
                    break;
                default:
                    break;
            }
        }
    } routeChange:^(id handlerTarget, SLAudioManager *audioManager, SLAudioManagerRouteChangeReason reason) {
        SLStrongSelf
        if (reason == SLAudioManagerRouteChangeReasonOldDeviceUnavailable) {
            switch (strongSelf.state) {
                case SLPlayerStatePlaying:
                case SLPlayerStateBuffering:
                {
                    [strongSelf pause];
                }
                    break;
                default:
                    break;
            }
        }
    }];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    switch (self.backgroundMode) {
        case SLPlayerBackgroundModeNothing:
        case SLPlayerBackgroundModeContinue:
            break;
        case SLPlayerBackgroundModeAutoPlayAndPause:
        {
            switch (self.state) {
                case SLPlayerStatePlaying:
                case SLPlayerStateBuffering:
                {
                    self.needAutoPlay = YES;
                    [self pause];
                }
                    break;
                default:
                    break;
            }
        }
            break;
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    switch (self.backgroundMode) {
        case SLPlayerBackgroundModeNothing:
        case SLPlayerBackgroundModeContinue:
            break;
        case SLPlayerBackgroundModeAutoPlayAndPause:
        {
            switch (self.state) {
                case SLPlayerStateSuspend:
                {
                    if (self.needAutoPlay) {
                        self.needAutoPlay = NO;
                        [self play];
                        self.lastForegroundTimeInterval = [NSDate date].timeIntervalSince1970;
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
    }
}
@end


#pragma mark - Tracks Category

@implementation SLPlayer (Tracks)

- (BOOL)videoEnable
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.videoEnable;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.videoEnable;
        case SLDecoderTypeError:
            return NO;
    }
}

- (BOOL)audioEnable
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.audioEnable;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.audioEnable;
        case SLDecoderTypeError:
            return NO;
    }
}

- (SLPlayerTrack *)videoTrack
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.videoTrack;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.videoTrack;
        case SLDecoderTypeError:
            return nil;
    }
}

- (SLPlayerTrack *)audioTrack
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.audioTrack;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.audioTrack;
        case SLDecoderTypeError:
            return nil;
    }
}

- (NSArray<SLPlayerTrack *> *)videoTracks
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.videoTracks;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.videoTracks;
        case SLDecoderTypeError:
            return nil;
    }
}

- (NSArray<SLPlayerTrack *> *)audioTracks
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return self.avPlayer.audioTracks;
        case SLDecoderTypeFFmpeg:
            return self.avPlayer.audioTracks;
        case SLDecoderTypeError:
            return nil;
    }
}

- (void)selectAudioTrack:(SLPlayerTrack *)audioTrack
{
    [self selectAudioTrackIndex:audioTrack.index];
}

- (void)selectAudioTrackIndex:(int)audioTrackIndex
{
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            [self.avPlayer selectAudioTrackIndex:audioTrackIndex];
        case SLDecoderTypeFFmpeg:
            [self.avPlayer selectAudioTrackIndex:audioTrackIndex];
            break;
        case SLDecoderTypeError:
            break;
    }
}

@end


#pragma mark - Thread Category

@implementation SLPlayer (Thread)

- (BOOL)videoDecodeOnMainThread {
    switch (self.decoderType)
    {
        case SLDecoderTypeAVPlayer:
            return NO;
        case SLDecoderTypeFFmpeg:
            return NO;
        case SLDecoderTypeError:
            return NO;
    }
}

- (BOOL)audioDecodeOnMainThread {
    return NO;
}



@end
