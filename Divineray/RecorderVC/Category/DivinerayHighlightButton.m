
#import "DivinerayHighlightButton.h"
#import "UIView+SmartHighlight.h"
@implementation DivinerayHighlightButton


#pragma mark - UIGesture Delegate Methods
/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self focusWithScale:1.3];
    float difx = [[touches anyObject] locationInView:self].x - [[touches anyObject] previousLocationInView:self].x;
    float dify = [[touches anyObject] locationInView:self].y - [[touches anyObject] previousLocationInView:self].y;
    CGAffineTransform newTransform = CGAffineTransformTranslate(self.transform, difx, dify);
    self.transform = newTransform;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dismissFocus];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dismissFocus];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    float difx = [[touches anyObject] locationInView:self].x - [[touches anyObject] previousLocationInView:self].x;
    float dify = [[touches anyObject] locationInView:self].y - [[touches anyObject] previousLocationInView:self].y;
    CGAffineTransform newTransform = CGAffineTransformTranslate(self.transform, difx, dify);
    self.transform = newTransform;
}

- (void)translateFocus {
    //[self dismissFocus];
}


- (void)startAnimation {
    //[self focusWithScale:1.2];
}*/
@end
