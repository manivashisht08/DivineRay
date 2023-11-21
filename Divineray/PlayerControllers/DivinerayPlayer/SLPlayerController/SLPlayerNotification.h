//
//  SLPlayer
//
//  Created by Single on 16/8/15.
//  Copyright © 2016年 single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLPlayerImp.h"
#import "SLPlayerAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLPlayer (SLPlayerNotification)
@property (nonatomic, strong, nullable) SLError * error;
@end

@interface SLPlayerNotification : NSObject

+ (void)postPlayer:(SLPlayer *)player error:(SLError *)error;
+ (void)postPlayer:(SLPlayer *)player statePrevious:(SLPlayerState)previous current:(SLPlayerState)current;
+ (void)postPlayer:(SLPlayer *)player progressPercent:(NSNumber *)percent current:(NSNumber *)current total:(NSNumber *)total;
+ (void)postPlayer:(SLPlayer *)player playablePercent:(NSNumber *)percent current:(NSNumber *)current total:(NSNumber *)total;

@end

NS_ASSUME_NONNULL_END
