
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>

typedef NS_ENUM(NSUInteger, YGPulseViewAnimationType) {
    YGPulseViewAnimationTypeRegularPulsing,
    YGPulseViewAnimationTypeRadarPulsing
};

@interface UIView (YGPulseView)

- (void)startPulseWithColor:(UIColor *)color;

- (void)startPulseWithColor:(UIColor *)color animation:(YGPulseViewAnimationType)animationType;

- (void)startPulseWithColor:(UIColor *)color scaleFrom:(CGFloat)initialScale to:(CGFloat)finishScale frequency:(CGFloat)frequency opacity:(CGFloat)opacity animation:(YGPulseViewAnimationType)animationType;

- (void)stopPulse;

@end
