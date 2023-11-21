//  Created by Vivek Dharmai Rathor on 16/06/20.
//  Copyright © 2018. All rights reserved.
//
//  SLVideoEditor.m

#import "SLVideoEditor.h"
#import "SDAVAssetExportSession.h"

#define SLNotificationCenter [NSNotificationCenter defaultCenter]
#define SLRadians( degrees ) (M_PI * ( degrees ) / 180.0 )


@implementation SLVideoEditor

#pragma mark - Video merge
+(void)composeWithOriginalVideoUrl:(NSURL *)originalVideoUrl otherVideoUrl:(NSURL *)otherVideoUrl completion:(void (^)(BOOL, NSString *, AVAsset *, AVMutableAudioMix *, AVMutableVideoComposition *))block{
    if (originalVideoUrl==nil||[originalVideoUrl isKindOfClass:[NSNull class]]||otherVideoUrl==nil||[otherVideoUrl isKindOfClass:[NSNull class]]) {
        if (block) {
            block(NO,@"Video merge: incoming originalVideoUrl or otherVideoUrl is nil",nil,nil,nil);
        }
        return;
    }
    
    AVURLAsset *originalAsset = [[AVURLAsset alloc] initWithURL:originalVideoUrl options:nil];
    AVURLAsset *otherAsset = [[AVURLAsset alloc] initWithURL:otherVideoUrl options:nil];
    
    [self composeWithOriginalAVAsset:originalAsset otherAVAsset:otherAsset completion:block];
}
+(void)composeWithOriginalAVAsset:(AVAsset *)originalAsset otherAVAsset:(AVAsset *)otherAsset completion:(void(^)(BOOL success,NSString *error,AVAsset *asset,AVMutableAudioMix *audioMix,AVMutableVideoComposition *videoComposition))block{
    
    if (originalAsset==nil||[originalAsset isKindOfClass:[NSNull class]]||otherAsset==nil||[otherAsset isKindOfClass:[NSNull class]]) {
        if (block) {
            block(NO,@"Video merge: incoming originalAsset or otherAsset is nil",nil,nil,nil);
        }
        return;
    }
    
    CGFloat originalDuration=CMTimeGetSeconds([originalAsset duration]);
    CGFloat otherDuration=CMTimeGetSeconds([otherAsset duration]);
    
    //Video resource
    AVAssetTrack *originalVideoTrack = [self getAssetTrackWithMediaType:AVMediaTypeVideo asset:originalAsset];
    AVAssetTrack *otherVideoTrack = [self getAssetTrackWithMediaType:AVMediaTypeVideo asset:otherAsset];
    
    //Audio resource
    AVAssetTrack *originalAudioTrack = [self getAssetTrackWithMediaType:AVMediaTypeAudio asset:originalAsset];
    AVAssetTrack *otherAudioTrack = [self getAssetTrackWithMediaType:AVMediaTypeAudio asset:otherAsset];
    
    AVMutableComposition *composition=[AVMutableComposition composition];
    NSError *error=nil;
    
    //Combined audio
    AVMutableAudioMix *audioMix=nil;
    
    //original Audio resource
    if (originalAudioTrack!=nil) {
        [self insertTrack:originalAudioTrack
            toComposition:composition
                mediaType:AVMediaTypeAudio
         preferredTrackID:kCMPersistentTrackID_Invalid
          insertTimeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(originalDuration,1))
                   atTime:kCMTimeZero
                    error:&error];
        
        if (error) {
            if (block) {
                block(NO,[NSString stringWithFormat:@"Error merging originalVideo audio resource:%@",error],nil,nil,nil);
            }
            return;
        }
    }
    else{
        NSLog(@"Video Merge: The provided originalVideo resource has no audio resources internally or does not support the video format.");
    }
    //other Audio resource
    if (otherAudioTrack!=nil) {
        AVMutableCompositionTrack *audioTrack=[self insertTrack:otherAudioTrack
                                                  toComposition:composition
                                                      mediaType:AVMediaTypeAudio
                                               preferredTrackID:kCMPersistentTrackID_Invalid
                                                insertTimeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(otherDuration,1))
                                                         atTime:CMTimeMakeWithSeconds(originalDuration,1)
                                                          error:&error];
        
        if (error) {
            if (block) {
                block(NO,[NSString stringWithFormat:@"Error mergeing otherVideo audio resources:%@",error],nil,nil,nil);
            }
            return;
        }
        
        if (audioTrack) {
            AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
            [mixParameters setVolumeRampFromStartVolume:1 toEndVolume:1 timeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(otherDuration,1))];
            
            audioMix=[AVMutableAudioMix audioMix];
            audioMix.inputParameters=@[mixParameters];
        }
    }
    else{
        NSLog(@"Video merge: The provided otherVideo resource has no audio resources or does not support the video format.");
    }
    
    //合并视频
    AVMutableVideoComposition *videoComposition=nil;
    NSMutableArray *videoArr=[[NSMutableArray alloc] init];
    
    AVMutableVideoCompositionLayerInstruction *originalLayerInstruction=nil;
    AVMutableVideoCompositionLayerInstruction *otherLayerInstruction=nil;
    
    CGAffineTransform originalTransform;
    CGAffineTransform otherTransform;
    
    UIImageOrientation originalOrientation=UIImageOrientationUp;
    UIImageOrientation otherOrientation=UIImageOrientationUp;
    
    //original Video resource
    if (originalVideoTrack!=nil) {
        AVMutableCompositionTrack *videoTrack=[self insertTrack:originalVideoTrack
                                                  toComposition:composition
                                                      mediaType:AVMediaTypeVideo
                                               preferredTrackID:kCMPersistentTrackID_Invalid
                                                insertTimeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(originalDuration,1))
                                                         atTime:kCMTimeZero
                                                          error:&error];
        
        if (error) {
            if (block) {
                block(NO,[NSString stringWithFormat:@"Error merging originalVideo video resource:%@",error],nil,nil,nil);
            }
            return;
        }
        
        if (videoTrack) {
            originalLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            //视频ImageOrientation方向
            originalOrientation=[self getUIImageOrientationWithAssetTrack:originalVideoTrack];
            
            //修正视频方向
            originalTransform=[self getTransformWithAssetTrack:originalVideoTrack imageOrientation:originalOrientation];
        }
    }
    else{
        NSLog(@"Video merge: The provided originalVideo resource has no video resources or does not support the video format.");
    }
    //other Video resource
    if (otherVideoTrack!=nil) {
        AVMutableCompositionTrack *videoTrack=[self insertTrack:otherVideoTrack
                                                  toComposition:composition
                                                      mediaType:AVMediaTypeVideo
                                               preferredTrackID:kCMPersistentTrackID_Invalid
                                                insertTimeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(otherDuration,1))
                                                         atTime:CMTimeMakeWithSeconds(originalDuration,1)
                                                          error:&error];
        
        if (error) {
            if (block) {
                block(NO,[NSString stringWithFormat:@"Error mergeing otherVideo video resources:%@",error],nil,nil,nil);
            }
            return;
        }
        
        if (videoTrack) {
            otherLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            //Video ImageOrientation direction
            otherOrientation=[self getUIImageOrientationWithAssetTrack:otherVideoTrack];
            
            //Fix video direction
            otherTransform=[self getTransformWithAssetTrack:otherVideoTrack imageOrientation:otherOrientation];
        }
    }
    else{
        NSLog(@"Video merge: The provided otherVideo resource has no video resources or does not support the video format.");
    }
    
    CGFloat originalWidth;
    CGFloat originalHeight;
    CGFloat otherWidth;
    CGFloat otherHeight;
    
    BOOL isOriginalPortrait=NO,isOtherPortrait=NO;
    if (originalOrientation==UIImageOrientationDown||originalOrientation==UIImageOrientationUp) {
        isOriginalPortrait=YES;
    }
    if (otherOrientation==UIImageOrientationDown||otherOrientation==UIImageOrientationUp) {
        isOtherPortrait=YES;
    }
    
    if (isOriginalPortrait==YES&&isOtherPortrait==YES&&originalOrientation==otherOrientation) {
        //Both videos are vertical and identical
        originalWidth=originalVideoTrack.naturalSize.width;
        originalHeight=originalVideoTrack.naturalSize.height;
        otherWidth=otherVideoTrack.naturalSize.width;
        otherHeight=otherVideoTrack.naturalSize.height;
    }
    else{
        originalWidth=MIN(originalVideoTrack.naturalSize.width,originalVideoTrack.naturalSize.height);
        originalHeight=MAX(originalVideoTrack.naturalSize.width,originalVideoTrack.naturalSize.height);
        otherWidth=MIN(otherVideoTrack.naturalSize.width,otherVideoTrack.naturalSize.height);
        otherHeight=MAX(otherVideoTrack.naturalSize.width,otherVideoTrack.naturalSize.height);
    }
    
    //Get the final rendering size of the composite video
    CGFloat renderWidth=MAX(originalWidth,otherWidth);
    CGFloat renderHeight=MAX(originalHeight,otherHeight);
    
    //Determine if an originalLayerInstruction object exists
    if (originalLayerInstruction) {
        CGFloat spanWidth=0;
        CGFloat spanHeight=0;
        
        if (renderWidth>originalWidth) {
            //Poor to the final video rendering width
            spanWidth=renderWidth-originalWidth;
        }
        if (renderHeight>originalHeight) {
            //High difference from final video rendering
            spanHeight=renderHeight-originalHeight;
        }
        if (spanWidth!=0||spanHeight!=0) {
            CGAffineTransform t=originalTransform;
            originalTransform=CGAffineTransformTranslate(t,spanWidth/2,spanHeight/2);
        }
        
        [originalLayerInstruction setTransform:originalTransform atTime:kCMTimeZero];
        [originalLayerInstruction setOpacity:0 atTime:CMTimeMakeWithSeconds(originalDuration,1)];
        [videoArr addObject:originalLayerInstruction];
    }
    
    //Determine if there is anotherLayerInstruction object
    if (otherLayerInstruction) {
        CGFloat spanWidth=0;
        CGFloat spanHeight=0;
        
        if (renderWidth>otherWidth) {
            //Poor to the final video rendering width
            spanWidth=renderWidth-otherWidth;
        }
        if (renderHeight>otherHeight) {
            //High difference from final video rendering
            spanHeight=renderHeight-otherHeight;
        }
        if (spanWidth!=0||spanHeight!=0) {
            CGAffineTransform t = otherTransform;
            otherTransform=CGAffineTransformTranslate(t,spanWidth/2,spanHeight/2);
        }
        
        [otherLayerInstruction setTransform:otherTransform atTime:CMTimeMakeWithSeconds(originalDuration-0.5,1)];
        [videoArr addObject:otherLayerInstruction];
    }
    
    //Determine if there is a LayerInstruction video resource, and if there is a composite
    if (videoArr.count>0) {
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange=CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(originalDuration+otherDuration,1));
        instruction.layerInstructions=videoArr;
        
        videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.instructions=[NSArray arrayWithObject:instruction];
        videoComposition.frameDuration = CMTimeMake(1,30);
        videoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    }
    else{
        NSLog(@"Video merge: The provided originalVideo and otherVideo resources have no video resources inside, and may not support video formats.");
    }
    
    
    if (block) {
        block(YES,@"",composition,audioMix,videoComposition);
    }
}
#pragma mark - Video cut
+(void)trimWithVideoUrl:(NSURL *)videoUrl start:(CGFloat)startTime end:(CGFloat)endTime completion:(void (^)(BOOL, NSString *, AVAsset *))block{
    if (videoUrl==nil||[videoUrl isKindOfClass:[NSNull class]]) {
        if (block) {
            block(NO,@"Video cut: incoming videoUrl is nil",nil);
        }
        return;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    [self trimWithAVAsset:asset start:startTime end:endTime completion:block];
}
+(void)trimWithAVAsset:(AVAsset *)asset start:(CGFloat)startTime end:(CGFloat)endTime completion:(void(^)(BOOL success,NSString *error,AVAsset *asset))block{
    if (asset==nil||[asset isKindOfClass:[NSNull class]]) {
        if (block) {
            block(NO,@"Video cut: the incoming video resource asset is nil",nil);
        }
        return;
    }
    if (startTime<0) {
        startTime=0;
    }
    
    if (startTime>=endTime) {
        if (block) {
            block(NO,@"Video cut: startTime is greater than endTime",nil);
        }
        return;
    }
    
    //Video resource
    AVAssetTrack *assetVideoTrack = [self getAssetTrackWithMediaType:AVMediaTypeVideo asset:asset];
    //Audio resource
    AVAssetTrack *assetAudioTrack = [self getAssetTrackWithMediaType:AVMediaTypeAudio asset:asset];
    
    //Handling the video time period to be cut
    CGFloat assetDuration=CMTimeGetSeconds([asset duration]);
    if (startTime>=assetDuration) {
        if (block) {
            block(NO,[NSString stringWithFormat:@"The parameter startTime:%f is greater than the total video time: %f. If the total time is 0, the video format may not be supported.",startTime,assetDuration],nil);
        }
        return;
    }
    CMTime startPoint=CMTimeMakeWithSeconds(startTime,1);
    CMTime trimmedDuration = (endTime>=assetDuration)?CMTimeMakeWithSeconds(assetDuration-startTime,1):CMTimeMakeWithSeconds(endTime-startTime,1);
    
    //Composition object is mainly audio and video combination
    AVMutableComposition *composition=[AVMutableComposition composition];
    NSError *error=nil;
    
    if(assetVideoTrack!=nil) {
        //Composition add video resources
        [self insertTrack:assetVideoTrack
            toComposition:composition
                mediaType:AVMediaTypeVideo
         preferredTrackID:kCMPersistentTrackID_Invalid
          insertTimeRange:CMTimeRangeMake(startPoint,trimmedDuration)
                   atTime:kCMTimeZero
                    error:&error];
        
        if (error) {
            if (block) {
                block(NO,[NSString stringWithFormat:@"Error cutting video resources:%@",error],nil);
            }
            return;
        }
    }
    else{
        NSLog(@"Video Clipping: The provided resource has no video resources internally or does not support the video format.");
    }
    
    if(assetAudioTrack != nil) {
        //Composition add audio resources
        [self insertTrack:assetAudioTrack
            toComposition:composition
                mediaType:AVMediaTypeAudio
         preferredTrackID:kCMPersistentTrackID_Invalid
          insertTimeRange:CMTimeRangeMake(startPoint,trimmedDuration)
                   atTime:kCMTimeZero
                    error:&error];
        
        if (error) {
            if (block) {
                block(NO,[NSString stringWithFormat:@"Error cutting audio resources:%@",error],nil);
            }
            return;
        }
    }
    else{
        NSLog(@"Video Clipping: The provided resource has no audio resources internally or does not support the video format.");
    }
    
    if (block) {
        block(YES,@"",composition);
    }
}
#pragma mark - Video watermark
+(void)addWatermarkWithVideoUrl:(NSURL *)videoUrl image:(UIImage *)image frame:(CGRect)frame completion:(void (^)(BOOL, NSString *, AVAsset *, AVMutableVideoComposition *))block{
    if (videoUrl==nil||[videoUrl isKindOfClass:[NSNull class]]) {
        if (block) {
            block(NO,@"Video add watermark: incoming videoUrl is nil",nil,nil);
        }
        return;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    [self addWatermarkWithAVAsset:asset image:image frame:frame start:0 duration:asset.duration.value/asset.duration.timescale completion:block];
}
+(void)addWatermarkWithVideoUrl:(NSURL *)videoUrl image:(UIImage *)image frame:(CGRect)frame start:(CGFloat)startTime duration:(CGFloat)duration completion:(void (^)(BOOL, NSString *, AVAsset *, AVMutableVideoComposition *))block{
    if (videoUrl==nil||[videoUrl isKindOfClass:[NSNull class]]) {
        if (block) {
            block(NO,@"Video add watermark: incoming videoUrl is nil",nil,nil);
        }
        return;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    [self addWatermarkWithAVAsset:asset image:image frame:frame start:startTime duration:duration completion:block];
}
+(void)addWatermarkWithAVAsset:(AVAsset *)asset image:(UIImage *)image frame:(CGRect)frame start:(CGFloat)startTime duration:(CGFloat)duration completion:(void (^)(BOOL, NSString *, AVAsset *, AVMutableVideoComposition *))block{
    if (asset==nil||[asset isKindOfClass:[NSNull class]]) {
        if (block) {
            block(NO,@"Video add watermark: The incoming video resource asset is nil",nil,nil);
        }
        return;
    }
    if (startTime<0) {
        startTime=0;
    }
    if (duration<0) {
        duration=0;
    }
    
    //Video resource
    AVAssetTrack *assetVideoTrack = [self getAssetTrackWithMediaType:AVMediaTypeVideo asset:asset];
    //Audio resource
    AVAssetTrack *assetAudioTrack = [self getAssetTrackWithMediaType:AVMediaTypeAudio asset:asset];
    
    CMTime startPoint=CMTimeMakeWithSeconds(0,1);
    
    //Composition object is mainly audio and video combination
    AVMutableComposition *composition=[AVMutableComposition composition];
    NSError *error=nil;
    
    if(assetVideoTrack!=nil) {
        //Composition add video resources
        [self insertTrack:assetVideoTrack
            toComposition:composition
                mediaType:AVMediaTypeVideo
         preferredTrackID:kCMPersistentTrackID_Invalid
          insertTimeRange:CMTimeRangeMake(startPoint,[asset duration])
                   atTime:kCMTimeZero
                    error:&error];
        
        if (error) {
            if (block) {
                block(NO,[NSString stringWithFormat:@"Video watermarking: video resource error:%@",error],nil,nil);
            }
            return;
        }
    }
    else{
        NSLog(@"Video watermarking: The provided resource has no video resources internally or does not support the video format.");
    }
    
    if(assetAudioTrack != nil) {
        //composition添加音频资源
        [self insertTrack:assetAudioTrack
            toComposition:composition
                mediaType:AVMediaTypeAudio
         preferredTrackID:kCMPersistentTrackID_Invalid
          insertTimeRange:CMTimeRangeMake(startPoint,[asset duration])
                   atTime:kCMTimeZero
                    error:&error];
        
        if (error) {
            if (block) {
                block(NO,[NSString stringWithFormat:@"Video watermarking: audio resource error:%@",error],nil,nil);
            }
            return;
        }
    }
    else{
        NSLog(@"Video watermarking: The provided resource has no audio resources internally or does not support the video format.");
    }
    
    //Check if there are video resources in the composition
    AVMutableVideoComposition *videoComposition=nil;
    if ([[composition tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.frameDuration=CMTimeMake(1, 30);
        videoComposition.renderSize=assetVideoTrack.naturalSize;
        
        AVMutableVideoCompositionInstruction *instruction=[AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange=CMTimeRangeMake(kCMTimeZero,composition.duration);
        
        AVAssetTrack *videoTrack=[composition tracksWithMediaType:AVMediaTypeVideo][0];
        AVMutableVideoCompositionLayerInstruction *layerInstruction=[AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        instruction.layerInstructions = @[layerInstruction];
        videoComposition.instructions = @[instruction];
        
        //Create a watermark background layer
        CAShapeLayer *parentLayer=[CAShapeLayer layer];
        parentLayer.geometryFlipped=YES;
        parentLayer.frame=CGRectMake(0,0,videoComposition.renderSize.width,videoComposition.renderSize.height);
        
        CALayer *videoLayer=[CALayer layer];
        videoLayer.frame=CGRectMake(0,0,videoComposition.renderSize.width,videoComposition.renderSize.height);
        [parentLayer addSublayer:videoLayer];
        
        //Create a watermark
        CALayer *watermarkLayer=[CALayer layer];
        watermarkLayer.contentsGravity=@"resizeAspect";
        watermarkLayer.frame=frame;
        watermarkLayer.contents=(__bridge id _Nullable)image.CGImage;
        [parentLayer addSublayer:watermarkLayer];
        
        //Add watermark display time period
        CGFloat endTime=startTime+duration;
        CGFloat allTime=composition.duration.value/composition.duration.timescale;
        
        if (!(startTime<=0&&endTime>=allTime)) {
            //The watermark is only displayed at a specific time
            watermarkLayer.opacity=0;
            
            [self addAnimationToWatermarkLayer:watermarkLayer show:YES beginTime:startTime];
            [self addAnimationToWatermarkLayer:watermarkLayer show:NO beginTime:endTime];
        }
        
        videoComposition.animationTool=[AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
    else{
        if (block) {
            block(NO,@"Video watermarking: The provided resource has no video resources internally or does not support the video format. Watermark cannot be added.",asset,nil);
        }
        return;
    }
    
    if (block) {
        block(YES,@"",composition,videoComposition);
    }
}
#pragma mark - Video changes background music
+(void)addAudioWithVideoUrl:(NSURL *)videoUrl audioUrl:(NSURL *)audioUrl keepOriginAudio:(BOOL)keepOriginAudio completion:(void (^)(BOOL, NSString *, AVAsset *, AVMutableAudioMix *, AVMutableVideoComposition *))completionBlock {
    
    if (videoUrl==nil||[videoUrl isKindOfClass:[NSNull class]]||audioUrl==nil||[audioUrl isKindOfClass:[NSNull class]]) {
        if (completionBlock) {
            completionBlock(NO,@"Video changes background music: incoming videoUrl or audioUrl is nil",nil,nil,nil);
        }
        return;
    }
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
    
    [self addAudioWithVideoAVAsset:videoAsset audioAVAsset:audioAsset keepOriginAudio:keepOriginAudio completion:completionBlock];
}
+(void)addAudioWithVideoAVAsset:(AVAsset *)videoAsset audioAVAsset:(AVAsset *)audioAsset keepOriginAudio:(BOOL)keepOriginAudio completion:(void (^)(BOOL, NSString *, AVAsset *, AVMutableAudioMix *, AVMutableVideoComposition *))completionBlock {
    
    if (videoAsset==nil||[videoAsset isKindOfClass:[NSNull class]]||audioAsset==nil||[audioAsset isKindOfClass:[NSNull class]]) {
        if (completionBlock) {
            completionBlock(NO,@"Video changes background music: incoming videoAsset or audioAsset is nil",nil,nil,nil);
        }
        return;
    }
    
    CGFloat videoDuration = CMTimeGetSeconds([videoAsset duration]);
    CGFloat audioDuration = CMTimeGetSeconds([audioAsset duration]);
    
    //Video resource
    AVAssetTrack *originalVideoTrack = [self getAssetTrackWithMediaType:AVMediaTypeVideo asset:videoAsset];
    
    //Background music resources
    AVAssetTrack *originalVideoAudioTrack = (keepOriginAudio)?[self getAssetTrackWithMediaType:AVMediaTypeAudio asset:videoAsset]:nil;
    AVAssetTrack *newAudioTrack = [self getAssetTrackWithMediaType:AVMediaTypeAudio asset:audioAsset];
    
    AVMutableComposition *composition=[AVMutableComposition composition];
    NSError *error=nil;
    
    //Audio collection
    AVMutableAudioMix *audioMix=nil;
    
    //Video original background audio resource
    if (originalVideoAudioTrack!=nil) {
        [self insertTrack:originalVideoAudioTrack
            toComposition:composition
                mediaType:AVMediaTypeAudio
         preferredTrackID:kCMPersistentTrackID_Invalid
          insertTimeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(videoDuration,1))
                   atTime:kCMTimeZero
                    error:&error];
        
        if (error) {
            if (completionBlock) {
                completionBlock(NO,[NSString stringWithFormat:@"Video original background music resource error:%@",error],nil,nil,nil);
            }
            return;
        }
    }
    else if (keepOriginAudio) {
        NSLog(@"Video change background music: The provided video resource has no audio resources internally or does not support the video format.");
    }
    
    //New background music audio resources
    if (newAudioTrack!=nil) {
        AVMutableCompositionTrack *audioTrack=[self insertTrack:newAudioTrack
                                                  toComposition:composition
                                                      mediaType:AVMediaTypeAudio
                                               preferredTrackID:kCMPersistentTrackID_Invalid
                                                insertTimeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(audioDuration,1))
                                                         atTime:kCMTimeZero
                                                          error:&error];
        
        if (error) {
            if (completionBlock) {
                completionBlock(NO,[NSString stringWithFormat:@"Add video new background music audio resource error:%@",error],nil,nil,nil);
            }
            return;
        }
        
        if (audioTrack) {
            AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
            [mixParameters setVolumeRampFromStartVolume:1 toEndVolume:1 timeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(audioDuration,1))];
            
            audioMix=[AVMutableAudioMix audioMix];
            audioMix.inputParameters=@[mixParameters];
        }
    }
    else{
        NSLog(@"Video change background music: The provided audio resource has no audio resources or does not support the media format.");
    }
    
    //Video collection
    AVMutableVideoComposition *videoComposition=nil;
    
    AVMutableVideoCompositionLayerInstruction *originalLayerInstruction=nil;
    //Original video resource
    if (originalVideoTrack!=nil) {
        AVMutableCompositionTrack *videoTrack=[self insertTrack:originalVideoTrack
                                                  toComposition:composition
                                                      mediaType:AVMediaTypeVideo
                                               preferredTrackID:kCMPersistentTrackID_Invalid
                                                insertTimeRange:CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(videoDuration,1))
                                                         atTime:kCMTimeZero
                                                          error:&error];
        
        if (error) {
            if (completionBlock) {
                completionBlock(NO,[NSString stringWithFormat:@"Error adding video video resource when video changes background:%@",error],nil,nil,nil);
            }
            return;
        }
        
        if (videoTrack) {
            originalLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        }
    }
    else{
        NSLog(@"Video change background music: The provided video resource has no video resources inside or does not support the video format.");
    }
    
    //Determine if there is a LayerInstruction video resource
    if (originalLayerInstruction) {
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange=CMTimeRangeMake(kCMTimeZero,CMTimeMakeWithSeconds(videoDuration,1));
        instruction.layerInstructions=@[originalLayerInstruction];
        
        videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.instructions=[NSArray arrayWithObject:instruction];
        videoComposition.frameDuration = CMTimeMake(1,30);
        videoComposition.renderSize = CGSizeMake(originalVideoTrack.naturalSize.width,originalVideoTrack.naturalSize.height);
    }
    else{
        NSLog(@"Video change background: The provided video resource has no video resources inside, and may not support media format.");
    }
    
    if (completionBlock) {
        completionBlock(YES,@"",composition,audioMix,videoComposition);
    }
}
#pragma mark - Compressed video export
+(void)exportWithVideoUrl:(nonnull NSURL *)videoUrl saveToLibrary:(BOOL)isSave exportQuality:(SLVideoEditorExportQuality)exportQuality{
    if (videoUrl==nil||[videoUrl isKindOfClass:[NSNull class]]) {
        NSLog(@"Video compression export: incoming videoUrl is nil");
        [SLNotificationCenter postNotificationName:SLVideoEditorExportFail object:@"Video compression export: incoming videoUrl is nil"];
        return;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    [self exportAsset:asset audioMix:nil videoComposition:nil saveToLibrary:isSave exportQuality:exportQuality];
}
+(void)exportAsset:(nonnull AVAsset *)asset saveToLibrary:(BOOL)isSave exportQuality:(SLVideoEditorExportQuality)exportQuality{
    [self exportAsset:asset audioMix:nil videoComposition:nil saveToLibrary:isSave exportQuality:exportQuality];
}

+(void)exportAsset:(nonnull AVAsset *)asset audioMix:(nullable AVMutableAudioMix *)audioMix videoComposition:(nullable AVMutableVideoComposition *)videoComposition saveToLibrary:(BOOL)isSave exportQuality:(SLVideoEditorExportQuality)exportQuality{
    
    if (asset==nil||[asset isKindOfClass:[NSNull class]]) {
        NSLog(@"Video compression export: incoming AVAsset is nil");
        [SLNotificationCenter postNotificationName:SLVideoEditorExportFail object:@"Video compression export: incoming AVAsset is nil"];
        return;
    }
    
    //Create an export path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *outputURL = paths[0];
    
    NSFileManager *manager=[NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    outputURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-mergedVideo.mov", [[NSUUID UUID] UUIDString]]];
    //.mp4
    //Remove file
    [manager removeItemAtPath:outputURL error:nil];
    
    
    //Create an exportSession video export object based on the asset object
    AVAssetExportSession *exportSession=[[AVAssetExportSession alloc] initWithAsset:asset presetName:[self getVideoExportQuality:exportQuality]];
    //Audio mixer
    exportSession.audioMix = audioMix;
    //Video combiner
    exportSession.videoComposition=videoComposition;
    //Video export path
    exportSession.outputURL=[NSURL fileURLWithPath:outputURL];
    //Export format
    exportSession.outputFileType=AVFileTypeMPEG4;
    //Start asynchronous export
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] delegate].window.userInteractionEnabled=YES;
        });
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                //Export successful
                [SLNotificationCenter postNotificationName:SLVideoEditorExportSuccess object:[NSURL fileURLWithPath:outputURL]];
                if (isSave==YES) {
                    [self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
                }
                break;
            case AVAssetExportSessionStatusFailed:
                //Export failed
                NSLog(@"Video compression export failure error:%@",exportSession.error);
                [SLNotificationCenter postNotificationName:SLVideoEditorExportFail object:[NSString stringWithFormat:@"%@",exportSession.error]];
                break;
            case AVAssetExportSessionStatusCancelled:
                //Export cancellation
                NSLog(@"Video compression export cancel error:%@",exportSession.error);
                [SLNotificationCenter postNotificationName:SLVideoEditorExportCancel object:[NSString stringWithFormat:@"%@",exportSession.error]];
                break;
            default:
                break;
        }
    }];
}
#pragma mark - Save it to your local photo library based on the video url address
+(void)writeVideoToPhotoLibrary:(nonnull NSURL *)url {
    if (url==nil||[url isKindOfClass:[NSNull class]]) {
        NSLog(@"Save the video to your local photo library: the incoming video url is nil");
        [SLNotificationCenter postNotificationName:SLVideoEditorSaveToLibraryFail object:@"Save the video to your local photo library: the incoming video url is nil"];
        return;
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success==YES) {
            [SLNotificationCenter postNotificationName:SLVideoEditorSaveToLibrarySuccess object:url];
        }
        else{
            NSLog(@"Video save to local photo library failed error:%@",error);
            [SLNotificationCenter postNotificationName:SLVideoEditorSaveToLibraryFail object:[NSString stringWithFormat:@"%@",error]];
        }
    }];
}
#pragma mark - Other related methods
//Add a show hide effect to the watermark
+ (void)addAnimationToWatermarkLayer:(CALayer *)layer show:(BOOL)isShow beginTime:(CGFloat)beginTime{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setDuration:0];
    [animation setFromValue:[NSNumber numberWithFloat:(isShow)?0.0:1.0]];
    [animation setToValue:[NSNumber numberWithFloat:(isShow)?1.0:0.0]];
    [animation setBeginTime:(beginTime==0)?0.25:beginTime];//(If the display starts from 0, the system will not display, there will be a bug, it must be delayed for a while, it may be necessary to react time.)
    animation.autoreverses=NO;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    [layer addAnimation:animation forKey:nil];
}

