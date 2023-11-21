//
//  SLGlobalShared.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 02/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#ifndef SLGlobalShared_h
#define SLGlobalShared_h

#define KLUG_VIDEO_FOLDER                  @"SLRecordedVideo"
#define KLUG_DRAFT_FOLDER                  @"SLDraftVideo"

#define Divineray_VIDEO_RECORDING_TIME         16.0
#define TIMER_INTERVAL                     0.05
#define Divineray_VIDEO_MIN_RECORDING_TIME     5.0

#define Screen_WIDTH   [UIScreen mainScreen].bounds.size.width
#define Screen_HEIGTH  [UIScreen mainScreen].bounds.size.height
#define ScreenSize  [[UIScreen mainScreen]bounds]

#define Width(i) i*(Screen_WIDTH/375)
#define FONT(x)        [UIFont systemFontOfSize:Width(x)]
#define BOLD_FONT(x)   [UIFont boldSystemFontOfSize:Width(x)]


#define SL_STRIP_INREVIEW_COLOR [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.80]
#define SL_STRIP_BLOCKED_COLOR [UIColor colorWithRed:255/255.0 green:91/255.0 blue:65/255.0 alpha:0.90]

#define SL_INREVIEW_BG_COLOR [UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:0.80]



#define SLKlugRGBA(r, g, b, a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


#define SLKlugFiltersImagePath(file)  [UIImage imageNamed:[NSString stringWithFormat:@"FilterAssets/%@", file] inBundle:[NSBundle DivineraylyImagesBundle] compatibleWithTraitCollection:nil]

#define SLKlugSharedImagePath(file)  [UIImage imageNamed:[NSString stringWithFormat:@"SharedImages/%@", file] inBundle:[NSBundle DivineraylyImagesBundle] compatibleWithTraitCollection:nil]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define SLSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SLSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#endif /* SLGlobalShared_h */
