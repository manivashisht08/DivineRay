//
//  SLVideoTool.m
//    
//
//  Created by Vivek Dharmai.
//  Copyright © 2019. All rights reserved.
//

#import "SLVideoTool.h"

@implementation SLVideoTool

#pragma mark - Album video save local path
+(NSString *)mh_albumVideoOutTempPath
{
    NSString * tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"albumVideoTemp"];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if(![fileManage fileExistsAtPath:tempPath]){
            [fileManage createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    NSString * fileName = [NSString stringWithFormat:@"VideoCompressionTemp%f.mp4",time];
    NSString *outPath =  [tempPath stringByAppendingPathComponent:fileName];
    if([fileManage fileExistsAtPath:outPath]){
        [fileManage removeItemAtPath:outPath error:nil];
    }
    return outPath;
}
#pragma mark - Get the thumbnail method of the video
+ (UIImage *)mh_getVideoTempImageFromVideo:(NSURL *)videoUrl withTime:(CGFloat)theTime {
    if (!videoUrl) {
        return nil;
    }
    AVURLAsset * asset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    CGFloat timescale = asset.duration.timescale;
    UIImage *shotImage;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    
    CGFloat width = [UIScreen mainScreen].scale * 100;
    CGFloat height = width * [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
    gen.maximumSize =  CGSizeMake(width, height);
    
    CMTime time = CMTimeMakeWithSeconds(theTime, timescale);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}
#pragma mark - Get video length
+(CGFloat)mh_getVideolength:(NSURL *)videoUrl
{
    AVURLAsset * asset = [AVURLAsset assetWithURL:videoUrl];
    CGFloat length = (CGFloat)asset.duration.value/(CGFloat)asset.duration.timescale;
    return length;
}
#pragma mark - Video rotation angle
+(NSUInteger)mh_getDegressFromVideoWithURL:(NSURL *)url
{
    NSUInteger degress = 0;
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}
#pragma mark - Get video size
+(CGSize)mh_getVideoSize:(NSURL *)videoUrl
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];
    CGSize videoSize = CGSizeZero;
    for (AVAssetTrack *track in asset.tracks) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
        }
    }
    return videoSize;
}
#pragma mark - Adjust the size of the video output according to the ratio, width=480
+(CGSize)mh_fixVideoOutPutSize:(CGSize)nomSize
{
    if (nomSize.width <= 480.0) {
        return nomSize;
    }
    CGFloat height = nomSize.height * 480.0 / nomSize.width;
    return CGSizeMake(480.0, height);
}
#pragma mark - Save video to album
+(void)mh_writeVideoToPhotosAlbum:(NSURL *)videoUrl callBack:(void (^)(BOOL))callBack
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoUrl]) {
        [library writeVideoAtPathToSavedPhotosAlbum:videoUrl completionBlock:^(NSURL *assetURL, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    if (callBack) {
                        callBack(NO);
                    }
                } else {
                    if (callBack) {
                        callBack(YES);
                    }
                }
            });
        }];
    }
}
#pragma mark - Change video speed
+(void)changeVideoSpeed:(NSURL *)videoUrl speed:(CGFloat)speed outPutUrl:(NSURL *)outPutUrl callBack:(void (^)(BOOL))callBack
{
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //Add video track information
    AVMutableCompositionTrack * videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero
                          error:nil];
    
    // Adjust audio and video based on speed ratio
    [videoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale))
                    toDuration:CMTimeMake(videoAsset.duration.value * speed , videoAsset.duration.timescale)];
    
    if ([videoAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        AVMutableCompositionTrack * audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                            ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:nil];
        
        [audioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale))
                        toDuration:CMTimeMake(videoAsset.duration.value * speed, videoAsset.duration.timescale)];
    }
    
    //Output file
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL=outPutUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                callBack(YES);
            }else{
                callBack(NO);
            }
        });
    }];
}
#pragma mark - Combine multiple videos into one video
+(void)mergeVideosWithPaths:(NSArray *)paths outPutUrl:(NSURL *)outPutUrl callBack:(void (^)(BOOL, NSURL *))callBack
{
    if (paths.count == 0) {
        callBack(NO,nil);
        return;
    }
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < paths.count; i ++) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:paths[i]]];
        
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        
        NSError *errorVideo = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetVideoTrack atTime:totalDuration error:&errorVideo];
        
        
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        NSError *erroraudio = nil;
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetAudioTrack atTime:totalDuration error:&erroraudio];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    
    //Output file
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL=outPutUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                callBack(YES,outPutUrl);
            }else{
                callBack(NO,outPutUrl);
            }
        });
    }];
}
#pragma mark - Audio cropping
+(void)crapMusicWithUrl:(NSURL *)bgmUrl startTime:(CGFloat)startTime length:(CGFloat)length callBack:(void (^)(BOOL, NSURL *))callBack
{
    AVAsset *asset = [AVAsset assetWithURL:bgmUrl];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    //Clip (set the time period of the export)
    CMTime start = CMTimeMakeWithSeconds(startTime, asset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(length,asset.duration.timescale);
    exporter.timeRange = CMTimeRangeMake(start, duration);
    
    //Output path
    NSURL * outPutUrl = [NSURL fileURLWithPath:[SLVideoTool musicCrapOutPutTempPath]];
    exporter.outputURL = outPutUrl;
    exporter.outputFileType = AVFileTypeAppleM4A;
    exporter.shouldOptimizeForNetworkUse= YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            callBack(YES,outPutUrl);
        }else{
            callBack(NO,nil);
        }
    }];
}
#pragma mark - Output path (temporary folder) when cropping audio
+(NSString *)musicCrapOutPutTempPath
{
    NSString * tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"musicTemp"];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if(![fileManage fileExistsAtPath:tempPath]){
            [fileManage createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    NSString * fileName = [NSString stringWithFormat:@"musicCrapTemp%f.m4a",time];
    NSString *outPath =  [tempPath stringByAppendingPathComponent:fileName];
    if([fileManage fileExistsAtPath:outPath]){
        [fileManage removeItemAtPath:outPath error:nil];
    }
    return outPath;
}
#pragma mark - Merge video + background music Adjust the volume of the original video's audio and background music at the same time
+(void)mergevideoWithVideoUrl:(NSURL *)videoUrl originalAudioTrackVideoUrl:(NSURL *)originalAudioTrackVideoUrl bgmUrl:(NSURL *)bgmUrl originalVolume:(CGFloat)originalVolume bgmVolume:(CGFloat)bgmVolume outPutUrl:(NSURL *)outPutUrl callBack:(void (^)(BOOL, NSURL *))callBack
{
    //Create merge composition
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    //Add video track information
    AVURLAsset * inputVideoAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    AVMutableCompositionTrack * videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, inputVideoAsset.duration)
                        ofTrack:[[inputVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero
                          error:nil];
    
    //Add audio track information that comes with the video
    //Save audio volume data
    NSMutableArray * audioInputParamsArr = [NSMutableArray arrayWithCapacity:0];
    
    AVURLAsset * originalVideoAsset = [AVURLAsset URLAssetWithURL:originalAudioTrackVideoUrl options:nil];
    if ([originalVideoAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        
        AVMutableCompositionTrack * audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, inputVideoAsset.duration)
                            ofTrack:[[originalVideoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:nil];
        
        //Adjust volume
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        [audioInputParams setVolumeRampFromStartVolume:originalVolume toEndVolume:.0f timeRange:CMTimeRangeMake(kCMTimeZero, originalVideoAsset.duration)];
        [audioInputParams setTrackID:audioTrack.trackID];
        
        [audioInputParamsArr addObject:audioInputParams];
    }
    
    //Add background music audio track information
    if (bgmUrl && bgmUrl.absoluteString.length > 0) {
        AVURLAsset * inputAudioAsset = [AVURLAsset URLAssetWithURL:bgmUrl options:nil];
        if ([inputAudioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
            AVMutableCompositionTrack * addAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [addAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, inputVideoAsset.duration)
                                   ofTrack:[[inputAudioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                    atTime:kCMTimeZero
                                     error:nil];
            
            //Adjust volume
            AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:addAudioTrack];
            [audioInputParams setVolumeRampFromStartVolume:bgmVolume toEndVolume:.0f timeRange:CMTimeRangeMake(kCMTimeZero, inputVideoAsset.duration)];
            [audioInputParams setTrackID:addAudioTrack.trackID];
            
            [audioInputParamsArr addObject:audioInputParams];
        }
    }
    
    //Handling video rotation and scaling
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, inputVideoAsset.duration);
    
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *videoAssetTrack = [[inputVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    CGSize videoSize = videoAssetTrack.naturalSize;
    if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)
    {
        videoTransform = CGAffineTransformTranslate(videoTransform,0,videoTransform.tx-videoSize.height);
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    [videolayerInstruction setTransform:videoTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:inputVideoAsset.duration];
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.renderSize = videoSize;
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);//fps
    
    //Audio adjustment
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithArray:audioInputParamsArr];
    
    //Output file
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL=outPutUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    exporter.audioMix = audioMix;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                callBack(YES,outPutUrl);
            }else{
                callBack(NO,nil);
            }
        });
        
        
    }];
}

+ (UIViewContentMode)determineVideoContentMode:(CGSize)videoSize {
    
    float videowidth = videoSize.width;
    float videoHeight = videoSize.height;
    if (videowidth <=0 || videoHeight<=0) {
        return UIViewContentModeScaleToFill;
    }
    
    float deviceRatio = [UIApplication sharedApplication].keyWindow.frame.size.width/[UIApplication sharedApplication].keyWindow.frame.size.height;
    
    float videoRatio = videowidth/videoHeight;
    float ratio = fabsf(deviceRatio - videoRatio);
    if (ratio < 0.12) {
        return UIViewContentModeScaleAspectFill;
    } else {
        return UIViewContentModeScaleAspectFit;
    }
}

@end