//Get video direction according to videoTrack
+(UIImageOrientation)getUIImageOrientationWithAssetTrack:(nonnull AVAssetTrack *)assetTrack{
    CGAffineTransform transform=assetTrack.preferredTransform;
    
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
        //UIImageOrientationLeft
        return UIImageOrientationLeft;
    }
    else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
        //UIImageOrientationRight
        return UIImageOrientationRight;
    }
    else if (transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
        //UIImageOrientationUp
        return UIImageOrientationUp;
    }
    else if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
        //UIImageOrientationDown
        return UIImageOrientationDown;
    }
    else{
        return UIImageOrientationUp;
    }
}
//Get the correct transform of the video according to parameters such as AVAssetTrack
+(CGAffineTransform)getTransformWithAssetTrack:(nonnull AVAssetTrack *)assetTrack imageOrientation:(UIImageOrientation)orientation{
    CGAffineTransform transform=assetTrack.preferredTransform;
    
    if (orientation==UIImageOrientationLeft) {
        CGAffineTransform t = CGAffineTransformMakeTranslation(assetTrack.naturalSize.height,0.0);
        transform = CGAffineTransformRotate(t,SLRadians(90.0));
    }
    else if (orientation==UIImageOrientationRight) {
        CGAffineTransform t = CGAffineTransformMakeTranslation(-assetTrack.naturalSize.height,0.0);
        transform = CGAffineTransformRotate(t,SLRadians(270.0));
    }
    else if (orientation==UIImageOrientationUp) {
    }
    else if (orientation==UIImageOrientationDown) {
        CGAffineTransform t = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width,assetTrack.naturalSize.height);
        transform = CGAffineTransformRotate(t,SLRadians(180.0));
    }
    
    
    return transform;
}
//Obtain related resources in the asset according to the specified mediaType type.
+(AVAssetTrack *)getAssetTrackWithMediaType:(NSString *)mediaType asset:(AVAsset *)asset{
    if ([[asset tracksWithMediaType:mediaType] count] != 0) {
        return [asset tracksWithMediaType:mediaType][0];
    }
    else{
        return nil;
    }
}
//Add resources to Composition
+(AVMutableCompositionTrack *)insertTrack:(AVAssetTrack *)assetTrack toComposition:(AVMutableComposition *)composition mediaType:(NSString *)mediaType preferredTrackID:(CMPersistentTrackID)trackID insertTimeRange:(CMTimeRange)timeRange atTime:(CMTime)atTime error:(NSError * __nullable * __nullable)error{
    
    if (composition&&assetTrack) {
        AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:mediaType preferredTrackID:trackID];
        
        //Add the timeRange period of the resource to the atTime point of the composition object
        [compositionTrack insertTimeRange:timeRange ofTrack:assetTrack atTime:atTime error:error];
        
        return compositionTrack;
    }
    else{
        return nil;
    }
}
//Get the desired video quality based on SLVideoEditorExportQuality
+(NSString *)getVideoExportQuality:(SLVideoEditorExportQuality)quality{
    switch (quality) {
        case SLVideoEditorExportQuality960x540:
            return AVAssetExportPreset960x540;
            break;
        case SLVideoEditorExportQuality640x480:
            return AVAssetExportPreset640x480;
            break;
        case SLVideoEditorExportQuality1280x720:
            return AVAssetExportPreset1280x720;
            break;
        case SLVideoEditorExportQuality1920x1080:
            return AVAssetExportPreset1920x1080;
            break;
        case SLVideoEditorExportQuality3840x2160:
            return AVAssetExportPreset3840x2160;
            break;
        case SLVideoEditorExportLowQuality:
            return AVAssetExportPresetLowQuality;
            break;
        case SLVideoEditorExportHighQuality:
            return AVAssetExportPresetHighestQuality;
        default:
            return AVAssetExportPresetMediumQuality;
            break;
    }
}


