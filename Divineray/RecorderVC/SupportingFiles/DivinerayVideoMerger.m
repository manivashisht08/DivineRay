//
//  DivinerayVideoMerger.m
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 04/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import "DivinerayVideoMerger.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@implementation DivinerayVideoMerger

+ (void)mergeRecordedVideosWithFileURLs:(NSArray *)videoFileURLs videoStoredPath:(NSString *)storedPath completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion {
    
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio     preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    CMTime totalDuration = kCMTimeZero;
    for (NSInteger videoSegment = 0; videoSegment < videoFileURLs.count; videoSegment++) {
        
        NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVAsset* asset = [AVURLAsset URLAssetWithURL:videoFileURLs[videoSegment] options:options];
        NSError *erroraudio = nil;
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];
        
        NSLog(@"erroraudio:%@%d",erroraudio,ba);
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        NSLog(@"errorVideo:%@%d",errorVideo,bl);
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    CGSize videoSize = [videoTrack naturalSize];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack* mixVideoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    NSURL *mergeFileURL = [NSURL fileURLWithPath:storedPath];
    
    //Video export tool
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPreset1280x720];
    exporter.videoComposition = videoComp;
    /*
     exporter.progress
     Export progress
     This property is not key-value observable.
     Does not support kvo listening
     Can only be monitored with a timer -   NStimer
     */
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    void(^exportCompletion)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(exporter.outputURL, exporter.error);
        });
    };
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
    
        switch (exporter.status) {
            case AVAssetExportSessionStatusCompleted: {
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Failed");
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusCancelled:{
                NSLog(@"Cancelled");
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
                NSLog(@"Unknown");
            }
            case AVAssetExportSessionStatusExporting : {
                NSLog(@"Exporting");
            }
            case AVAssetExportSessionStatusWaiting: {
                NSLog(@"Wating");
            }
        }
    }];
}


