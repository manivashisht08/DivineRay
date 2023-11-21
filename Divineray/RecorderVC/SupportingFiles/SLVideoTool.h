//
//  SLVideoTool.h
//  Created by Vivek Dharmai.
//  Copyright © 2019. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SLVideoTool : NSObject

/**
 Album video save local path
 @return Save album video to local path
 */
+(NSString *)mh_albumVideoOutTempPath;

/**
 Get the thumbnail method of the video
 @param videoUrl Video path
 @param time time
 @return Video screenshot
 */
+ (UIImage *)mh_getVideoTempImageFromVideo:(NSURL *)videoUrl withTime:(CGFloat)time;


/**
 Get video length
 @param videoUrl Video address
 @return Video length
 */
+(CGFloat)mh_getVideolength:(NSURL *)videoUrl;

/**
 Video rotation angle
 @param url video
 @return angle
 */
+ (NSUInteger)mh_getDegressFromVideoWithURL:(NSURL *)url;

/**
 Get video size
 @param videoUrl Video address
 @return Video size
 */
+(CGSize)mh_getVideoSize:(NSURL *)videoUrl;

/**
 Adjust the size of the video output according to the ratio, width=480
 @param nomSize original size
 @return Adjusted size
 */
+(CGSize)mh_fixVideoOutPutSize:(CGSize)nomSize;

/**
 Save video to album
 @param videoUrl Video address to save
 @param callBack Save callback
 */
+(void)mh_writeVideoToPhotosAlbum:(NSURL *)videoUrl callBack:(void(^)(BOOL success))callBack;

/**
 Modify video speed
 @param videoUrl Original video address
 @param speed The speed to change, the greater the speed, the longer the video is modified. The final time = original time *speed
 @param outPutUrl Changed video address
 @param callBack Callback - success
 */
+(void)changeVideoSpeed:(NSURL *)videoUrl speed:(CGFloat)speed outPutUrl:(NSURL *)outPutUrl callBack:(void(^)(BOOL success))callBack;

/**
 Combine multiple videos into one video
 @param paths Video path to be synthesized
 @param outPutUrl Input path
 @param callBack Callback - success, input path
 */
+(void)mergeVideosWithPaths:(NSArray *)paths outPutUrl:(NSURL *)outPutUrl callBack:(void(^)(BOOL success,NSURL * outPurUrl))callBack;

/**
 Audio bgm cropping
 @param bgmUrl Audio path to be cropped
 @param startTime Crop start time
 @param length Crop length
 @param callBack Callback
 */
+(void)crapMusicWithUrl:(NSURL *)bgmUrl startTime:(CGFloat)startTime length:(CGFloat)length callBack:(void(^)(BOOL success,NSURL * outPurUrl))callBack;

/**
 Merge video + background music Adjust the volume of the original video's audio and background music at the same time
 @param videoUrl Video address to merge
 @param originalAudioTrackVideoUrl Original video address - get the audio track of the original video from inside
 @param bgmUrl Background music address
 @param originalVolume Original video audio track volume
 @param bgmVolume Background music volume
 @param outPutUrl Output address
 @param callBack Callback
 */
+(void)mergevideoWithVideoUrl:(NSURL *)videoUrl originalAudioTrackVideoUrl:(NSURL *)originalAudioTrackVideoUrl bgmUrl:(NSURL *)bgmUrl originalVolume:(CGFloat)originalVolume bgmVolume:(CGFloat)bgmVolume outPutUrl:(NSURL *)outPutUrl callBack:(void(^)(BOOL success,NSURL * outPurUrl))callBack;

+ (UIViewContentMode)determineVideoContentMode:(CGSize)videoSize;
@end