#pragma mark - Filters adition and Video Merging
+ (void)compressVideoWithEmptyFilterInputVideoUrl:(NSURL *)inputVideoUrl completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion {
    
    /* Create Output File Url */
    NSString *documentsDirectory = NSTemporaryDirectory();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *finalVideoURLString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"compressedVideo%@.mov",nowTimeStr]];
    //mp4
    
    NSURL *outputVideoUrl = ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1)?([NSURL URLWithString:finalVideoURLString]):([NSURL fileURLWithPath:finalVideoURLString]); // Url Should be a file Url, so here we check and convert it into a file Url
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    
    AVAsset* asset = [AVURLAsset URLAssetWithURL:inputVideoUrl options:options];
    NSArray* keys = @[@"tracks",@"duration",@"commonMetadata"];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        SDAVAssetExportSession *compressionEncoder = [SDAVAssetExportSession.alloc initWithAsset:asset]; // provide inputVideo Url Here
        compressionEncoder.outputFileType = AVFileTypeMPEG4;
        
        compressionEncoder.outputURL = outputVideoUrl; //Provide output video Url here
        // compressionEncoder.outputURL = [NSURL fileURLWithPath:outputVideoUrl.path];
        
        compressionEncoder.videoSettings = @
        {
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: @720,   //Set your resolution width here
        AVVideoHeightKey: @1280,  //set your resolution height here
        AVVideoCompressionPropertiesKey: @{
                                           AVVideoAverageBitRateKey: @(2500000),
                                           AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                                           AVVideoAverageNonDroppableFrameRateKey: @(30),
                                           },
        };
        
        compressionEncoder.audioSettings = @ {
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVNumberOfChannelsKey: @2,
        AVSampleRateKey: @44100,
        AVEncoderBitRateKey: @128000,
        };
        
        [compressionEncoder exportAsynchronouslyWithCompletionHandler:^ {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (compressionEncoder.status == AVAssetExportSessionStatusCompleted) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] removeObserver:self];
                        completion(outputVideoUrl, nil);
                    });
                    
                } else if (compressionEncoder.status == AVAssetExportSessionStatusCancelled) {
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] removeObserver:self];
                        completion(nil, [NSError errorWithDomain:@"DivineraySDKGo" code:AVAssetExportSessionStatusCancelled userInfo:nil]);
                    });
                    
                } else {
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] removeObserver:self];
                        completion(nil, compressionEncoder.error);
                    });
                }
            });
        }];
    }];
}



