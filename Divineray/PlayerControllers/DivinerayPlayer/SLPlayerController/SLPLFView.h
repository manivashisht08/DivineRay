//
//  SLPLFView.h
//  Created by Single on 2017/2/24.
//  Copyright © 2017年 single. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SLPlayerMacro.h"

typedef UIView SLPLFView;
void SLPLFViewSetBackgroundColor(SLPLFView * view, UIColor * color);
void SLPLFViewInsertSubview(SLPLFView * superView, SLPLFView * subView, NSInteger index);

