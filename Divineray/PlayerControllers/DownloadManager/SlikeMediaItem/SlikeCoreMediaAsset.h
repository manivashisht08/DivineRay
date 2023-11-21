//
//  SlikeTrack.h
//  SlikeMediaDownload
//
//  Created by ""  on 06/12/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlikeDownloadConstants.h"

@interface SlikeCoreMediaAsset : NSObject

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, assign) double progress;
@property (nonatomic, strong) NSURL *downloadURL;
@property (nonatomic, strong) NSString *downloadedPath;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) SLDownloadState downloadingState;
@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) NSData* streamData;
@property (nonatomic, strong) NSDictionary* metaDataInfo;
@property (nonatomic, strong) NSError* error;
@end

@interface SlikeCoreMediaAsset(MediaAsset)
- (void)updateExistingMediaAsset:(SlikeCoreMediaAsset *)newAsset;
@end



