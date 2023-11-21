//
//  VideoUtilities.m
//  DivinerayVideoProcessing
//
//  Created by ""  on 03/10/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import "VideoUtilities.h"
#import "SLGlobalShared.h"
#import <UIKit/UIKit.h>
#import "SLGlobalShared.h"
#import "SLFileTools.h"
#import "SLFileHash.h"
#import "ISMessages.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

@implementation VideoUtilities



+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates withFrameSize:(CGSize) frameSize {
    
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize apertureSize = CGSizeMake(1280, 720);
    CGPoint point = viewCoordinates;
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    CGFloat xc = .5f;
    CGFloat yc = .5f;
    
    if (viewRatio > apertureRatio) {
        CGFloat y2 = frameSize.height;
        CGFloat x2 = frameSize.height * apertureRatio;
        CGFloat x1 = frameSize.width;
        CGFloat blackBar = (x1 - x2) / 2;
        if (point.x >= blackBar && point.x <= blackBar + x2) {
            xc = point.y / y2;
            yc = 1.f - ((point.x - blackBar) / x2);
        }
    }else {
        CGFloat y2 = frameSize.width / apertureRatio;
        CGFloat y1 = frameSize.height;
        CGFloat x2 = frameSize.width;
        CGFloat blackBar = (y1 - y2) / 2;
        if (point.y >= blackBar && point.y <= blackBar + y2) {
            xc = ((point.y - blackBar) / y2);
            yc = 1.f - (point.x / x2);
        }
    }
    pointOfInterest = CGPointMake(xc, yc);
    return pointOfInterest;
}

+ (CALayer *)setFocusImage {
    
    UIImage *focusImage = [UIImage imageNamed:@"cam_focus.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
    imageView.image = focusImage;
    CALayer *layer = imageView.layer;
    layer.hidden = YES;
    return layer;
}

+ (void)exportVideoInMp4Format:(NSURL *)videoFileURL completion:(void(^)(NSURL *mp4VideoURL, NSError *error))completion {
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoFileURL options:nil];
    
    if (videoAsset==nil||[videoAsset isKindOfClass:[NSNull class]]) {
        NSLog(@"Video export: incoming AVAsset is nil");
        completion(nil,nil);
        return;
    }
    
    NSString *outputPath = [SLFileTools getMp4FilePath];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
    exportSession.outputURL=[NSURL fileURLWithPath:outputPath];
    exportSession.outputFileType=AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse=YES;
    
    
    void(^exportCompletion)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(exportSession.outputURL, exportSession.error);
        });
    };
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted: {
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusFailed:{
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusCancelled:{
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
            }
            case AVAssetExportSessionStatusExporting : {
            }
            case AVAssetExportSessionStatusWaiting: {
            }
        };
    }];
}

/**
 Show the drop down message
 @param title -  Title
 @param message - Message
 */
+ (void)showDropDownAlertWithTitle:(NSString *)title withMessage:(NSString *)message isSucess:(BOOL)sucess {
    
    if(sucess) {
        [ISMessages showCardAlertWithTitle:title message:message duration:3.0 hideOnSwipe:YES hideOnTap:YES alertType: sucess?ISAlertTypeSuccess :ISAlertTypeSuccess  alertPosition:ISAlertPositionTop didHide:^(BOOL finished) {
        }];
        
    } else {
        [self showErrorDropDownAlertWithTitle:title withMessage:message isSucess:sucess];
    }
}

+ (void)showDropDownAlertWithTitleAtBottom:(NSString *)title withMessage:(NSString *)message {
    [ISMessages showCardAlertWithTitle:title message:message duration:3.0 hideOnSwipe:YES hideOnTap:YES alertType :ISAlertTypeError  alertPosition:ISAlertPositionBottom didHide:^(BOOL finished) {
    }];
}





+ (void)showBoxError:(NSDictionary*)userInfo {
    [[NSNotificationCenter defaultCenter]postNotificationName:kNetworkErrorNotification object:nil userInfo:userInfo];
}
+ (void)showBoxErrorLive:(NSDictionary*)userInfo {
    [[NSNotificationCenter defaultCenter]postNotificationName:kNetworkErrorNotificationLive object:nil userInfo:userInfo];
}

