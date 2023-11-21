//
//  UITextField+slTextField.h
//  OakHeads
//
//  Created by "" Rathor on 25/05/15.
//
//

#import <UIKit/UIKit.h>

@interface UITextField (slTextField)

- (void)setPlaceholder:(NSString *)placeholder withColor:(UIColor *)color;
- (void) setLeftPadding:(int) paddingValue;
- (void) setRightPadding:(int) paddingValue;

@end


@interface UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding;
- (void)centerVertically;
- (void)centerVertically:(float)padding;
@end

