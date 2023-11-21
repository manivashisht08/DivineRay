//
//  UIView+SmartHighlight.h
//  Oncam
//
//  Created by Gaurav Keshre on 11/11/13.
//  Copyright (c) 2018 Oncam Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#define HIGHLIGHT_SCALE_DURATION 0.5
#define HIGHLIGHT_SCALE_DURATION 0.3
@interface UIView (SmartHighlight)

-(void)focusWithScale:(CGFloat)scale;
-(void)dismissFocus;
@end