+ (void)mergeVideosWithFileURLs:(NSArray *)videoFileURLs videoStoredPath:(NSString *)storedPath
                     completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion
{
    
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSMutableArray *instructions = [NSMutableArray new];
    
    __block BOOL isError = NO;
    __block CMTime currentTime = kCMTimeZero;
    __block CGSize videoSize = CGSizeZero;
    __block int32_t highestFrameRate = 0;
    [videoFileURLs enumerateObjectsUsingBlock:^(NSURL *videoFileURL, NSUInteger idx, BOOL *stop) {
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoFileURL options:options];
        AVAssetTrack *videoAsset = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (CGSizeEqualToSize(videoSize, CGSizeZero)) {
            videoSize = videoAsset.naturalSize;
        }
        if (videoSize.height < videoAsset.naturalSize.height){
            videoSize.height = videoAsset.naturalSize.height;
        }
        if (videoSize.width < videoAsset.naturalSize.width){
            videoSize.width = videoAsset.naturalSize.width;
        }
    }];
    [videoFileURLs enumerateObjectsUsingBlock:^(NSURL *videoFileURL, NSUInteger idx, BOOL *stop) {
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoFileURL options:options];
        AVAssetTrack *videoAsset = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        AVAssetTrack *audioAsset = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        
        int32_t currentFrameRate = (int)roundf(videoAsset.nominalFrameRate);
        highestFrameRate = (currentFrameRate > highestFrameRate) ? currentFrameRate : highestFrameRate;
        
        
        CMTime trimmingTime = CMTimeMake(lround(videoAsset.naturalTimeScale / videoAsset.nominalFrameRate), videoAsset.naturalTimeScale);
        CMTimeRange timeRange = CMTimeRangeMake(trimmingTime, CMTimeSubtract(videoAsset.timeRange.duration, trimmingTime));
        
        
        NSError *videoError,*audioError;
        BOOL videoResult = [videoTrack insertTimeRange:timeRange ofTrack:videoAsset atTime:currentTime error:&videoError];
        BOOL audioResult = [audioTrack insertTimeRange:timeRange ofTrack:audioAsset atTime:currentTime error:&audioError];
        if (!audioResult || audioError){
            NSLog(@"%@", audioError);
        }
        if(!videoResult || videoError) {
            if (completion){
                completion(nil, videoError);}
            isError = YES;
            *stop = YES;
        } else {
            AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            videoCompositionInstruction.timeRange = CMTimeRangeMake(currentTime, timeRange.duration);
            
            AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            int tx = 0;
            if (videoSize.width-videoAsset.naturalSize.width != 0)
            {
                tx = (videoSize.width-videoAsset.naturalSize.width)/2;
            }
            int ty = 0;
            if (videoSize.height-videoAsset.naturalSize.height != 0)
            {
                ty = (videoSize.height-videoAsset.naturalSize.height)/2;
            }
            CGAffineTransform Scale = CGAffineTransformMakeScale(1,1);
            
            if (tx != 0 && ty!=0)
            {
                if (tx <= ty) {
                    float factor = videoSize.width/videoAsset.naturalSize.width;
                    Scale = CGAffineTransformMakeScale(factor,factor);
                    tx = 0;
                    ty = (videoSize.height-videoAsset.naturalSize.height*factor)/2;
                }
                if (tx > ty) {
                    float factor = videoSize.height/ videoAsset.naturalSize.height;
                    Scale = CGAffineTransformMakeScale(factor,factor);
                    ty = 0;
                    tx = (videoSize.width-videoAsset.naturalSize.width*factor)/2;
                }
            }
            CGAffineTransform Move = CGAffineTransformMakeTranslation(tx,ty);
            
            [layerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
            videoCompositionInstruction.layerInstructions = @[layerInstruction];
            
            [instructions addObject:videoCompositionInstruction];
            currentTime = CMTimeAdd(currentTime, timeRange.duration);
        }
    }];
    
    if (isError == NO) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        NSString *strFilePath = [DivinerayVideoMerger generateMergedVideoFilePath];
        exportSession.outputURL = [NSURL fileURLWithPath:strFilePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
        mutableVideoComposition.instructions = instructions;
        mutableVideoComposition.frameDuration = CMTimeMake(1, highestFrameRate);
        mutableVideoComposition.renderSize = videoSize;
        exportSession.videoComposition = mutableVideoComposition;
        NSURL *mergeFileURL = [NSURL fileURLWithPath:storedPath];
        exportSession.outputURL = mergeFileURL;

        
        NSLog(@"Composition Duration: %ld s", lround(CMTimeGetSeconds(composition.duration)));
        NSLog(@"Composition Framerate: %d fps", highestFrameRate);
        
        void(^exportCompletion)(void) = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(exportSession.outputURL, exportSession.error);
            });
        };
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"Successfully merged: %@", strFilePath);
                    exportCompletion();
                    break;
                }
                case AVAssetExportSessionStatusFailed:{
                    NSLog(@"Failed");
                    exportCompletion();
                    break;
                }
                case AVAssetExportSessionStatusCancelled:{
                    NSLog(@"Cancelled");
                    exportCompletion();
                    break;
                }
                case AVAssetExportSessionStatusUnknown: {
                    NSLog(@"Unknown");
                }
                case AVAssetExportSessionStatusExporting : {
                    NSLog(@"Exporting");
                }
                case AVAssetExportSessionStatusWaiting: {
                    NSLog(@"Wating");
                }
            };
        }];
    }
}

