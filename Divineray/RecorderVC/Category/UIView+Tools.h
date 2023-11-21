//
//  UIView+Tools.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 03/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Tools)
- (void)makeCornerRadius:(float)radius borderColor:(UIColor*)bColor borderWidth:(float)bWidth;
+ (void)layerAnimationWithPoint:(CGPoint)point withLayer:(CALayer *)focusLayer;


/**
 View appear States...
 */
- (void)Divineray_fadeIn;
- (void)Divineray_fadeOut;
- (void)Divineray_fadeInAndCompletion:(void(^)(UIView *view))block;
- (void)Divineray_fadeOutAndCompletion:(void(^)(UIView *view))block;
- (void)Divineray_appearState:(BOOL)appearState;
- (void)addSubviewWithContstraints:(UIView *)containerView;

- (void)slideInMenu;
- (void)slideOutMenu;

+ (void)setAnimationWithButton:(UIButton *)button highlighted:(BOOL)selected;
- (void)setCrossDissolveWithView;
- (void)showFooterView :(float)hight;
- (void)hideFooterView:(float)hight;
- (void)hideBottomView:(float)hight completion:(void(^)(UIView *view))block;
+ (void)hideBottomViewWithAnimation:(UIView *)sourceView viewHight:(float)hight completion:(void(^)(UIView *view))block;


+ (float)safeAreaBottomOffset;
@end


@interface UILabel (SLLabel)
+(UILabel *)labTextColor:(UIColor *)textColor font:(UIFont *)font aligent:(NSTextAlignment)aligent;

@end

