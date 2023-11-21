
#import "UITextField+slTextField.h"
@implementation UITextField (slTextField)

- (void)setPlaceholder:(NSString *)placeholder withColor:(UIColor *)color {
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{ NSForegroundColorAttributeName: color }];
}

- (void)setLeftPadding:(int) paddingValue {
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingValue, self.frame.size.height)];
    paddingView.backgroundColor = self.backgroundColor;
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setRightPadding:(int) paddingValue {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingValue, self.frame.size.height)];
    paddingView.backgroundColor = self.backgroundColor;
    self.rightView = paddingView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

@end

@implementation UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding {
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGFloat totalHeight = (imageSize.height + titleSize.height + padding);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height),
                                            0.0f,
                                            0.0f,
                                            - titleSize.width);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                            - imageSize.width,
                                            - (totalHeight - titleSize.height),
                                            0.0f);
}

- (void)centerVertically {
    const CGFloat kDefaultPadding = 5.0f;
    [self centerVerticallyWithPadding:kDefaultPadding];
    [self centerImageAndButton:kDefaultPadding imageOnTop:YES];
}

- (void)centerVertically:(float)padding {
    [self centerVerticallyWithPadding:padding];
    [self centerImageAndButton:padding imageOnTop:YES];
}

- (void)centerImageAndButton:(CGFloat)gap imageOnTop:(BOOL)imageOnTop {
    NSInteger sign = imageOnTop ? 1 : -1;
    CGSize imageSize = self.imageView.frame.size;
    self.titleEdgeInsets = UIEdgeInsetsMake((imageSize.height+gap)*sign, -imageSize.width, 0, 0);
    CGSize titleSize = self.titleLabel.bounds.size;
    self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height+gap)*sign, 0, 0, -titleSize.width);
    
}


@end

