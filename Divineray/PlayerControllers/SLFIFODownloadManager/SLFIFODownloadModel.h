//
//  SLFIFODownloadModel.h
//  SLFIFODownloadManager
//
//  Created by https://github.com/guowilling on 17/1/10.
//  Copyright © 2017年 SR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SlikeDownloadConstants.h"

@interface SLFIFODownloadModel : NSObject

@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, assign) NSInteger totalLength;

@property (nonatomic, copy) NSString *destPath;

@property (nonatomic, copy) SLStateBlock state;

@property (nonatomic, copy) SLProgressBlock progress;

@property (nonatomic, copy) SLCompletionBlock completion;

- (void)openOutputStream;

- (void)closeOutputStream;

@end
