
#import "YPDouYinLikeAnimation.h"

#define SLKlugYPVideoLikeImagePath(file)  [UIImage imageNamed:[NSString stringWithFormat:@"YPVideoLike/%@", file] inBundle:[NSBundle    ImagesBundle] compatibleWithTraitCollection:nil]

NSString *const yp_heartImgName = @"yp_video_like";
const CGFloat yp_heartImgWidth = 80;
const CGFloat yp_heartImgHeight = 80;


@interface YPDouYinLikeAnimation ()


@end

@implementation YPDouYinLikeAnimation

#pragma mark -
#pragma mark - 🎱 shareInstance
+ (instancetype)shareInstance {
    static YPDouYinLikeAnimation *selfInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        selfInstance = [[self alloc] init];
    });
    
    return selfInstance;
}

#pragma mark -
#pragma mark - 🎱 createAnimationWithTounch: withEvent:
- (void)createAnimationWithTouch:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (@available(iOS 8.0, *)) {
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
        UIImage *img = [UIImage imageNamed:yp_heartImgName];;
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, yp_heartImgWidth, yp_heartImgHeight)];
    imgV.image = img;
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    imgV.center = point;
    

    int leftOrRight = arc4random()%2;
    leftOrRight = leftOrRight ? leftOrRight : -1;
    imgV.transform = CGAffineTransformRotate(imgV.transform,M_PI / 9 * leftOrRight);
    [[touch view] addSubview:imgV];
    
    __block UIImageView *blockImgV = imgV;
    __block UIImage *blockImg = img;
    [UIView animateWithDuration:0.1 animations:^{
        blockImgV.transform = CGAffineTransformScale(blockImgV.transform, 1.2, 1.2);
    } completion:^(BOOL finished) {
        blockImgV.transform = CGAffineTransformScale(blockImgV.transform, 0.8, 0.8);
        [self performSelector:@selector(animationToTop:) withObject:@[blockImgV,blockImg] afterDelay:0.3];
    }];
    }
}


#pragma mark -
#pragma mark - 🎱 createAnimationWithTap:
- (void)createAnimationWithTap:(UITapGestureRecognizer *)tap {
     if (@available(iOS 8.0, *)) {
    CGPoint point = [tap locationInView:[tap view]];
    UIImage *img = [UIImage imageNamed:yp_heartImgName];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, yp_heartImgWidth, yp_heartImgHeight)];
    imgV.image = img;
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    imgV.center = point;
    [[tap view] addSubview:imgV];
    
    int leftOrRight = arc4random()%2;
    leftOrRight = leftOrRight ? leftOrRight : -1;
    imgV.transform = CGAffineTransformRotate(imgV.transform,M_PI / 9 * leftOrRight);
    
    __block UIImageView *blockImgV = imgV;
    __block UIImage *blockImg = img;
    [UIView animateWithDuration:0.1 animations:^{
        blockImgV.transform = CGAffineTransformScale(blockImgV.transform, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [self performSelector:@selector(animationToTop:) withObject:@[blockImgV,blockImg] afterDelay:0.3];
    }];
     }
}

#pragma mark -
#pragma mark - 🎱 animationToTop
- (void)animationToTop:(NSArray *)imgObjects {
    if (imgObjects && imgObjects.count > 0) {
        __block UIImageView *imageV = (UIImageView *)imgObjects[0];
        __block UIImage *img = (UIImage *)imgObjects[1];
        [UIView animateWithDuration:1.0 animations:^{
            imageV.frame = CGRectMake(imageV.frame.origin.x, imageV.frame.origin.y - 100, imageV.frame.size.width, imageV.frame.size.height);
            imageV.transform = CGAffineTransformScale(imageV.transform, 1.8, 1.8);
            imageV.alpha = 0.0;
        } completion:^(BOOL finished) {
            imageV = nil;
            img = nil;
        }];
    }
}

@end
