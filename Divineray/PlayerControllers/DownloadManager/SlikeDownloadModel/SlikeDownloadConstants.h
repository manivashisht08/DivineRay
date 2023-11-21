//
//  SlikeDownloadConstants.h
//  SlikeDownloadConstants
//
//  Created by ""  on 06/12/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifndef SlikeDownloadConstants_h
#define SlikeDownloadConstants_h

// This will returns SlikeMediaItem
OBJC_EXTERN NSString * const kSlikeDownloadItemProgressKey;
OBJC_EXTERN NSString * const kSlikeDownloadItemProgressNotification;

OBJC_EXTERN NSString * const kSlikeDownloadItemsDeletedKey;
OBJC_EXTERN NSString * const kSlikeDownloadItemsDeletedNotification;

typedef NS_ENUM(NSInteger, SLDownloadState) {
    
    SLDownloadStateWaiting = 0,
    SLDownloadStateDownloading = 1,
    SLDownloadStateCanceled = 2,
    SLDownloadStateCompleted = 3,
    SLDownloadStateFailed = 4
};

//Typedefs for the blocks...
typedef void (^SLProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);
typedef void (^SLCompletionBlock)(BOOL success, NSString *filePath, NSError *error);
typedef void (^SLStateBlock)(SLDownloadState state);

#endif /* SlikeAssetConstants_h */


