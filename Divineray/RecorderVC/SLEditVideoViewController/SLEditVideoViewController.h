//
//  SLEditVideoViewController.h
//  DivinerayVideoProcessing
//
//  Created by ""  on 08/10/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import "PostVideoModel.h"
#import "SLEditVideoViewBaseController.h"

@interface SLEditVideoViewController :SLEditVideoViewBaseController {  
}
@property (nonatomic, strong) PostVideoModel *postViewModel;

@end