+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion {
    
    if (videoFileURLs.count != 4) {
        NSError *error = [[NSError alloc] initWithDomain:@"DPVideoMerger" code:404 userInfo:@{NSLocalizedDescriptionKey : @"Provide 4 Videos",NSLocalizedFailureReasonErrorKey : @"error"}];
        completion(nil,error);
        return;
    }
    
    AVMutableComposition* composition = [[AVMutableComposition alloc] init];
    
    __block CMTime maxTime = [AVURLAsset URLAssetWithURL:videoFileURLs[0] options:nil].duration;
    
    [videoFileURLs enumerateObjectsUsingBlock:^(NSURL *videoFileURL, NSUInteger idx, BOOL *stop) {
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoFileURL options:options];
        if (CMTimeCompare(maxTime, asset.duration) == -1) {
            maxTime = asset.duration;
        }
        
    }];
    
    AVMutableVideoCompositionInstruction * instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, maxTime);
    
    NSMutableArray *arrAVMutableVideoCompositionLayerInstruction = [NSMutableArray new];
    
    [videoFileURLs enumerateObjectsUsingBlock:^(NSURL *videoFileURL, NSUInteger idx, BOOL *stop) {
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:videoFileURL options:nil];
        
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        
        
        AVMutableVideoCompositionLayerInstruction *subInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        CGAffineTransform Scale = CGAffineTransformMakeScale(1,1);
        CGAffineTransform Move = CGAffineTransformMakeTranslation(0,0);
        int tx = 0;
        if (resolution.width/2-videoTrack.naturalSize.width != 0)
        {
            tx = (resolution.width/2-videoTrack.naturalSize.width)/2;
        }
        int ty = 0;
        if (resolution.height/2-videoTrack.naturalSize.height != 0)
        {
            ty = (resolution.height/2-videoTrack.naturalSize.height)/2;
        }
        
        if (tx != 0 && ty!=0)
        {
            if (tx <= ty) {
                float factor = resolution.width/2/videoTrack.naturalSize.width;
                Scale = CGAffineTransformMakeScale(factor,factor);
                tx = 0;
                ty = (resolution.height/2-videoTrack.naturalSize.height*factor)/2;
            }
            if (tx > ty) {
                float factor = resolution.height/2/ videoTrack.naturalSize.height;
                Scale = CGAffineTransformMakeScale(factor,factor);
                ty = 0;
                tx = (resolution.width/2-videoTrack.naturalSize.width*factor)/2;
            }
        }
        switch (idx) {
            case 0:
                Move = CGAffineTransformMakeTranslation(0+tx,0+ty);
                break;
            case 1:
                Move = CGAffineTransformMakeTranslation(resolution.width/2+tx,0+ty);
                break;
            case 2:
                Move = CGAffineTransformMakeTranslation(0+tx,resolution.height/2+ty);
                break;
            case 3:
                Move = CGAffineTransformMakeTranslation(resolution.width/2+tx,resolution.height/2+ty);
                break;
            default:
                break;
        }
        
        [subInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
        [arrAVMutableVideoCompositionLayerInstruction addObject:subInstruction];
    }];
    
    instruction.layerInstructions = arrAVMutableVideoCompositionLayerInstruction;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:instruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = resolution;
    
    NSURL *url = [NSURL fileURLWithPath:[DivinerayVideoMerger generateMergedVideoFilePath]];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    [exporter setVideoComposition:MainCompositionInst];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    void(^exportCompletion)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(exporter.outputURL, exporter.error);
        });
    };
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch (exporter.status) {
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"Successfully merged: %@", exporter.outputURL);
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Failed");
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusCancelled:{
                NSLog(@"Cancelled");
                exportCompletion();
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
                NSLog(@"Unknown");
            }
            case AVAssetExportSessionStatusExporting : {
                NSLog(@"Exporting");
            }
            case AVAssetExportSessionStatusWaiting: {
                NSLog(@"Wating");
            }
        };
    }];
}

+ (NSString *)generateMergedVideoFilePath{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-mergedVideo.mov", [[NSUUID UUID] UUIDString]]];
    //.mp4
}


+ (void)writeSLVideoToPhotoLibrary:(nonnull NSURL *)url completion:(void(^)(BOOL status))completion {
    if (url==nil||[url isKindOfClass:[NSNull class]]) {
        return;
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success==YES) {
            completion(YES);
        }
        else{
           completion(NO);
        }
    }];
}

@end
