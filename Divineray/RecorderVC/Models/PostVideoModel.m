//
//  PostVideoModel.m
//  Created by "" on 2019/02/25.
//  Copyright © 2019. All rights reserved.
//

#import "PostVideoModel.h"
#import "SLVideoTool.h"


/** Video local temporary folder */
static NSString * shortSubVideoTempDoc() {
    NSString * document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString * docPath = [document stringByAppendingPathComponent:@"shootVideoTempDoc"];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if(![fileManage fileExistsAtPath:docPath]){
            [fileManage createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return docPath;
}
/** Video local temporary path */
static NSString * gatAVideoTempPath() {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    NSString * fileName = [NSString stringWithFormat:@"video_%f.mov",time];
    NSString *subPath = [shortSubVideoTempDoc() stringByAppendingPathComponent:fileName];
    if([fileManage fileExistsAtPath:subPath]){
        [fileManage removeItemAtPath:subPath error:nil];
    }
    return subPath;
}

@implementation PostVideoModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.videoVolume = 1.0;
        self.bgmVolume = 1.0;
        self.videoCaverLocation = 0.0;
        self.bgMusicPath = @"";
        self.captureImage =  nil;
        self.muisicId = @"";
    }
    return self;
}
#pragma mark - Add a sub video model based on the video capture speed and return to the current add model
- (ShootSubVideo *)addSubVideoInfoWithSpeedType:(MHShootSpeedType)videoSpeedType
{
    ShootSubVideo * subModel = [[ShootSubVideo alloc] init];
    subModel.videoSpeedType = videoSpeedType;
    unlink([subModel.subVideoPath UTF8String]);
    NSMutableArray * arr = [NSMutableArray arrayWithArray:self.subVideoInfos];
    [arr addObject:subModel];
    self.subVideoInfos = [NSArray arrayWithArray:arr];
    
    return subModel;
}
#pragma mark - Delete the previous sub-video
- (void)removeLastSubVideoInfo {
    NSMutableArray * arr = [NSMutableArray arrayWithArray:self.subVideoInfos];
    if (arr.count > 0) {
        [arr removeLastObject];
    }
    self.subVideoInfos = [NSArray arrayWithArray:arr];
}
#pragma mark - Calculate the sum of all sub video video durations
-(CGFloat)getAllSubVideoInfoVideoLength
{
    CGFloat totleLength = 0.f;
    for (ShootSubVideo * subvideo in self.subVideoInfos) {
        totleLength += subvideo.videolength;
    }
    return totleLength;
}
- (CGFloat)shootFinishVideolength
{
    if (!self.shootFinishMergedVideoPath) {
        return 0.f;
    }
    
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:self.shootFinishMergedVideoPath]];
    CGFloat length = (CGFloat)asset.duration.value/(CGFloat)asset.duration.timescale;
    return length;
}
#pragma mark - Shift + merge the sub video after shooting
+(void)compositionSubVideos:(NSArray<ShootSubVideo *> *)subVideoInfos callBack:(void (^)(BOOL, NSString *))callBack
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PostVideoModel changeSpeedVideo:subVideoInfos callBack:^(NSArray * changedSpeedVideoPathArr) {
            NSString * videoPath = gatAVideoTempPath();
            NSURL * outPutUrl = [NSURL fileURLWithPath:videoPath];
            [SLVideoTool mergeVideosWithPaths:changedSpeedVideoPathArr outPutUrl:outPutUrl callBack:^(BOOL success, NSURL *outPurUrl) {
                callBack(success,outPurUrl.path);
            }];
            
        }];
    });

}
+(void)changeSpeedVideo:(NSArray<ShootSubVideo *> *)subVideoInfos callBack:(void(^)(NSArray *))callBack
{
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    for (int j = 0; j < subVideoInfos.count; j ++) {
        [arr addObject:@""];
    }
    
    for (int i = 0; i < subVideoInfos.count; i ++) {
        ShootSubVideo * subVideo = (ShootSubVideo *)subVideoInfos[i];
        NSURL * videoUrl = [NSURL fileURLWithPath:subVideo.subVideoPath];
        [PostVideoModel changeSpeedVideoUrl:videoUrl speed:[PostVideoModel videoSpeedFor:subVideo.videoSpeedType] videoindex:i callBack:^(BOOL success, NSString *outUrlPath, NSInteger videoIndex) {
            [arr replaceObjectAtIndex:videoIndex withObject:outUrlPath];
            
            //Determine if all is processed
            BOOL isFinished = YES;
            for (NSString * subInfo in arr) {
                if ([subInfo isEqualToString:@""]) {
                    isFinished = NO;
                    break;
                }
            }
            if (isFinished) {
                callBack([NSArray arrayWithArray:arr]);
                return;
            }
            
        }];
    }
}
+(void)changeSpeedVideoUrl:(NSURL *)videoUrl speed:(CGFloat)speed videoindex:(NSInteger)index callBack:(void(^)(BOOL success,NSString * outUrlPath,NSInteger videoIndex))callBack
{
    NSString * subPath = gatAVideoTempPath();
    NSURL * outPutUrl = [NSURL fileURLWithPath:subPath];
    
    [SLVideoTool changeVideoSpeed:videoUrl speed:speed outPutUrl:outPutUrl callBack:^(BOOL success) {
        callBack(success,subPath,index);
    }];
}
+(CGFloat)videoSpeedFor:(MHShootSpeedType)speedType
{
    switch (speedType) {
        case MHShootSpeedTypeNomal:
        {
            return 1.0;
        }
            break;
        case MHShootSpeedTypeaSlow:
        {
            return 2.0;
        }
            break;
        case MHShootSpeedTypeMoreSlow:
        {
            return 4.0;
        }
            break;
        case MHShootSpeedTypeFast:
        {
            return 0.5;
        }
            break;
        case MHShootSpeedTypeMorefast:
        {
            return 0.25;
        }
            break;
        default:
            break;
    }
    return 1.0;
}
#pragma mark - Merge video + audio
+(void)videoAddBGM_videoUrl:(NSURL *)videoUrl originalInfo:(PostVideoModel *)model callBack:(void (^)(BOOL, NSString *))callBack
{
    //If there is background music, you need to crop the background music first.
    if (model.bgMusicPath.length > 2) {
        //Crop background music first
        NSURL * bgmUrl = [NSURL fileURLWithPath:model.bgMusicPath];
        [SLVideoTool crapMusicWithUrl:bgmUrl startTime:model.bgmStartTime length:[SLVideoTool mh_getVideolength:videoUrl] callBack:^(BOOL success, NSURL *outPurUrl) {
            
            NSURL * finalBGMUrl = bgmUrl;
            if (success) {
                finalBGMUrl = outPurUrl;
            }
            [SLVideoTool mergevideoWithVideoUrl:videoUrl
                     originalAudioTrackVideoUrl:[NSURL fileURLWithPath:model.shootFinishMergedVideoPath]
                                         bgmUrl:finalBGMUrl
                                 originalVolume:model.videoVolume
                                      bgmVolume:model.bgmVolume
                                      outPutUrl:[NSURL fileURLWithPath:gatAVideoTempPath()]
                                       callBack:^(BOOL success, NSURL *outPurUrl) {
                                           callBack(success,outPurUrl.path);
                                       }];
        }];
    }else{
        //No background music
        [SLVideoTool mergevideoWithVideoUrl:videoUrl
                 originalAudioTrackVideoUrl:[NSURL fileURLWithPath:model.shootFinishMergedVideoPath]
                                     bgmUrl:nil
                             originalVolume:model.videoVolume
                                  bgmVolume:model.bgmVolume
                                  outPutUrl:[NSURL fileURLWithPath:gatAVideoTempPath()]
                                   callBack:^(BOOL success, NSURL *outPurUrl) {
            callBack(success,outPurUrl.path);
        }];
    }
}
#pragma mark - Clear shot temporary video files
+(void)cleanShootTempCache
{
    NSString *cachPath = shortSubVideoTempDoc();
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    for (NSString *subFile in files) {
        NSError *error;
        NSString *path = [cachPath stringByAppendingPathComponent:subFile];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
}
#pragma mark -Create - return a video temporary path
+(NSString *)creatAVideoTempPath
{
    NSString * subPath = gatAVideoTempPath();
    return subPath;
}
@end


@implementation ShootSubVideo

-(id)init
{
    self = [super init];
    if (self) {
        //Directly assign a segmented video path during initialization
        NSString * subPath = gatAVideoTempPath();
        _subVideoPath = subPath;
        
        //Default video speed 1.0 (original speed)
        _videoSpeedType = MHShootSpeedTypeNomal;
    }
    return self;
}
- (CGFloat)videolength
{
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:self.subVideoPath]];
    CGFloat length = (CGFloat)asset.duration.value/(CGFloat)asset.duration.timescale;
    return length;
}

@end
