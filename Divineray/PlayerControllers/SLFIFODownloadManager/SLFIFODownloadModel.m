//
//  SLFIFODownloadModel.m
//  SLFIFODownloadManager
//
//  Created by https://github.com/guowilling on 17/1/10.
//  Copyright © 2017年 SR. All rights reserved.
//

#import "SLFIFODownloadModel.h"

@implementation SLFIFODownloadModel

- (void)openOutputStream {
    if (!_outputStream) {
        return;
    }
    [_outputStream open];
}

- (void)closeOutputStream {
    if (!_outputStream) {
        return;
    }
    if (NSStreamStatusNotOpen < _outputStream.streamStatus && _outputStream.streamStatus < NSStreamStatusClosed) {
        [_outputStream close];
    }
    _outputStream = nil;
}

@end
