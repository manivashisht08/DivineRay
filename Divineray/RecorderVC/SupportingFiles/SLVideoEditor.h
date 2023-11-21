//
//  SLVideoEditor.h
//  Created by Vivek Dharmai Rathor on 16/06/20.
//  Copyright © 2018. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

//Related notification notification

//The video is saved to the local photo library successfully (object is the video url)
#define SLVideoEditorSaveToLibrarySuccess @"SLVideoEditorSaveToLibrarySuccess"

//Video saved to local photo library failed (object is error message)
#define SLVideoEditorSaveToLibraryFail @"SLVideoEditorSaveToLibraryFail"

//Export video successfully (object is video url)
#define SLVideoEditorExportSuccess @"SLVideoEditorExportSuccess"

//Export video failed (object is an error message)
#define SLVideoEditorExportFail @"SLVideoEditorExportFail"

//Export video cancellation (object is error message)
#define SLVideoEditorExportCancel @"SLVideoEditorExportCancel"


typedef enum{
    SLVideoEditorExportMediumQuality=0,//Medium quality (default)
    SLVideoEditorExportLowQuality,//Low quality
    SLVideoEditorExportHighQuality,//Higher quality
    SLVideoEditorExportQuality640x480,//640x480 size
    SLVideoEditorExportQuality960x540,//960x540 size
    SLVideoEditorExportQuality1280x720,//1280x720 size
    SLVideoEditorExportQuality1920x1080,//1920x1080 size
    SLVideoEditorExportQuality3840x2160,//3840x2160 size
} SLVideoEditorExportQuality;//Export video quality (the higher the quality, the longer it takes to export)

@interface SLVideoEditor : NSObject

#pragma mark - Video merge
/**
 *  Merge video (merge failed to return nil)
 *  originalVideoUrl - The URL of the video being merged (played first after the merge)
 *  otherVideoUrl - The video URL to be merged into OriginalVideo (combined after originalVideo)
 *  completion - Execution end block callback
 *  If there is a video ImageOrientation with UIImageOrientationDown down and the other is not UIImageOrientationDown down, then after playing and then playing to ImageOrientationDown video, it will still play and display all, but its center position may not be in the center of the screen.
 */
+ (void)composeWithOriginalVideoUrl:(NSURL *)originalVideoUrl otherVideoUrl:(NSURL *)otherVideoUrl completion:(void(^)(BOOL success,NSString *error,AVAsset *asset,AVMutableAudioMix *audioMix,AVMutableVideoComposition *videoComposition))block;
/**
 *  See composeWithOriginalVideoUrl: otherVideoUrl: completion: class method
 *  AVAsset Video resources that need to be merged
 */
+ (void)composeWithOriginalAVAsset:(AVAsset *)originalAsset otherAVAsset:(AVAsset *)otherAsset completion:(void(^)(BOOL success,NSString *error,AVAsset *asset,AVMutableAudioMix *audioMix,AVMutableVideoComposition *videoComposition))block;

#pragma mark - Video cut
/**
 *  Cut video (clip failure asset returns nil)
 *  videoUrl Video URL
 *  startTime Cut start time (when it is less than 0, it will automatically become 0)
 *  endTime Cut end time (more than the total video time, it will automatically change to the total video time)
 *  completion Execution end block callback
 */
+ (void)trimWithVideoUrl:(NSURL *)videoUrl start:(CGFloat)startTime end:(CGFloat)endTime completion:(void(^)(BOOL success,NSString *error,AVAsset *asset))block;
/**
 *  Reference trimWithVideoUrl: start: end: completion: class method
 *  AVAsset Video resources that need to be cut
 */
+ (void)trimWithAVAsset:(AVAsset *)asset start:(CGFloat)startTime end:(CGFloat)endTime completion:(void(^)(BOOL success,NSString *error,AVAsset *asset))block;

#pragma mark - Video watermark
/**
 *  Video add watermark (add failed asset return nil)
 *  videoUrl Video URL
 *  image Watermark image
 *  frame Watermark relative video position
 *  completion Execution end block callback
 */
+ (void)addWatermarkWithVideoUrl:(NSURL *)videoUrl image:(UIImage *)image frame:(CGRect)frame completion:(void(^)(BOOL success,NSString *error,AVAsset *asset,AVMutableVideoComposition *videoComposition))block;