+ (void)showErrorDropDownAlertWithTitle:(NSString *)title withMessage:(NSString *)message isSucess:(BOOL)sucess {
    
    [ISMessages showCardAlertWithTitle:title message:message duration:3.0 hideOnSwipe:YES hideOnTap:YES alertType: ISAlertTypeError  alertPosition:ISAlertPositionTop didHide:^(BOOL finished) {
    }];
}
+(BOOL)isEmptyString:(NSString *)string {
    if([string length] == 0) { //string is empty or nil
        return YES;
    }
    if(![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        //string is all whitespace
        return YES;
    }
    return NO;
}

/**
 @param filepath - File Path of Video
 @return - Screen Shot of Video
 */
+ (UIImage *)generateThumbImage:(NSString *)filepath {
    
    NSURL *url = [NSURL fileURLWithPath:filepath];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    //  Get thumbnail at the very start of the video
    CMTime thumbnailTime = [asset duration];
    thumbnailTime.value = 0;
    
    CGImageRef imgRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:nil];
    UIImage* thumbnail = [[UIImage alloc] initWithCGImage:imgRef scale:UIViewContentModeScaleAspectFit orientation:UIImageOrientationUp];
    return thumbnail;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (CGFloat)getLabelHeight:(UILabel*)label
{
    if(label != nil && [label isKindOfClass:[UILabel class]])
    {
        NSString *text =  label.text;
        if([text isKindOfClass:[NSString class]] && [text length]> 0)
        {
            CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
            CGSize size;
            
            NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
            CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:label.font}
                                                          context:context].size;
            
            size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
            
            return size.height;
        }else
        {
            return 0;
        }
    }else
    {
        return 0;
    }
}

+ (CGFloat)getStringHeight:(NSString*)text andWidth:(float)width withFont:(UIFont*)font
{
   
        if([text isKindOfClass:[NSString class]] && [text length]> 0)
        {
            CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
            CGSize size;
            
            NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
            CGSize boundingBox = [text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:font}
                                                          context:context].size;
            
            size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
            
            return size.height;
        }else
        {
            return 0;
        }
    
}

+ (NSString *)formatTime:(NSInteger)elapsedSeconds {
    
    if(elapsedSeconds <= 0) return @"00:00:00";
    NSUInteger h = elapsedSeconds / 3600;
    NSUInteger m = (elapsedSeconds / 60) % 60;
    NSUInteger s = elapsedSeconds % 60;
    if(h > 0) return [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
    else return [NSString stringWithFormat:@"00:%02lu:%02lu", (unsigned long)m, (unsigned long)s];
}


/**
 Show Loading Alert
 @param view - View on which loading is shown
 */
+ (void)showLoadingAt:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
}

/**
 Hide Loading Alert
 @param view - View on which loading is shown
 */

+ (void)hideLoadingAt:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        //[MBProgressHUD hideHUDForView:view animated:YES];
        [SVProgressHUD dismiss];
    });
}
+(BOOL)isNetworkReachible {
   NSString *networkValue;

   Reachability *rc = [Reachability reachabilityWithHostName:@"https://www.google.com"];
   NetworkStatus internetStatus = [rc currentReachabilityStatus];

   if(internetStatus==0)
   {
       networkValue = @"NoAccess";
       return  NO;
   }
   else if(internetStatus==1)
   {
       networkValue = @"ReachableViaWiFi";

   } else if(internetStatus==2)
   {
       networkValue = @"ReachableViaWWAN";
   }
   else
   {
       networkValue = @"Reachable";
   }

    return  YES;
}
+ (UIViewContentMode)calculateMode:(NSString*)width withHeight:(NSString*)height {
    
        float videowidth = [width floatValue];
        float videoHeight = [height floatValue];
        float videoRatio = videowidth/videoHeight;
        float deviceRatio = [UIApplication sharedApplication].keyWindow.frame.size.width/[UIApplication sharedApplication].keyWindow.frame.size.height;
        
        float ratio = fabsf(deviceRatio - videoRatio);
        if (ratio < 0.12)
        {
            return UIViewContentModeScaleAspectFill;
        }else
        {
            return UIViewContentModeScaleAspectFit;
        }
    
    return UIViewContentModeScaleToFill;
}
@end
