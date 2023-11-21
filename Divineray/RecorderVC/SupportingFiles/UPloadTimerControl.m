//
//  UPloadTimerControl.m

#import "UPloadTimerControl.h"
#import "SLGlobalShared.h"

@interface NSTimer (UPloadTimerControl)
+ (NSTimer *)timer_timerWithTimeInterval:(NSTimeInterval)ti
                                   block:(void(^)(NSTimer *timer))block
                                 repeats:(BOOL)repeats;
@end

@implementation NSTimer (UPloadTimerControl)
+ (NSTimer *)timer_timerWithTimeInterval:(NSTimeInterval)ti
                                   block:(void(^)(NSTimer *timer))block
                                 repeats:(BOOL)repeats {
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:self
                                           selector:@selector(timer_exeBlock:)
                                           userInfo:block
                                            repeats:repeats];
    return timer;
}

+ (void)timer_exeBlock:(NSTimer *)timer {
    void(^block)(NSTimer *timer) = timer.userInfo;
    if ( block ) block(timer);
}

@end

@interface UPloadTimerControl ()
@property (nonatomic, strong) NSTimer *timer;
@end


@implementation UPloadTimerControl

- (instancetype)init {
    self = [super init];
    if ( self ) {
    }
    return self;
}


- (void)start {
    [self clear];
    
    __weak typeof(self) _self = self;
    _timer = [NSTimer timer_timerWithTimeInterval:TIMER_INTERVAL block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.executionBlock ) self.executionBlock(self);
    } repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
}

- (void)clear {
    [_timer invalidate];
    _timer = nil;
}

@end
