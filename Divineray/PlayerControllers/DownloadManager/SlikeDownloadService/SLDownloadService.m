//
//  SLDownloadService.m
//  SlikeMediaDownload
//
//  Created by ""  on 01/12/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import "SLDownloadService.h"
#import "SlikeDownloadModel.h"
#import "SlikeCoreMediaAsset.h"
#import "SlikeMediaItem.h"

@interface SLDownloadService() {
}

@end

@implementation SLDownloadService

- (instancetype)init {
    
    self = [super init];
    self.activeDownloads = [[NSMutableDictionary alloc]init];
    return self;
}

/**
 Start the downloading of media file
 @param downloadModel - Download Model
 */
- (void)startDownload:(SlikeDownloadModel *)downloadModel  {
    
    downloadModel.fileDownloadtask = [self.downloadsSession downloadTaskWithURL:downloadModel.asset.coreAsset.downloadURL];
    self.activeDownloads[downloadModel.asset.coreAsset.downloadURL] = downloadModel;
    [downloadModel.fileDownloadtask resume];
}

- (void)pauseDownload:(SlikeDownloadModel *)downloadModel {
    
    if (!_activeDownloads[downloadModel.asset.coreAsset.downloadURL]) {
        return;
    }
    if (downloadModel.asset.coreAsset.downloadingState == SLDownloadStateDownloading) {
        [downloadModel.fileDownloadtask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            downloadModel.taskResumeData = resumeData;
        }];
        downloadModel.asset.coreAsset.downloadingState = SLDownloadStateWaiting;
    }
}

- (void)cancelDownload:(SlikeDownloadModel *)downloadModel {
    if (_activeDownloads[downloadModel.asset.coreAsset.downloadURL]) {
        [downloadModel.fileDownloadtask cancel];
        _activeDownloads[downloadModel.asset.coreAsset.downloadURL] = nil;
    }
}

- (void)resumeDownload:(SlikeDownloadModel *)downloadModel {
    if (!_activeDownloads[downloadModel.asset.coreAsset.downloadURL]) {
        return;
    }
    
    if (downloadModel.taskResumeData) {
        downloadModel.fileDownloadtask = [_downloadsSession downloadTaskWithResumeData:downloadModel.taskResumeData];
    } else {
        downloadModel.fileDownloadtask = [self.downloadsSession downloadTaskWithURL:downloadModel.asset.coreAsset.downloadURL];
    }
    downloadModel.asset.coreAsset.downloadingState = SLDownloadStateDownloading;
    [downloadModel.fileDownloadtask resume];
}

@end
