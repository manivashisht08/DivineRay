//
//  SLDisplayView.h
//  SLPlayer
//
//  Created by  on 12/01/2017.
//  Copyright © 2017 single. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SLPlayerImp.h"
#import "SLAVPlayer.h"
#import "SLPlayerMacro.h"


typedef NS_ENUM(NSUInteger, SLDisplayRendererType) {
    SLDisplayRendererTypeEmpty,
    SLDisplayRendererTypeAVPlayerLayer,
    SLDisplayRendererTypeOpenGL,
};

typedef NS_ENUM(NSUInteger, SLDisplayPlayerOutputType) {
    SLDisplayPlayerOutputTypeEmpty,
    SLDisplayPlayerOutputTypeFF,
    SLDisplayPlayerOutputTypeAV,
};

@interface SLDisplayView : SLPLFView


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
+ (instancetype)displayViewWithAbstractPlayer:(SLPlayer *)abstractPlayer;

@property (nonatomic, weak, readonly) SLPlayer * abstractPlayer;

// player output type
@property (nonatomic, assign, readonly) SLDisplayPlayerOutputType playerOutputType;
@property (nonatomic, weak) id <SLAVPlayerOutput> playerOutputAV;
- (void)playerOutputTypeAV;
- (void)playerOutputTypeEmpty;

// renderer type
@property (nonatomic, assign, readonly) SLDisplayRendererType rendererType;
- (void)rendererTypeEmpty;
- (void)rendererTypeAVPlayerLayer;
- (void)rendererTypeOpenGL;


// reload
- (void)reloadGravityMode;
- (void)reloadPlayerConfig;

@end
