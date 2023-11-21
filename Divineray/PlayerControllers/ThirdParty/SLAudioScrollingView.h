
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLAudioScrollingView : UIControl
@property (nonatomic, copy) NSString *text;

- (void)startOrResumeAnimate;
- (void)pauseAnimate;
- (void)resumeAnimate;
- (void)stopAnimate;
@end

NS_ASSUME_NONNULL_END
