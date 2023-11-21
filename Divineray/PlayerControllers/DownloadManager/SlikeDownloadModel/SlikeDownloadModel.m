//
//  SlikeDownloadModel.m
//  SlikeMediaDownload
//
//  Created by ""  on 30/11/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import "SlikeDownloadModel.h"
#import "SlikeMediaItem.h"

@implementation SlikeDownloadModel

- (instancetype)initWithAsset:(SlikeMediaItem *)asset  {
    if(self == [super init]) {
        self.asset = asset;
        _fileDownloadtask = nil;
        _taskResumeData = nil;
    }
    return self;
}
@end
