//
//  SlikeDownloadModel.h
//  SlikeMediaDownload
//
//  Created by ""  on 30/11/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlikeDownloadConstants.h"

@class SlikeMediaItem;

@interface SlikeDownloadModel : NSObject
/**
 Initialize with asset
 @param asset - slike asset
 @return - instance
 */
- (instancetype)initWithAsset:(SlikeMediaItem *)asset;

@property (strong, nonatomic) SlikeMediaItem *asset;
@property (nonatomic, strong) NSURLSessionDownloadTask *fileDownloadtask;
@property (nonatomic, strong) NSData *taskResumeData;
@property (nonatomic, copy) SLProgressBlock progressBlock;
@property (nonatomic, copy) SLCompletionBlock completionBlock;
@property (nonatomic, copy) SLStateBlock stateBlock;
@end


