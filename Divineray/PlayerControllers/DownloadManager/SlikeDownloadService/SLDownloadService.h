//
//  SLDownloadService.h
//  SlikeMediaDownload
//
//  Created by ""  on 01/12/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SlikeDownloadModel;

@interface SLDownloadService : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSURL *,SlikeDownloadModel*>* activeDownloads;
@property (nonatomic, strong) NSURLSession *downloadsSession;

/**
 Start the downloading of the Media
 @param downloadModel - downloading model
 */
- (void)startDownload:(SlikeDownloadModel *)downloadModel;

/**
 Pause the downloading of the Media
 @param downloadModel - downloading model
 */
- (void)pauseDownload:(SlikeDownloadModel *)downloadModel;

/**
 Cancel the downloading of the Media
 @param downloadModel - downloading model
 */
- (void)cancelDownload:(SlikeDownloadModel *)downloadModel;

/**
 Resume the downloading of the Media
 @param downloadModel - downloading model
 */
- (void)resumeDownload:(SlikeDownloadModel *)downloadModel;

@end

