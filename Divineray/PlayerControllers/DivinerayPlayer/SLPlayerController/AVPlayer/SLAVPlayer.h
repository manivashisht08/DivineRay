//
//  SLAVPlayer.h
//  SLPlayer
//
//  Created by Single on 16/6/28.
//  Copyright © 2016年 single. All rights reserved.
//

#import "SLPlayerImp.h"
#import <AVFoundation/AVFoundation.h>

@protocol SLAVPlayerOutput <NSObject>

- (AVPlayer *)playerOutputGetAVPlayer;
- (CVPixelBufferRef)playerOutputGetPixelBufferAtCurrentTime;

@end

@interface SLAVPlayer : NSObject <SLAVPlayerOutput>

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)init NS_UNAVAILABLE;

+ (instancetype)playerWithAbstractPlayer:(SLPlayer *)abstractPlayer;

@property (nonatomic, weak, readonly) SLPlayer * abstractPlayer;
@property (nonatomic, strong, readonly) AVPlayer * avPlayer;

@property (nonatomic, assign, readonly) SLPlayerState state;
@property (nonatomic, assign, readonly) CGSize presentationSize;
@property (nonatomic, assign, readonly) NSTimeInterval bitrate;
@property (nonatomic, assign, readonly) NSTimeInterval progress;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval playableTime;
@property (nonatomic, assign, readonly) BOOL seeking;

- (void)replaceVideo;
- (void)reloadVolume;

- (void)play;
- (void)pause;
- (void)stop;

@property (nonatomic, assign, readonly) BOOL seekEnable;
- (void)seekToTime:(NSTimeInterval)time;
- (void)seekToTime:(NSTimeInterval)time completeHandler:(void(^)(BOOL finished))completeHandler;


#pragma mark - track info

@property (nonatomic, assign, readonly) BOOL videoEnable;
@property (nonatomic, assign, readonly) BOOL audioEnable;

@property (nonatomic, strong, readonly) SLPlayerTrack * videoTrack;
@property (nonatomic, strong, readonly) SLPlayerTrack * audioTrack;

@property (nonatomic, strong, readonly) NSArray <SLPlayerTrack *> * videoTracks;
@property (nonatomic, strong, readonly) NSArray <SLPlayerTrack *> * audioTracks;

- (void)selectAudioTrackIndex:(int)audioTrackIndex;

@end
