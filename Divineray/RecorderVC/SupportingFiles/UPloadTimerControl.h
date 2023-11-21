//
//  UPloadTimerControl.h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UPloadTimerControl : NSObject
@property (nonatomic, copy, readwrite, nullable) void(^executionBlock)(UPloadTimerControl *control);
- (void)start;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
