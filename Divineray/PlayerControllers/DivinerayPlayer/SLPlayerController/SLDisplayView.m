//
//  SLDisplayView.m
//  SLPlayer
//
//  Created by Single on 12/01/2017.
//  Copyright © 2017 single. All rights reserved.
//

#import "SLDisplayView.h"
#import "SLPlayerMacro.h"

@interface SLDisplayView ()
@property (nonatomic, weak) SLPlayer * abstractPlayer;
@property (nonatomic, assign) BOOL avplayerLayerToken;
@property (nonatomic, strong) AVPlayerLayer * avplayerLayer;
@end

@implementation SLDisplayView

+ (instancetype)displayViewWithAbstractPlayer:(SLPlayer *)abstractPlayer
{
    return [[self alloc] initWithAbstractPlayer:abstractPlayer];
}

- (instancetype)initWithAbstractPlayer:(SLPlayer *)abstractPlayer
{
    if (self = [super initWithFrame:CGRectZero]) {
        self.abstractPlayer = abstractPlayer;
        SLPLFViewSetBackgroundColor(self, [UIColor blackColor]);
        [self setupEventHandler];
    }
    return self;
}

- (void)playerOutputTypeEmpty
{
    self->_playerOutputType = SLDisplayPlayerOutputTypeEmpty;
}

- (void)playerOutputTypeFF
{
    self->_playerOutputType = SLDisplayPlayerOutputTypeFF;
}

- (void)playerOutputTypeAV
{
    self->_playerOutputType = SLDisplayPlayerOutputTypeAV;
}

- (void)rendererTypeEmpty
{
    if (self.rendererType != SLDisplayRendererTypeEmpty) {
        self->_rendererType = SLDisplayRendererTypeEmpty;
        [self reloadView];
    }
}

- (void)rendererTypeAVPlayerLayer
{
    if (self.rendererType != SLDisplayRendererTypeAVPlayerLayer) {
        self->_rendererType = SLDisplayRendererTypeAVPlayerLayer;
        [self reloadView];
    }
}

- (void)rendererTypeOpenGL
{
    if (self.rendererType != SLDisplayRendererTypeOpenGL) {
        self->_rendererType = SLDisplayRendererTypeOpenGL;
        [self reloadView];
    }
}

- (void)reloadView
{
    [self cleanView];
    switch (self.rendererType) {
        case SLDisplayRendererTypeEmpty:
            break;
        case SLDisplayRendererTypeAVPlayerLayer:
        {
            self.avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
            [self reloadPlayerConfig];
            self.avplayerLayerToken = NO;
            [self.layer insertSublayer:self.avplayerLayer atIndex:0];
            [self reloadGravityMode];
        }
            break;
        case SLDisplayRendererTypeOpenGL:
            
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateDisplayViewLayout:self.bounds];
    });
}

- (void)reloadGravityMode
{
    if (self.avplayerLayer) {
        switch (self.abstractPlayer.viewGravityMode) {
            case SLGravityModeResize:
                self.avplayerLayer.videoGravity = AVLayerVideoGravityResize;
                break;
            case SLGravityModeResizeAspect:
                self.avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                break;
            case SLGravityModeResizeAspectFill:
                self.avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                break;
        }
    }
}

- (void)reloadPlayerConfig
{
    if (self.avplayerLayer && self.playerOutputType == SLDisplayPlayerOutputTypeAV) {
        if ([self.playerOutputAV playerOutputGetAVPlayer] && [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
            self.avplayerLayer.player = [self.playerOutputAV playerOutputGetAVPlayer];
        } else {
            self.avplayerLayer.player = nil;
        }
        
    }
}


- (void)cleanView
{
    if (self.avplayerLayer) {
        [self.avplayerLayer removeFromSuperlayer];
        self.avplayerLayer.player = nil;
        self.avplayerLayer = nil;
    }
    
    self.avplayerLayerToken = NO;
    
}

- (void)updateDisplayViewLayout:(CGRect)frame
{
    if (self.avplayerLayer) {
        self.avplayerLayer.frame = frame;
        if (self.abstractPlayer.viewAnimationHidden || !self.avplayerLayerToken) {
            [self.avplayerLayer removeAllAnimations];
            self.avplayerLayerToken = YES;
        }
    }
    
}

#pragma mark - Event Handler
- (void)setupEventHandler
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iOS_applicationDidEnterBackgroundAction:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iOS_applicationWillEnterForegroundAction:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    UITapGestureRecognizer * tapGestureRecigbuzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iOS_tapGestureRecigbuzerAction:)];
    [self addGestureRecognizer:tapGestureRecigbuzer];
}


- (void)iOS_applicationDidEnterBackgroundAction:(NSNotification *)notification
{
    if (_avplayerLayer) {
        _avplayerLayer.player = nil;
    }
}

- (void)iOS_applicationWillEnterForegroundAction:(NSNotification *)notification
{
    if (_avplayerLayer) {
        _avplayerLayer.player = [self.playerOutputAV playerOutputGetAVPlayer];
    }
}

- (void)iOS_tapGestureRecigbuzerAction:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.abstractPlayer.viewTapAction) {
        self.abstractPlayer.viewTapAction(self.abstractPlayer, self.abstractPlayer.view);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.abstractPlayer.displayMode == SLDisplayModeBox) return;
    switch (self.rendererType) {
        case SLDisplayRendererTypeEmpty:
        case SLDisplayRendererTypeAVPlayerLayer:
            return;
        default:
        {
            UITouch * touch = [touches anyObject];
            float distanceX = [touch locationInView:touch.view].x - [touch previousLocationInView:touch.view].x;
            float distanceY = [touch locationInView:touch.view].y - [touch previousLocationInView:touch.view].y;
            distanceX *= 0.005;
            distanceY *= 0.005;
            // self.fingerRotation.x += distanceY *  [SGFingerRotation degress] / 100;
            //self.fingerRotation.y -= distanceX *  [SGFingerRotation degress] / 100;
        }
            break;
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    [self updateDisplayViewLayout:layer.bounds];
}

- (void)dealloc {
    [self cleanView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SLPlayerLog(@"SLDisplayView release");
}

@end
