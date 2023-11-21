//
//  SLPLFView.m
//  Created by  on 2017/2/24.
//  Copyright © 2017年 single. All rights reserved.
//

#import "SLPLFView.h"

void SLPLFViewSetBackgroundColor(SLPLFView * view, UIColor * color) {
    view.backgroundColor = color;
}

void SLPLFViewInsertSubview(SLPLFView * superView, SLPLFView * subView, NSInteger index) {
    [superView insertSubview:subView atIndex:index];
}