/**
 *  See addWatermarkWithVideoUrl: image: frame: completion: class method
 *  startTime Watermark start time (less than 0 will be automatically set to 0)
 *  duration Watermark duration (less than 0 will automatically set to 0)
 */
+ (void)addWatermarkWithVideoUrl:(NSURL *)videoUrl image:(UIImage *)image frame:(CGRect)frame start:(CGFloat)startTime duration:(CGFloat)duration completion:(void(^)(BOOL success,NSString *error,AVAsset *asset,AVMutableVideoComposition *videoComposition))block;

/**
 *  See addWatermarkWithVideoUrl: image: frame: completion: class method
 *  AVAsset Video resource that needs to be watermarked
 *  startTime Watermark start time (less than 0 will be automatically set to 0)
 *  duration Watermark duration (less than 0 will automatically set to 0)
 */
+ (void)addWatermarkWithAVAsset:(AVAsset *)asset image:(UIImage *)image frame:(CGRect)frame start:(CGFloat)startTime duration:(CGFloat)duration completion:(void(^)(BOOL success,NSString *error,AVAsset *asset,AVMutableVideoComposition *videoComposition))block;

#pragma mark - Video changes background music
/**
 *  Change the video background music (failed asset returns nil)
 *  videoUrl Changed video URL
 *  audioUrl To change the audio URL into video (1. Incoming video, only audio resources will be taken internally. 2. If the video finally obtained is played, the background music will stop with the video even if the duration is longer than the video.)
 *  completion Execution end block callback
 *  keepOriginAudio Whether to keep the original background music
 */
+ (void)addAudioWithVideoUrl:(NSURL *)videoUrl audioUrl:(NSURL *)audioUrl keepOriginAudio:(BOOL)keepOriginAudio completion:(void(^)(BOOL success,NSString *error,AVAsset *asset,AVMutableAudioMix *audioMix,AVMutableVideoComposition *videoComposition))block;

/**
 *  See addAudioWithVideoUrl: audioUrl: keepOriginAudio: completion: class method
 *  AVAsset Resources that need to be changed
 */
+ (void)addAudioWithVideoAVAsset:(AVAsset *)videoAsset audioAVAsset:(AVAsset *)audioAsset keepOriginAudio:(BOOL)keepOriginAudio completion:(void(^)(BOOL success,NSString *error,AVAsset *asset,AVMutableAudioMix *audioMix,AVMutableVideoComposition *videoComposition))block;

#pragma mark - Compressed export video
/**
 *  Compress and export video (users are prohibited from interacting with the screen when performing asynchronous compression, otherwise it may cause failure, and the higher the quality of exportQuality, the longer it takes)
 
 *  videoUrl - Video URL
 *  isSave - Whether to automatically save to the local photo library after exporting the compressed video
 *  exportQuality - Compress and export video quality
 */
+ (void)exportWithVideoUrl:(nonnull NSURL *)videoUrl saveToLibrary:(BOOL)isSave exportQuality:(SLVideoEditorExportQuality)exportQuality;

/**
 *  See exportAsset: saveToLibrary: exportQuality: class method
 *  asset - Video Asset object
 *  audioMix - Audio mixer
 *  videoComposition - Video mixer
 */
+(void)exportAsset:(nonnull AVAsset *)asset saveToLibrary:(BOOL)isSave exportQuality:(SLVideoEditorExportQuality)exportQuality;

+(void)exportAsset:(nonnull AVAsset *)asset audioMix:(nullable AVMutableAudioMix *)audioMix videoComposition:(nullable AVMutableVideoComposition *)videoComposition saveToLibrary:(BOOL)isSave exportQuality:(SLVideoEditorExportQuality)exportQuality;

/**
 *  Save it to your local photo library based on the video url address
 */
+(void)writeVideoToPhotoLibrary:(nonnull NSURL *)url;

#pragma - Filters Adition and Mixing Audio
+ (void)compressVideoWithEmptyFilterInputVideoUrl:(NSURL *_Nonnull)inputVideoUrl completion:(void(^_Nullable)(NSURL * _Nullable mergedVideoURL, NSError * _Nullable error))completion;

+ (void)mixAudioAndVidoWithInputURL:(NSURL*_Nonnull)inputURL withAudioPath:(NSString *_Nonnull)audioPath keepOriginAudio:(BOOL)keepOriginAudio completion:(void(^_Nullable)(NSURL * _Nullable mergedVideoURL, NSError * _Nullable error))completion;

@end
