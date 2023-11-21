
#import "SLAudioScrollingView.h"
#import "NSString+Extension.h"
#import "UIView+EdwFrame.h"
#import "Masonry.h"

@interface SLAudioScrollingView ()
@property (nonatomic, strong) UIView *animateView;
@property (nonatomic, strong) NSMutableArray <UILabel *>*mtbLabArr;
@end

@implementation SLAudioScrollingView

- (NSMutableArray<UILabel *> *)mtbLabArr{
    if (!_mtbLabArr) {
        _mtbLabArr = [NSMutableArray array];
    }
    return _mtbLabArr;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    UIImageView *musicIcon = [[UIImageView alloc]init];
    musicIcon.image = [UIImage imageNamed:@"d_music"];
    [self addSubview:musicIcon];
    
    _animateView = [[UIView alloc]init];
    _animateView.userInteractionEnabled = NO;
    //    _animateView.backgroundColor = [UIColor redColor];
    [self addSubview:_animateView];
    
    [musicIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    
    [_animateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(musicIcon.mas_right).offset(5);
        make.height.mas_equalTo(musicIcon);
        make.right.mas_equalTo(self);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self addLeadShadow];
}

- (void)addLeadShadow{
    float fadeLength = 10.0f;
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.bounds = _animateView.layer.bounds;
    gradientMask.position = CGPointMake(_animateView.edw_width/2.0, _animateView.edw_height/2.0);
    NSObject *transparent = (NSObject*) [[UIColor clearColor] CGColor];
    NSObject *opaque = (NSObject*) [[UIColor blackColor] CGColor];
    gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY(_animateView.frame));
    gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY(_animateView.frame));
    float fadePoint = fadeLength/_animateView.edw_width;
    [gradientMask setColors: [NSArray arrayWithObjects: transparent, opaque, opaque, transparent, nil]];
    [gradientMask setLocations: [NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat: 0.0],
                                 [NSNumber numberWithFloat: fadePoint],
                                 [NSNumber numberWithFloat: 1 - fadePoint],
                                 [NSNumber numberWithFloat: 1.0],
                                 nil]];
    _animateView.layer.mask = gradientMask;
}

- (void)setText:(NSString *)text{
    if (!(text.length > 0)) {
        return;
    }
    text = [NSString stringWithFormat:@"@%@    ",text];
    _text = text;
    
    CGFloat width = [text widthWithFont:[UIFont fontWithName:@"Poppins-Medium" size:15] constrainedToHeight:self.animateView.edw_width];
    
    NSUInteger labCount = 1;
    if (width > self.animateView.edw_width) {
        labCount++;
    }else{
        labCount = self.animateView.edw_width / width + labCount + 1;
    }
    
    for (NSUInteger i = 0; i < self.mtbLabArr.count; i++) {
        UILabel *lab = [self.mtbLabArr objectAtIndex:i];
        NSString *key = [NSString stringWithFormat:@"musicNameLab_position_x_%lu",(unsigned long)i];
        [lab.layer removeAnimationForKey:key];
        [lab removeFromSuperview];
    }
    [self.mtbLabArr removeAllObjects];
    for (NSUInteger i = 0;i < labCount; i++) {
        UILabel *nameLab = [[UILabel alloc]init];
        nameLab.textColor = [UIColor colorWithWhite:1 alpha:1.0];
        nameLab.font = [UIFont fontWithName:@"Poppins-Medium" size:15];
        nameLab.text = text;
        [_animateView addSubview:nameLab];
        [self.mtbLabArr addObject:nameLab];
        
        [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.animateView).mas_offset(width * i);
            make.top.bottom.mas_equalTo(self.animateView);
            make.width.mas_equalTo(@(width));
        }];
    }
}

- (void)addAnimateView:(UILabel *)lab repeatCount:(float)repeatCount duration:(CFTimeInterval)duration key:(NSString *)key timeOffset:(CFTimeInterval)timeOffset{
    
    UILabel *firstLab = [self.mtbLabArr objectAtIndex:0];
    UILabel *lastLab = [self.mtbLabArr lastObject];
    CABasicAnimation *baseAnimat = [CABasicAnimation animationWithKeyPath:@"position.x"];
    baseAnimat.fromValue = [NSValue valueWithCGPoint:CGPointMake(lastLab.layer.position.x,0)];
    baseAnimat.toValue = [NSValue valueWithCGPoint:CGPointMake(-firstLab.layer.position.x,0)];
    baseAnimat.repeatCount = repeatCount;
    baseAnimat.duration = duration;
    baseAnimat.fillMode = kCAFillModeForwards;
    baseAnimat.removedOnCompletion=NO;
    baseAnimat.timeOffset = timeOffset;
    [lab.layer addAnimation:baseAnimat forKey:key];

    if (lab.layer.speed != 1.0) {
        CFTimeInterval pausedTime = [lab.layer timeOffset];
        lab.layer.speed = 1.0;
        lab.layer.timeOffset = 0.0;
        lab.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [lab.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        lab.layer.beginTime = timeSincePause;
    }
};

- (void)startOrResumeAnimate{
    if (!(self.mtbLabArr.count > 0)) return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTextAnimation) object: nil];
    [self performSelector:@selector(startTextAnimation) withObject:self afterDelay:0.5];
}

- (void)startTextAnimation {
    
      UILabel *firstLab = [self.mtbLabArr objectAtIndex:0];
       UILabel *lastLab = [self.mtbLabArr lastObject];
       
       NSString *firstKey = @"musicNameLab_position_x_0";
       CAAnimation *baseAnimat = [firstLab.layer animationForKey:firstKey];
       
       if (!baseAnimat) {
           CGFloat distance = lastLab.layer.position.x - firstLab.layer.position.x,speed = 20;
           CGFloat time = distance / speed;
           CFTimeInterval timeOffset = time / self.mtbLabArr.count;
           for (NSUInteger i = 0; i < self.mtbLabArr.count; i++) {
               UILabel *firstLab = [self.mtbLabArr objectAtIndex:i];
               NSString *key = [NSString stringWithFormat:@"musicNameLab_position_x_%lu",(unsigned long)i];
               [self addAnimateView:firstLab repeatCount:MAXFLOAT duration:time key:key timeOffset:timeOffset *i];
           }
       }else{
           if (firstLab.layer.speed != 1.0) {
               [self resumeAnimate];
           }
       }
}



- (void)pauseAnimate{
    
    for (NSUInteger i = 0; i < self.mtbLabArr.count; i++) {
        UILabel *firstLab = [self.mtbLabArr objectAtIndex:i];
        CFTimeInterval pausedTime = [firstLab.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        firstLab.layer.speed = 0.0;
        firstLab.layer.timeOffset = pausedTime;
    }
    
}

- (void)resumeAnimate{
    for (NSUInteger i = 0; i < self.mtbLabArr.count; i++) {
        UILabel *lab = [self.mtbLabArr objectAtIndex:i];
        CFTimeInterval pausedTime = [lab.layer timeOffset];
        lab.layer.speed = 1.0;
        lab.layer.timeOffset = 0.0;
        lab.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [lab.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        lab.layer.beginTime = timeSincePause;
    }
}

- (void)stopAnimate{
    for (NSUInteger i = 0; i < self.mtbLabArr.count; i++) {
        UILabel *lab = [self.mtbLabArr objectAtIndex:i];
        NSString *key = [NSString stringWithFormat:@"musicNameLab_position_x_%lu",(unsigned long)i];
        [lab.layer removeAnimationForKey:key];
    }
}

@end
