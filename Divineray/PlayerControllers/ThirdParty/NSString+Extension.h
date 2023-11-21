
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface NSString (Extension)
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;
@end
