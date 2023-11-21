//
//  UIView+SmartHighlight.m
//  Oncam
//
//  Created by Gaurav Keshre on 11/11/13.
//  Copyright (c) 2018 Oncam Inc. All rights reserved.
//

#import "UIView+SmartHighlight.h"

@implementation UIView (SmartHighlight)

-(void)focusWithScale:(CGFloat)scale {
    [self.layer addAnimation:[self createAnimationWithDuration:HIGHLIGHT_SCALE_DURATION delay:0] forKey:@"scale"];
}

- (void)dismissFocus {
    [self.layer removeAllAnimations];
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (CABasicAnimation *)createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.fromValue = [NSNumber numberWithFloat:1.4];
    anim.toValue = [NSNumber numberWithFloat:1.8];
    anim.autoreverses = YES;
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.beginTime = CACurrentMediaTime()+delay;
    anim.repeatCount = INFINITY;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}


@end
