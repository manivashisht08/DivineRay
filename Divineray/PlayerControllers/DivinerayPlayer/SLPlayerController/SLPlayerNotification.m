//
//  SLPlayer
//
//  Created by  on 16/8/15.
//  Copyright © 2016年 single. All rights reserved.
//

#import "SLPlayerNotification.h"

@implementation SLPlayerNotification

+ (void)postPlayer:(SLPlayer *)player error:(SLError *)error
{
    if (!player || !error) return;
    NSDictionary * userInfo = @{
                                SLPlayerErrorKey : error
                                };
    player.error = error;
    [self postNotificationName:SLPlayerErrorNotificationName object:player userInfo:userInfo];
}

+ (void)postPlayer:(SLPlayer *)player statePrevious:(SLPlayerState)previous current:(SLPlayerState)current
{
    if (!player) return;
    NSDictionary * userInfo = @{
                                SLPlayerStatePreviousKey : @(previous),
                                SLPlayerStateCurrentKey : @(current)
                                };
    [self postNotificationName:SLPlayerStateChangeNotificationName object:player userInfo:userInfo];
}

+ (void)postPlayer:(SLPlayer *)player progressPercent:(NSNumber *)percent current:(NSNumber *)current total:(NSNumber *)total
{
    if (!player) return;
    if (![percent isKindOfClass:[NSNumber class]]) percent = @(0);
    if (![current isKindOfClass:[NSNumber class]]) current = @(0);
    if (![total isKindOfClass:[NSNumber class]]) total = @(0);
    NSDictionary * userInfo = @{
                                SLPlayerProgressPercentKey : percent,
                                SLPlayerProgressCurrentKey : current,
                                SLPlayerProgressTotalKey : total
                                };
    [self postNotificationName:SLPlayerProgressChangeNotificationName object:player userInfo:userInfo];
}

+ (void)postPlayer:(SLPlayer *)player playablePercent:(NSNumber *)percent current:(NSNumber *)current total:(NSNumber *)total
{
    if (!player) return;
    if (![percent isKindOfClass:[NSNumber class]]) percent = @(0);
    if (![current isKindOfClass:[NSNumber class]]) current = @(0);
    if (![total isKindOfClass:[NSNumber class]]) total = @(0);
    NSDictionary * userInfo = @{
                                SLPlayerPlayablePercentKey : percent,
                                SLPlayerPlayableCurrentKey : current,
                                SLPlayerPlayableTotalKey : total,
                                };
    [self postNotificationName:SLPlayerPlayableChangeNotificationName object:player userInfo:userInfo];
}

+ (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
    });
}

@end
