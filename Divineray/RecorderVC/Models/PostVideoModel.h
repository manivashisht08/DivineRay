//
//  PostVideoModel.h//
//  Created by "" on 2019/02/25.
//  Copyright © 2019. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ShootSubVideo;

typedef enum : NSInteger  {
    MHShootSpeedTypeMoreSlow       = 0, //very slow
    MHShootSpeedTypeaSlow          = 1, //slow
    MHShootSpeedTypeNomal          = 2, //standard
    MHShootSpeedTypeFast           = 3, //fast
    MHShootSpeedTypeMorefast       = 4, //Extremely fast
}MHShootSpeedType;//Video shooting speed type

typedef enum : NSInteger  {
    MHPostVideoOpenTypeOpen          = 0, //public
    MHPostVideoOpenTypeOnlyFriend    = 1, //Visible only to friends
    MHPostVideoOpenTypeUnOpen        = 2, //private
}MHPostVideoOpenType;//Video release public type



@interface PostVideoModel : NSObject

/** Sub video information during video capture for synthesis after final shooting */
@property(nonatomic,strong)NSArray<ShootSubVideo *> * subVideoInfos;

/** End of shooting Variable speed + combined video local path */
@property(nonatomic,copy)NSString * shootFinishMergedVideoPath;

/** Video length after shooting */
@property(nonatomic,assign,readonly)CGFloat shootFinishVideolength;

/**shooting constains audio*/
@property(nonatomic,assign) BOOL havingAudioOnRecording;

/**background music path*/
@property(nonatomic,copy)NSString * bgMusicPath;
/**background music ed*/
@property(nonatomic,copy)NSString * muisicId;

/**Is Gallery Video */
@property(nonatomic,assign) BOOL isGalleryVideo;




/** Video add background music music name */
//@property(nonatomic,copy)NSString * bgmName;
/** Background music start position */
@property(nonatomic,assign)NSInteger bgmStartTime;
/** Original video volume Default 1 */
@property(nonatomic,assign)CGFloat videoVolume;
/** Background music volume default 1 */
@property(nonatomic,assign)CGFloat bgmVolume;
/** Video cover location - time point default 0.f */
@property(nonatomic,assign)CGFloat videoCaverLocation;
/** Final video path */
@property(nonatomic,copy)NSString * finalVideoPath;

@property(nonatomic,copy)UIImage * captureImage;

@property(nonatomic,assign) BOOL isImageData;


/** Post title*/
@property(nonatomic,copy)NSString * postTitle;
/** Release location */
@property(nonatomic,copy)NSString * postLocation;
/** Release type */
@property(nonatomic,assign)MHPostVideoOpenType postOpenType;


/** Add a sub video model based on the video capture speed and return to the current add model */
-(ShootSubVideo *)addSubVideoInfoWithSpeedType:(MHShootSpeedType)videoSpeedType;
/** Delete the previous sub-video */
-(void)removeLastSubVideoInfo;
/** Calculate the sum of all sub video video durations */
-(CGFloat)getAllSubVideoInfoVideoLength;

/**
 Shift + merge the sub video after shooting
 @param subVideoInfos Sub video array
 @param callBack Callback - whether it succeeded in processing the video path
 */
+(void)compositionSubVideos:(NSArray<ShootSubVideo *> *)subVideoInfos callBack:(void(^)(BOOL success ,NSString * outPurPath))callBack;

/**
 合并视频+音频
 @param videoUrl The video to be merged (no audio track, the original audio track needs to be read from the shotFinishMergedVideoPath inside the model)
 @param model Video information
 @param callBack Callback
 */
+(void)videoAddBGM_videoUrl:(NSURL *)videoUrl originalInfo:(PostVideoModel *)model callBack:(void(^)(BOOL success ,NSString * outPurPath))callBack;

/** Clear shot temporary video files */
+(void)cleanShootTempCache;
/** Create - return a video temporary path */
+(NSString *)creatAVideoTempPath;

@end


@interface ShootSubVideo : NSObject

/** Segmented video save path */
@property(nonatomic,copy,readonly)NSString * subVideoPath;
/** Segmentation video length */
@property(nonatomic,assign,readonly)CGFloat videolength;
/** Segmentation speed type */
@property(nonatomic,assign)MHShootSpeedType videoSpeedType;

@end
