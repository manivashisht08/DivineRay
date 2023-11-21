//
//  SLPlayerAction.h
//  SLPlayer
//
//  Created by Single on 2017/2/13.
//  Copyright © 2017年 single. All rights reserved.
//

#import "SLPlayerImp.h"

@class SLState;
@class SProgress;
@class SLPlayable;
@class SLError;

NS_ASSUME_NONNULL_BEGIN

// extern
#if defined(__cplusplus)
#define SLPLAYER_EXTERN extern "C"
#else
#define SLPLAYER_EXTERN extern
#endif

// notification name
SLPLAYER_EXTERN NSString * const SLPlayerErrorNotificationName;             // player error
SLPLAYER_EXTERN NSString * const SLPlayerStateChangeNotificationName;       // player state change
SLPLAYER_EXTERN NSString * const SLPlayerProgressChangeNotificationName;    // player play progress change
SLPLAYER_EXTERN NSString * const SLPlayerPlayableChangeNotificationName;    // player playable progress change

// notification userinfo key
SLPLAYER_EXTERN NSString * const SLPlayerErrorKey;              // error

SLPLAYER_EXTERN NSString * const SLPlayerStatePreviousKey;      // state
SLPLAYER_EXTERN NSString * const SLPlayerStateCurrentKey;       // state

SLPLAYER_EXTERN NSString * const SLPlayerProgressPercentKey;    // progress
SLPLAYER_EXTERN NSString * const SLPlayerProgressCurrentKey;    // progress
SLPLAYER_EXTERN NSString * const SLPlayerProgressTotalKey;      // progress

SLPLAYER_EXTERN NSString * const SLPlayerPlayablePercentKey;    // playable
SLPLAYER_EXTERN NSString * const SLPlayerPlayableCurrentKey;    // playable
SLPLAYER_EXTERN NSString * const SLPlayerPlayableTotalKey;      // playable


#pragma mark - SLPlayer Action Category

@interface SLPlayer (SLPlayerAction)

- (void)registerPlayerNotificationTarget:(id)target
                             stateAction:(nullable SEL)stateAction
                          progressAction:(nullable SEL)progressAction
                          playableAction:(nullable SEL)playableAction;      // object's class is NSNotification

- (void)registerPlayerNotificationTarget:(id)target
                             stateAction:(nullable SEL)stateAction
                          progressAction:(nullable SEL)progressAction
                          playableAction:(nullable SEL)playableAction
                             errorAction:(nullable SEL)errorAction;

- (void)removePlayerNotificationTarget:(id)target;

@end


#pragma mark - SLPlayer Action Models

@interface SLModel : NSObject

+ (SLState *)stateFromUserInfo:(NSDictionary *)userInfo;
+ (SProgress *)progressFromUserInfo:(NSDictionary *)userInfo;
+ (SLPlayable *)playableFromUserInfo:(NSDictionary *)userInfo;
+ (SLError *)errorFromUserInfo:(NSDictionary *)userInfo;

@end

@interface SLState : SLModel
@property (nonatomic, assign) SLPlayerState previous;
@property (nonatomic, assign) SLPlayerState current;
@end

@interface SProgress : SLModel
@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, assign) CGFloat current;
@property (nonatomic, assign) CGFloat total;
@end

@interface SLPlayable : SLModel
@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, assign) CGFloat current;
@property (nonatomic, assign) CGFloat total;
@end

@interface SLErrorEvent : SLModel
@property (nonatomic, copy, nullable) NSDate * date;
@property (nonatomic, copy, nullable) NSString * URI;
@property (nonatomic, copy, nullable) NSString * serverAddress;
@property (nonatomic, copy, nullable) NSString * playbackSessionID;
@property (nonatomic, assign) NSInteger errorStatusCode;
@property (nonatomic, copy) NSString * errorDomain;
@property (nonatomic, copy, nullable) NSString * errorComment;
@end

@interface SLError : SLModel
@property (nonatomic, copy) NSError * error;
@property (nonatomic, copy, nullable) NSData * extendedLogData;
@property (nonatomic, assign) NSStringEncoding extendedLogDataStringEncoding;
@property (nonatomic, copy, nullable) NSArray <SLErrorEvent *> * errorEvents;
@end

NS_ASSUME_NONNULL_END
