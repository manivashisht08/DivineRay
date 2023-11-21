#import "SLPlayerAction.h"

// notification name
NSString * const SLPlayerErrorNotificationName = @"SLPlayerErrorNotificationName";                   // player error
NSString * const SLPlayerStateChangeNotificationName = @"SLPlayerStateChangeNotificationName";     // player state change
NSString * const SLPlayerProgressChangeNotificationName = @"SLPlayerProgressChangeNotificationName";  // player play progress change
NSString * const SLPlayerPlayableChangeNotificationName = @"SLPlayerPlayableChangeNotificationName";   // player playable progress change

// notification userinfo key
NSString * const SLPlayerErrorKey = @"error";               // error

NSString * const SLPlayerStatePreviousKey = @"previous";    // state
NSString * const SLPlayerStateCurrentKey = @"current";      // state

NSString * const SLPlayerProgressPercentKey = @"percent";   // progress
NSString * const SLPlayerProgressCurrentKey = @"current";   // progress
NSString * const SLPlayerProgressTotalKey = @"total";       // progress

NSString * const SLPlayerPlayablePercentKey = @"percent";   // playable
NSString * const SLPlayerPlayableCurrentKey = @"current";   // playable
NSString * const SLPlayerPlayableTotalKey = @"total";       // playable


#pragma mark - SLPlayer Action Category

@implementation SLPlayer (SLPlayerAction)

- (void)registerPlayerNotificationTarget:(id)target
                             stateAction:(nullable SEL)stateAction
                          progressAction:(nullable SEL)progressAction
                          playableAction:(nullable SEL)playableAction
{
    [self registerPlayerNotificationTarget:target
                               stateAction:stateAction
                            progressAction:progressAction
                            playableAction:playableAction
                               errorAction:nil];
}

- (void)registerPlayerNotificationTarget:(id)target
                             stateAction:(nullable SEL)stateAction
                          progressAction:(nullable SEL)progressAction
                          playableAction:(nullable SEL)playableAction
                             errorAction:(nullable SEL)errorAction
{
    if (!target) return;
    [self removePlayerNotificationTarget:target];
    
    if (stateAction) {
        [[NSNotificationCenter defaultCenter] addObserver:target selector:stateAction name:SLPlayerStateChangeNotificationName object:self];
    }
    if (progressAction) {
        [[NSNotificationCenter defaultCenter] addObserver:target selector:progressAction name:SLPlayerProgressChangeNotificationName object:self];
    }
    if (playableAction) {
        [[NSNotificationCenter defaultCenter] addObserver:target selector:playableAction name:SLPlayerPlayableChangeNotificationName object:self];
    }
    if (errorAction) {
        [[NSNotificationCenter defaultCenter] addObserver:target selector:errorAction name:SLPlayerErrorNotificationName object:self];
    }
}

- (void)removePlayerNotificationTarget:(id)target
{
    [[NSNotificationCenter defaultCenter] removeObserver:target name:SLPlayerStateChangeNotificationName object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:target name:SLPlayerProgressChangeNotificationName object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:target name:SLPlayerPlayableChangeNotificationName object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:target name:SLPlayerErrorNotificationName object:self];
}

@end


#pragma mark - SLPlayer Action Models

@implementation SLModel

+ (SLState *)stateFromUserInfo:(NSDictionary *)userInfo
{
    SLState * state = [[SLState alloc] init];
    state.previous = [[userInfo objectForKey:SLPlayerStatePreviousKey] integerValue];
    state.current = [[userInfo objectForKey:SLPlayerStateCurrentKey] integerValue];
    return state;
}

+ (SProgress *)progressFromUserInfo:(NSDictionary *)userInfo
{
    SProgress * progress = [[SProgress alloc] init];
    progress.percent = [[userInfo objectForKey:SLPlayerProgressPercentKey] doubleValue];
    progress.current = [[userInfo objectForKey:SLPlayerProgressCurrentKey] doubleValue];
    progress.total = [[userInfo objectForKey:SLPlayerProgressTotalKey] doubleValue];
    return progress;
}

+ (SLPlayable *)playableFromUserInfo:(NSDictionary *)userInfo
{
    SLPlayable * playable = [[SLPlayable alloc] init];
    playable.percent = [[userInfo objectForKey:SLPlayerPlayablePercentKey] doubleValue];
    playable.current = [[userInfo objectForKey:SLPlayerPlayableCurrentKey] doubleValue];
    playable.total = [[userInfo objectForKey:SLPlayerPlayableTotalKey] doubleValue];
    return playable;
}

+ (SLError *)errorFromUserInfo:(NSDictionary *)userInfo
{
    SLError * error = [userInfo objectForKey:SLPlayerErrorKey];
    if ([error isKindOfClass:[SLError class]]) {
        return error;
    } else if ([error isKindOfClass:[NSError class]]) {
        SLError * obj = [[SLError alloc] init];
        obj.error = (NSError *)error;
        return obj;
    } else {
        SLError * obj = [[SLError alloc] init];
        obj.error = [NSError errorWithDomain:@"SLPlayer error" code:-1 userInfo:nil];
        return obj;
    }
}

@end

@implementation SLState
@end

@implementation SProgress
@end

@implementation SLPlayable
@end

@implementation SLErrorEvent
@end

@implementation SLError
@end