+ (void)mixAudioAndVidoWithInputURL:(NSURL*)inputURL withAudioPath:(NSString *)audioPath keepOriginAudio:(BOOL)keepOriginAudio completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion {
    
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSURL *audioInputUrl = [NSURL fileURLWithPath:audioPath];
    NSURL *videoInputUrl = inputURL;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[documents stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mov"]; //mp4
    
    NSURL *outputFileUrl = [NSURL fileURLWithPath:fileName];
    CMTime nextClistartTime = kCMTimeZero;
    
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:options];
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:options];
    CMTimeRange audioTimeRange = videoTimeRange;
    
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
    
    if (keepOriginAudio) {
        
        AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
        // Create the audio mix input parameters object.
        AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        // Set the volume ramp to slowly fade the audio out over the duration of the composition.
        //    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
        [mixParameters setVolume:.5f atTime:kCMTimeZero];
        // Attach the input parameters to the audio mix.
        mutableAudioMix.inputParameters = @[mixParameters];
        
        AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
        
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        //float bili = 720/SCREEN_WIDTH;
        //aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.audioMix = mutableAudioMix;
        assetExport.videoComposition = videoComp;
        assetExport.outputFileType = AVFileTypeMPEG4;
        assetExport.outputURL = outputFileUrl;
        assetExport.shouldOptimizeForNetworkUse = YES;
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self compressVideoWithEmptyFilterInputVideoUrl:outputFileUrl completion:completion];
                //[self compressVideoWithInputVideoUrl:outputFileUrl];
            });
        }];
        
    } else {
        
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        // float bili = 720/SCREEN_WIDTH;
        //aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.videoComposition = videoComp;
        assetExport.outputFileType = AVFileTypeMPEG4;
        assetExport.outputURL = outputFileUrl;
        assetExport.shouldOptimizeForNetworkUse = YES;
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self compressVideoWithEmptyFilterInputVideoUrl:outputFileUrl completion:completion];
            });
        }];
    }
}

@end
