//
//  SLPlayer.h
//  SLPlayer
//
//  Created by Single on 16/6/28.
//  Copyright © 2016年 single. All rights reserved.
//

#import "SLPlayerTrack.h"
#import "SLPlayerDecoder.h"
#import "SLPLFView.h"

// video type
typedef NS_ENUM(NSUInteger, SLVideoType) {
    SLVideoTypeNormal,  // normal
    SLVideoTypeVR,      // virtual reality
};

// player state
typedef NS_ENUM(NSUInteger, SLPlayerState) {
    SLPlayerStateNone = 0,          // none
    SLPlayerStateBuffering = 1,     // buffering
    SLPlayerStateReadyToPlay = 2,   // ready to play
    SLPlayerStatePlaying = 3,       // playing
    SLPlayerStateSuspend = 4,       // pause
    SLPlayerStateFinished = 5,      // finished
    SLPlayerStateFailed = 6,        // failed
};

// display mode
typedef NS_ENUM(NSUInteger, SLDisplayMode) {
    SLDisplayModeNormal,    // default
    SLDisplayModeBox,
};

// video content mode
typedef NS_ENUM(NSUInteger, SLGravityMode) {
    SLGravityModeResize,
    SLGravityModeResizeAspect,
    SLGravityModeResizeAspectFill,
};

// background mode
typedef NS_ENUM(NSUInteger, SLPlayerBackgroundMode) {
    SLPlayerBackgroundModeNothing,
    SLPlayerBackgroundModeAutoPlayAndPause,     // default
    SLPlayerBackgroundModeContinue,
};


#pragma mark - SLPlayer

@class SLError;

NS_ASSUME_NONNULL_BEGIN

@interface SLPlayer : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)player;

@property (nonatomic, strong) SLPlayerDecoder * decoder;      // default is [SLPlayerDecoder defaultDecoder]

@property (nonatomic, copy, readonly) NSURL * contentURL;
@property (nonatomic, assign, readonly) SLVideoType videoType;

@property (nonatomic, strong, readonly, nullable) SLError * error;

- (void)replaceVideoWithURL:(nullable NSURL *)contentURL;
- (void)replaceVideoWithURL:(nullable NSURL *)contentURL videoType:(SLVideoType)videoType;

// preview
@property (nonatomic, assign) SLDisplayMode displayMode;
@property (nonatomic, strong, readonly) SLPLFView * view;      // graphics view
@property (nonatomic, assign) BOOL viewAnimationHidden;     // default is YES;
@property (nonatomic, assign) SLGravityMode viewGravityMode;       // default is SLGravityModeResizeAspect;
@property (nonatomic, copy) void (^viewTapAction)(SLPlayer * player, SLPLFView * view);


// control
@property (nonatomic, assign, readonly) SLPlayerState state;
@property (nonatomic, assign, readonly) CGSize presentationSize;
@property (nonatomic, assign, readonly) NSTimeInterval bitrate;
@property (nonatomic, assign, readonly) NSTimeInterval progress;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval playableTime;

@property (nonatomic, assign) SLPlayerBackgroundMode backgroundMode;    // background mode
@property (nonatomic, assign) NSTimeInterval playableBufferInterval;    // default is 2s
@property (nonatomic, assign) CGFloat volume;       // default is 1

- (void)play;
- (void)pause;
- (void)stop;

@property (nonatomic, assign, readonly) BOOL seekEnable;
@property (nonatomic, assign, readonly) BOOL seeking;
- (void)seekToTime:(NSTimeInterval)time;
- (void)seekToTime:(NSTimeInterval)time completeHandler:(nullable void(^)(BOOL finished))completeHandler;

//Proxy models
- (void)stopProxyServer;
- (void)startProxyServer;
@end


#pragma mark - Tracks Category

@interface SLPlayer (Tracks)

@property (nonatomic, assign, readonly) BOOL videoEnable;
@property (nonatomic, assign, readonly) BOOL audioEnable;

@property (nonatomic, strong, readonly) SLPlayerTrack * videoTrack;
@property (nonatomic, strong, readonly) SLPlayerTrack * audioTrack;

@property (nonatomic, strong, readonly) NSArray <SLPlayerTrack *> * videoTracks;
@property (nonatomic, strong, readonly) NSArray <SLPlayerTrack *> * audioTracks;

- (void)selectAudioTrack:(SLPlayerTrack *)audioTrack;
- (void)selectAudioTrackIndex:(int)audioTrackIndex;

@end


#pragma mark - Thread Category

@interface SLPlayer (Thread)

@property (nonatomic, assign, readonly) BOOL videoDecodeOnMainThread;
@property (nonatomic, assign, readonly) BOOL audioDecodeOnMainThread;

@end

NS_ASSUME_NONNULL_END

#import "SLPlayerAction.h"
