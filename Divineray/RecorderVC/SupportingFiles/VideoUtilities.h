//
//  VideoUtilities.h
//  DivinerayVideoProcessing
//
//  Created by ""  on 03/10/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SLConstants.h"
#import "SLGlobalShared.h"
#import "UIView+Tools.h"

@interface VideoUtilities : NSObject
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates withFrameSize:(CGSize)frameSize;
+ (CALayer *)setFocusImage;

+ (void)exportVideoInMp4Format:(NSURL *)videoFileURL completion:(void(^)(NSURL *mp4VideoURL, NSError *error))completion;

+ (void)showLoadingAt:(UIView *)view;
+ (void)hideLoadingAt:(UIView *)view;
+ (void)showDropDownAlertWithTitle:(NSString *)title withMessage:(NSString *)message isSucess:(BOOL)sucess;
+ (void)showDropDownAlertWithTitleAtBottom:(NSString *)title withMessage:(NSString *)message;

+(BOOL)isEmptyString:(NSString *)string;

/**
 @param filepath - File Path of Video
 @return - Screen Shot of Video
 */
+ (UIImage *)generateThumbImage:(NSString *)filepath;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (CGFloat)getLabelHeight:(UILabel*)label;
+ (void)showErrorDropDownAlertWithTitle:(NSString *)title withMessage:(NSString *)message isSucess:(BOOL)sucess;
+ (void)showBoxError:(NSDictionary*)userInfo;
+ (NSString *)formatTime:(NSInteger)elapsedSeconds;
+ (void)showBoxErrorLive:(NSDictionary*)userInfo ;
+(BOOL)isNetworkReachible;
+ (UIViewContentMode)calculateMode:(NSString*)width withHeight:(NSString*)height;
@end


