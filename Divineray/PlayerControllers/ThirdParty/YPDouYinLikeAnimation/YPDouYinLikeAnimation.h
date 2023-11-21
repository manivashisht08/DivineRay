//
//  YPDouYinDianZanAnimationTool.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YPDouYinLikeAnimation : NSObject

+ (instancetype)shareInstance;

- (void)createAnimationWithTouch:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)createAnimationWithTap:(UITapGestureRecognizer *)tap;

@end
