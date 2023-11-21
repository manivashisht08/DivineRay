//
//  UIView+Tools.m
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 03/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import "UIView+Tools.h"
#import "SLConstants.h"
#import "SLGlobalShared.h"

@implementation UIView (Tools)

- (void)makeCornerRadius:(float)radius borderColor:(UIColor *)bColor borderWidth:(float)bWidth{
    self.layer.borderWidth = bWidth;
    if (bColor != nil) {
        self.layer.borderColor = bColor.CGColor;
    }
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

+ (float)safeAreaBottomOffset {
    float safeAreaPosition = 0;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeArea = ([UIApplication sharedApplication].delegate).window.safeAreaInsets;
        if (safeArea.bottom > 5 ) {
            safeAreaPosition =  safeArea.bottom;
        }
    }
    return safeAreaPosition;
}


+ (void)layerAnimationWithPoint:(CGPoint)point withLayer:(CALayer *)focusLayer {
    
    if (focusLayer) {
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        animation.duration = 0.3f;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
}

- (void)Divineray_fadeIn {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self Divineray_fadeInAndCompletion:nil];
    });
    
}

- (void)Divineray_fadeOut {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self Divineray_fadeOutAndCompletion:nil];
        
    });
}

- (void)Divineray_fadeInAndCompletion:(void(^)(UIView *view))block {
    self.alpha = 0.001;
    [UIView animateWithDuration:0.60 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

- (void)Divineray_fadeOutAndCompletion:(void(^)(UIView *view))block {
    self.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.001;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

- (void)Divineray_appearState:(BOOL)appearState {
    if ((appearState && self.alpha == 1) || (!appearState && self.alpha == 0)) {
        return;
    }
    self.alpha = appearState ? 0.0:1.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = appearState ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)addSubviewWithContstraints:(UIView *)containerView {
    
    containerView.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:containerView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(containerView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containerView]-0-|" options:0 metrics:nil views:views]];
    
    [self  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containerView]-0-|" options:0 metrics:nil views:views]];
}

- (void)slideInMenu {
    self.transform = CGAffineTransformMakeTranslation(0.0f,self.center.y);
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)slideOutMenu {
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        self.transform = CGAffineTransformMakeTranslation(0.0f,self.center.y);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

+ (void)setAnimationWithButton:(UIButton *)button highlighted:(BOOL)selected {
    [UIView transitionWithView:button
                      duration:0.50
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        button.selected = selected;
                    }
                    completion:nil];
}

- (void)setCrossDissolveWithView {
    self.alpha = 0.001;
    [UIView transitionWithView:self
                      duration:0.50
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.alpha = 1;
                    }
                    completion:nil];
}

- (void)showFooterView :(float)hight {
    
    float safeAreaPosition = 0;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeArea = ([UIApplication sharedApplication].delegate).window.safeAreaInsets;
        if (safeArea.bottom > 5 ) {
            safeAreaPosition =  safeArea.bottom;
        }
    }
    self.frame = CGRectMake(0, SLSCREEN_HEIGHT, SLSCREEN_WIDTH, hight);
    self.alpha = 1.0;
    
    [UIView animateWithDuration:.50
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.frame = CGRectMake(0, SLSCREEN_HEIGHT - (hight+safeAreaPosition), SLSCREEN_WIDTH, hight);
                     }
                     completion:nil];
}

- (void)hideFooterView:(float)hight  {
    self.frame = CGRectMake(0, SLSCREEN_HEIGHT - hight, SLSCREEN_WIDTH, hight);
    self.alpha = 1.0;
    [UIView animateWithDuration:.50
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.frame = CGRectMake(0, SLSCREEN_HEIGHT, SLSCREEN_WIDTH, hight);
                     }
                     completion:nil];
}

- (void)hideBottomView:(float)hight completion:(void(^)(UIView *view))block {
    self.frame = CGRectMake(0, SLSCREEN_HEIGHT - hight, SLSCREEN_WIDTH, hight);
    self.alpha = 1.0;
    [UIView animateWithDuration:.50
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.frame = CGRectMake(0, SLSCREEN_HEIGHT, SLSCREEN_WIDTH, hight);
                     }
                     completion:^(BOOL finished) {
                         if ( block ) block(self);
                     }];
}

+ (void)hideBottomViewWithAnimation:(UIView *)sourceView viewHight:(float)hight completion:(void(^)(UIView *view))block {
    sourceView.frame = CGRectMake(0, SLSCREEN_HEIGHT - hight, SLSCREEN_WIDTH, hight);
    sourceView.alpha = 1.0;
    [UIView animateWithDuration:.50
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         sourceView.frame = CGRectMake(0, SLSCREEN_HEIGHT, SLSCREEN_WIDTH, hight);
                     }
                     completion:^(BOOL finished) {
                         if ( block ) block(nil);
                     }];
}


@end

@implementation UILabel (SLLabel)

+(UILabel *)labTextColor:(UIColor *)textColor font:(UIFont *)font aligent:(NSTextAlignment)aligent
{
    UILabel * lab = [[UILabel alloc] init];
    lab.textColor = textColor;
    lab.font = font;
    lab.textAlignment = aligent;
    lab.numberOfLines = 1;
    return lab;
}


@end

