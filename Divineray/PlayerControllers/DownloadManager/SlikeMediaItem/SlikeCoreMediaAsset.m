//
//  SlikeTrack.m
//  SlikeMediaDownload
//
//  Created by ""  on 06/12/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import "SlikeCoreMediaAsset.h"

@implementation SlikeCoreMediaAsset

- (instancetype)init {
    self = [super init];
    
    self.userId = @"";
    self.progress = 0.0;
    self.downloadURL = nil;
    self.downloadedPath = @"";
    self.downloadingState = SLDownloadStateWaiting;
    self.mediaType = @"";
    self.streamData =nil;
    self.metaDataInfo = @{};
    self.error = nil;
    return self;
}


@end

@implementation SlikeCoreMediaAsset(MediaAsset)

- (void)updateExistingMediaAsset:(SlikeCoreMediaAsset *)newAsset {
    self.userId = newAsset.userId;
    self.progress = newAsset.progress;
      self.mediaType = newAsset.mediaType;
    self.downloadURL = newAsset.downloadURL;
    self.downloadedPath = newAsset.downloadedPath;
    self.downloadingState = newAsset.downloadingState;
    self.metaDataInfo = newAsset.metaDataInfo;
    self.streamData = newAsset.streamData;
    self.metaDataInfo = newAsset.metaDataInfo;
    
}

@end

