//
//  SLAudioManager.h
//  SLPlayer
//
//  Created by Single on 09/01/2017.
//  Copyright © 2017 single. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SLAudioManagerInterruptionType) {
    SLAudioManagerInterruptionTypeBegin,
    SLAudioManagerInterruptionTypeEnded,
};

typedef NS_ENUM(NSUInteger, SLAudioManagerInterruptionOption) {
    SLAudioManagerInterruptionOptionNone,
    SLAudioManagerInterruptionOptionShouldResume,
};

typedef NS_ENUM(NSUInteger, SLAudioManagerRouteChangeReason) {
    SLAudioManagerRouteChangeReasonOldDeviceUnavailable,
};

@class SLAudioManager;

@protocol SLAudioManagerDelegate <NSObject>
- (void)audioManager:(SLAudioManager *)audioManager outputData:(float *)outputData numberOfFrames:(UInt32)numberOfFrames numberOfChannels:(UInt32)numberOfChannels;
@end

typedef void (^SLAudioManagerInterruptionHandler)(id handlerTarget, SLAudioManager * audioManager, SLAudioManagerInterruptionType type, SLAudioManagerInterruptionOption option);
typedef void (^SLAudioManagerRouteChangeHandler)(id handlerTarget, SLAudioManager * audioManager, SLAudioManagerRouteChangeReason reason);

@interface SLAudioManager : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)manager;

@property (nonatomic, assign) float volume;

@property (nonatomic, weak, readonly) id <SLAudioManagerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL playing;

@property (nonatomic, assign, readonly) Float64 samplingRate;
@property (nonatomic, assign, readonly) UInt32 numberOfChannels;

- (void)setHandlerTarget:(id)handlerTarget
            interruption:(SLAudioManagerInterruptionHandler)interruptionHandler
             routeChange:(SLAudioManagerRouteChangeHandler)routeChangeHandler;
- (void)removeHandlerTarget:(id)handlerTarget;

- (void)playWithDelegate:(id <SLAudioManagerDelegate>)delegate;
- (void)pause;

- (BOOL)registerAudioSession;
- (void)unregisterAudioSession;

@end
