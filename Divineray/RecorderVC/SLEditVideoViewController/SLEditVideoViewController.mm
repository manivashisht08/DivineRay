//
//  SLEditVideoViewController.m
//  SlikeVideoProcessing
//
//  Created by ""  on 08/10/18.
//  Copyright © 2018 "" . All rights reserved.
//
#import "SLEditVideoViewController.h"
#import "GPUImage.h"
#import "SLFilterData.h"
#import "SLFiltersView.h"
#import "SLGlobalShared.h"
#import "SLVideoEditor.h"
#import "SDAVAssetExportSession.h"
#import "LFGPUImageEmptyFilter.h"
#import "SLVideoTool.h"
#import "UIAlertController+SLBlocks.h"
#import "SLAudioPlayer.h"
#import "UIView+Toast.h"
#import "UIView+InnerShadow.h"
#import "SLFileTools.h"
#import "VideoUtilities.h"
#import "UPloadViewController.h"

@interface SLEditVideoViewController () <GPUImageMovieDelegate> {
}
//New UI
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeader;

@property(nonatomic,strong) PostVideoModel * videoModel;
@property (strong, nonatomic) NSURL *exportedMp4URL;
@property (strong, nonatomic) NSString *postMessage;

@property (weak, nonatomic) IBOutlet UIImageView *captureImageView;
@property (nonatomic, strong) SLFiltersView *filtersCollectionView;
@property (nonatomic, strong) SLFilterData *currentFilterModel;

@property(strong, nonatomic)  AVPlayer *               videoPlayer;
@property (strong, nonatomic) SLAudioPlayer            *audioPlayer;
@property (nonatomic, strong) GPUImageMovie *          gpuMoviePlayer;
@property (nonatomic, strong) GPUImageView *           gpuRendererView;
@property (nonatomic,strong)  GPUImageOutput<GPUImageInput> * commonFilter;
@property (nonatomic,strong)  GPUImageOutput<GPUImageInput> * specialFilter;

//Filters Modified
@property (nonatomic, strong) GPUImageMovieWriter*  movieWriter;
@property (nonatomic, strong) GPUImageMovie*        movieComposition;
@property (assign, nonatomic) BOOL isPopViewActive;
@property (nonatomic, assign) BOOL isdoing;
@property (nonatomic,strong) UISwipeGestureRecognizer* swipeLeft;
@property (nonatomic,strong) UISwipeGestureRecognizer* swipeRight;
@property (weak, nonatomic) IBOutlet UIImageView *placeHolderImage;
@property (weak, nonatomic) IBOutlet UIImageView *topShadow;
@property (weak, nonatomic) IBOutlet UIImageView *bottomShadow;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImage;


@end

@implementation SLEditVideoViewController

- (void)_setupUI {
    
    [self setupOutletsUI];
    self.activePopupView = SLActivePopupViewNone;
    
    _isPopViewActive = NO;
    [self _createFiltersLisView];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.bottomShadow addInnerShadowWithRadius:self.view.frame.size.height/2 andColor:[UIColor blackColor] inDirection:NLInnerShadowDirectionBottom];
    [self.topShadow addInnerShadowWithRadius:self.view.frame.size.height/2 andColor:[UIColor blackColor] inDirection:NLInnerShadowDirectionTop];
    
    self.topShadow.alpha =  0.6;
    self.bottomShadow.alpha =  0.6;

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _setupUI];
    if(_postViewModel.captureImage != nil)
       {
           //Image
       }
    else
       {
           if(self.postViewModel.shootFinishMergedVideoPath)
           {
    NSURL * videoUrl = [NSURL fileURLWithPath:self.postViewModel.shootFinishMergedVideoPath];
    
    self.placeHolderImage.image = [SLVideoTool mh_getVideoTempImageFromVideo:videoUrl withTime:0];
    CGSize videoSize = [SLVideoTool mh_getVideoSize:videoUrl];
    UIViewContentMode contentMode = [SLVideoTool determineVideoContentMode:videoSize];
    if (contentMode == UIViewContentModeScaleAspectFit) {
        [_placeHolderImage  setContentMode:contentMode];
    } else {
        [_placeHolderImage  setContentMode:UIViewContentModeScaleToFill];
    }
       }
       }
    
    self.cutSoundButton.enabled = NO;
    
    if(self.postViewModel.havingAudioOnRecording && self.postViewModel.bgMusicPath.length > 2) {
        _audioPlayer = [[SLAudioPlayer alloc]initWithAudioFile:_postViewModel.bgMusicPath];
        _audioPlayer.autoPlayOff = YES;
        [_audioPlayer updateSongVolume:1.0];
        self.postViewModel.videoVolume = 0.0;
        self.cutSoundButton.enabled = YES;
        [_audioPlayer pauseSound];
    }
    if(_postViewModel.captureImage != nil)
    {
        _captureImageView.image = _postViewModel.captureImage;
        _captureImageView.hidden =  NO;
    }else
    {
    _captureImageView.hidden =  YES;
    [self configPlayer];
    }
    self.topHeader.constant = 15.0 ;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if(mainWindow.safeAreaInsets.top > 0){
            self.topHeader.constant = mainWindow.safeAreaInsets.top;
        }
    }
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_audioPlayer && [_audioPlayer isPlaying]) {
           [_audioPlayer pauseSound];
       }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeStateChangeObserver];
    [self removeNoti];
    [self updateMovieMusicState_pause:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addMovieNoti];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [self addStateChangeObserver];
    [self updateMovieMusicState_pause:NO];
}

- (IBAction)closeButtonDidClicked:(id)sender {
  if (_audioPlayer) {
         [_audioPlayer pauseSound];
         _audioPlayer = nil;
     }
    if (!_postViewModel.havingAudioOnRecording) {
        _postViewModel.bgMusicPath = @"";
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)removeObserverHide
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark-  Actions
- (IBAction)addSoundButtonDidClicked:(id)sender
{
   // _self.audioPlayer = [[SLAudioPlayer alloc]initWithAudioFile:_self.postViewModel.bgMusicPath];

}

#pragma mark- Filters Creation
/**
 Create the Filters list View
 */
- (void)_createFiltersLisView {
    
    self.filtersCollectionView = [SLFiltersView DivinerayFiltersView];
    [self.view addSubview:_filtersCollectionView];
    _filtersCollectionView.frame = CGRectMake(0, SLSCREEN_HEIGHT - 140, SLSCREEN_WIDTH, 140);
    
    [_filtersCollectionView initialiseFiltersResource];
    [_filtersCollectionView reloadFilters];
    _filtersCollectionView.alpha=0.0;
    __weak typeof(self) _self = self;
    _filtersCollectionView.selectedFilter = ^(SLFilterData * _Nonnull filterModel,  NSInteger itemIndex) {
        
        [_self.navigationController.view hideAllToasts];
        [_self.navigationController.view makeToast:filterModel.name
                                          duration:2.0
                                          position:CSToastPositionCenter];
        
        _self.currentFilterModel = filterModel;
        [_self.gpuMoviePlayer removeAllTargets];
        _self.commonFilter = [SLFilterData selectedModelFilter:filterModel];
        [_self.gpuMoviePlayer addTarget:_self.commonFilter];
        [_self.commonFilter addTarget:_self.gpuRendererView];
    };
    
    _filtersCollectionView.hideFilters = ^{
        //[_self _hideFiltersView];
    };

    
}

- (void)swipe:(UISwipeGestureRecognizer*)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft ) {
        if (_filtersCollectionView) {
            [_filtersCollectionView swapLeftFilterGesture  ];
        }
        
    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight ) {
        if (_filtersCollectionView) {
            [_filtersCollectionView swapRightFilterGesture];
        }
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.gpuRendererView.frame = ScreenSize;
    self.gmpuImageContainer.frame = ScreenSize;
    self.shadowImage.frame = ScreenSize;
    
}

#pragma mark - Player Functionality
- (void)configPlayer {
    if(self.postViewModel.shootFinishMergedVideoPath)
    {
    NSURL * videoUrl = [NSURL fileURLWithPath:self.postViewModel.shootFinishMergedVideoPath];
    
    self.videoPlayer = [[AVPlayer alloc] init];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    [self.videoPlayer replaceCurrentItemWithPlayerItem:playerItem];
    self.videoPlayer.volume = self.postViewModel.videoVolume;
    
    self.gpuMoviePlayer = [[GPUImageMovie alloc]initWithPlayerItem:playerItem];
    _gpuMoviePlayer.playAtActualSpeed = YES;
    _gpuMoviePlayer.shouldRepeat = YES;
    self.commonFilter = [[LFGPUImageEmptyFilter alloc] init];
    self.specialFilter = [[LFGPUImageEmptyFilter alloc] init];
    [_gpuMoviePlayer addTarget:_commonFilter];
    self.gpuRendererView = [[GPUImageView alloc] initWithFrame:ScreenSize];
    
    if(_postViewModel.isGalleryVideo) {
        
        [self setRotationForFilter:_commonFilter withPlayerItem:playerItem];
        CGSize videoSize = [SLVideoTool mh_getVideoSize:videoUrl];
        UIViewContentMode contentMode = [SLVideoTool determineVideoContentMode:videoSize];
        if (contentMode == UIViewContentModeScaleAspectFit) {
            [_gpuRendererView setFillMode:kGPUImageFillModePreserveAspectRatio];
        } else {
            [_gpuRendererView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
        }
    } else {
        [_gpuRendererView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    }
    
    [_gpuRendererView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.gmpuImageContainer addSubview:_gpuRendererView];
    self.gmpuImageContainer.frame = ScreenSize;
    [_commonFilter addTarget:_gpuRendererView];
    
    [self _configureInitialSounds];
    if(self.postViewModel.bgMusicPath.length >2) {
        self.videoPlayer.muted = YES;
    }
    [self performSelector:@selector(_hidePlaceHolderImage) withObject:self afterDelay:2];
    }
}

- (void)addMovieNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)removeNoti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)_rePlayRecordedMedia {
    [self.videoPlayer seekToTime:kCMTimeZero];
    [self.videoPlayer play];
    if (self.audioPlayer && self.audioPlayer.isPlaying) {
        _audioPlayer.seekTime = CMTimeMakeWithSeconds(self.postViewModel.bgmStartTime, NSEC_PER_SEC);
        [self.audioPlayer restartAudioPlayer];
        [self.audioPlayer playSound];
    }
}

#pragma mark - Application States Notifications
- (void)onApplicationWillResignActive {
    if (_isdoing) {
        [_movieWriter cancelRecording];
        [_movieComposition endProcessing];
    }
    
    [self updateResignStateIsActive:NO];
}

- (void)onApplicationDidBecomeActive {
    if (_isdoing) {
    }
    [self updateResignStateIsActive:YES];
}

/**
 Notification that the Movie has ended - Need to reply it again
 @param notification - Notification
 */
- (void)playbackFinished:(NSNotification *)notification {
    [self _rePlayRecordedMedia];
}

#pragma GPUImageMovieDelegate
- (void)didCompletePlayingMovie {
    [self _rePlayRecordedMedia];
}





/**
 Mix the Filter with the Video
 @param callBack - Input Video Path
 */
- (void)compositionFilterWithCallBack:(void(^)(BOOL success, NSURL * outUrl))callBack {
    
    NSURL * videoUrl = [NSURL fileURLWithPath:self.postViewModel.shootFinishMergedVideoPath];
    _isdoing = YES;
    
    self.movieComposition = [[GPUImageMovie alloc] initWithURL:videoUrl];
    _movieComposition.runBenchmark = YES;
    _movieComposition.playAtActualSpeed = NO;
    
    GPUImageOutput<GPUImageInput> *specialFilter = [[LFGPUImageEmptyFilter alloc] init];
    
    GPUImageOutput<GPUImageInput> *commonFilter;
    if ([_currentFilterModel.fillterName isEqualToString:@"GPUImageSaturationFilter"]) {
        GPUImageSaturationFilter* xxxxfilter = [[NSClassFromString(_currentFilterModel.fillterName) alloc] init];
        xxxxfilter.saturation = [_currentFilterModel.value integerValue];
        commonFilter = xxxxfilter;
    } else {
        commonFilter = [[NSClassFromString(_currentFilterModel.fillterName) alloc] init];
    }
    
    [_movieComposition addTarget:commonFilter];
    [commonFilter addTarget:specialFilter];
    
    //Synthesized video path
    NSString * outPath = [PostVideoModel creatAVideoTempPath];
    unlink([outPath UTF8String]);
    NSLog(@"Save path after adding a filter：%@",outPath);
    NSURL * outPutUrl = [NSURL fileURLWithPath:outPath];
    
    //Video angle
    NSUInteger a = [SLVideoTool mh_getDegressFromVideoWithURL:videoUrl];
    //Get video size
    CGSize videoSize = [SLVideoTool mh_getVideoSize:videoUrl];
    if (a == 90 || a == 270) {
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    videoSize = [SLVideoTool mh_fixVideoOutPutSize:videoSize];
    NSLog(@"size:%f-%f",videoSize.width,videoSize.height);
    
    if (_postViewModel.isGalleryVideo) {
        self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:outPutUrl size:videoSize];
    } else {
        self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:outPutUrl size:CGSizeMake(720.0, 1280.0)];
    }
    
    _movieWriter.skipAudioCheck = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    //Sometimes because the video file does not have an audio track error.....I don't know why
    _movieComposition.audioEncodingTarget = _movieWriter;
    [specialFilter addTarget:_movieWriter];
    
    [_movieComposition enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    [_movieWriter startRecording];
    [_movieComposition startProcessing];
    
    __weak GPUImageMovieWriter *weakmovieWriter = _movieWriter;
    [_movieWriter setCompletionBlock:^{
        [specialFilter removeAllTargets];
        [commonFilter removeAllTargets];
        [weakmovieWriter finishRecording];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callBack(YES,outPutUrl);
        });
    }];
    [_movieWriter setFailureBlock:^(NSError *error) {
        [specialFilter removeAllTargets];
        [commonFilter removeAllTargets];
        [weakmovieWriter finishRecording];
        NSLog(@"Filter addition failed %@",error.description);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callBack(NO,nil);
        });
    }];
}



#pragma mark - sound Setting View
- (IBAction)equlizerButtonDidClicked:(id)sender {
    self.activePopupView = SLActivePopupViewMixer;
    [self showSoundLevelView];
}

- (void)_configureInitialSounds {
    [_audioPlayer updateSongVolume:_postViewModel.bgmVolume];
    _videoPlayer.volume = _postViewModel.videoVolume;
}

#pragma mark - Handle Next Button Action
- (IBAction)nextButtonDidClicked:(id)sender {
    
    if (!self.currentFilterModel || [_currentFilterModel.fillterName isEqualToString:@"LFGPUImageEmptyFilter"]) {
        //Show loader
        [VideoUtilities showLoadingAt:self.navigationController.view];
        //Both are empty filters. No processing required. Add background music directly.
        [PostVideoModel videoAddBGM_videoUrl:[NSURL fileURLWithPath:self.postViewModel.shootFinishMergedVideoPath] originalInfo:self.postViewModel callBack:^(BOOL success, NSString *outPurPath) {
            if (success) {
                self.postViewModel.finalVideoPath = outPurPath;
                [self jumpToPostVC:nil];
                
            } else{
                [VideoUtilities hideLoadingAt:self.navigationController.view];
                [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went wrong, please try again" isSucess:NO];
            }
        }];
        
    } else {
        // [self compositionFilterWithCallBack:[NSURL fileURLWithPath:_postViewModel.shootFinishMergedVideoPath]];
        //Add filter - Adding a filter will lose the original audio
        [VideoUtilities showLoadingAt:self.navigationController.view];
        [self compositionFilterWithCallBack:^(BOOL success, NSURL *outUrl) {
            if (success) {
                [PostVideoModel videoAddBGM_videoUrl:outUrl originalInfo:self.postViewModel callBack:^(BOOL success, NSString *outPurPath) {
                    if (success) {
                        self.postViewModel.finalVideoPath = outPurPath;
                        [self jumpToPostVC:nil];
                    }else{
                        [VideoUtilities hideLoadingAt:self.navigationController.view];
                       [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went wrong, please try again" isSucess:NO];
                    }
                }];
            }else{
                [VideoUtilities hideLoadingAt:self.navigationController.view];
                [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went wrong, please try again" isSucess:NO];
            }
        }];
        
    }
}



#pragma mark - Music
- (IBAction)cutSoundButtonDidClicked:(id)sender {
    self.activePopupView = SLActivePopupViewCropMusic;
    [self showMusicCutterView];
}

#pragma mark - Show Music Cutter View
- (void)showMusicCutterView {
    if (self.audioPlayer) {
           [self.audioPlayer pauseSound];
       }
}

- (void)update_bgm {
    if (self.postViewModel.bgMusicPath != nil || self.postViewModel.bgMusicPath.length > 2) {
        _audioPlayer = [[SLAudioPlayer alloc]initWithAudioFile:_postViewModel.bgMusicPath];
        _audioPlayer.seekTime = CMTimeMakeWithSeconds(self.postViewModel.bgmStartTime, NSEC_PER_SEC);
        [_audioPlayer updateSongVolume:self.postViewModel.bgmVolume];
        
        [self.videoPlayer seekToTime:kCMTimeZero];
        [_audioPlayer restartAudioPlayer];
    }
}

- (void)_hideMusicCutterView
{
    
}


#pragma mark - Show Sound Level
- (void)showSoundLevelView {
    
    _isPopViewActive = YES;
    [self _hidePopupViews];
    
    BOOL haveSound = NO;
    if (_postViewModel.bgMusicPath && [_postViewModel.bgMusicPath length]>2) {
        haveSound = YES;
    }

}

#pragma mark - EditSoundsLevelDelegate
- (void)updateOrignalSound:(float)soundLavel {
    [_videoPlayer setVolume:soundLavel];
}

- (void)updateMusicSound:(float)musicLavel {
    [_audioPlayer updateSongVolume:musicLavel];
}

- (void)doneButtonDidClicked:(float)soundLavel withMusic:(float)musicLevel {
    _postViewModel.videoVolume = soundLavel;
    _postViewModel.bgmVolume = musicLevel;
    [_audioPlayer updateSongVolume:musicLevel];
    [_videoPlayer setVolume:soundLavel];
    [self _removeSoundEditView];
}

- (void)_removeSoundEditView
{
    
}

/**
 Play/Pause the Music
 @param pause - YES|NO
 */
- (void)updateMovieMusicState_pause:(BOOL)pause {
    
    if (pause) {
        [self.videoPlayer pause];
        if (self.audioPlayer) {
            [self.audioPlayer pauseSound];
        }
        [self.gpuMoviePlayer endProcessing];
    }else {
        [self.videoPlayer seekToTime:kCMTimeZero];
        [self.videoPlayer play];
        if (self.audioPlayer) {
            _audioPlayer.autoPlayOff = NO;
            _audioPlayer.seekTime = CMTimeMakeWithSeconds(self.postViewModel.bgmStartTime, NSEC_PER_SEC);
            [self.audioPlayer restartAudioPlayer];
            [self.audioPlayer playSound];
        }
        [self.gpuMoviePlayer startProcessing];
    }
}

- (void)_hidePlaceHolderImage {
    self.placeHolderImage.hidden = YES;
}

- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset {
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty) {
        return UIInterfaceOrientationLandscapeRight;
    }
    else if (txf.tx == 0 && txf.ty == 0) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    else if (txf.tx == 0 && txf.ty == size.width) {
        return UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        return UIInterfaceOrientationPortrait;
    }
}

- (void)setRotationForFilter:(GPUImageOutput<GPUImageInput> *)filterRef  withPlayerItem:(AVPlayerItem *)playerItem {
    UIInterfaceOrientation orientation = [self orientationForTrack:playerItem.asset];
    if (orientation == UIInterfaceOrientationPortrait) {
        [filterRef setInputRotation:kGPUImageRotateRight atIndex:0];
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        [filterRef setInputRotation:kGPUImageRotate180 atIndex:0];
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        [filterRef setInputRotation:kGPUImageRotateLeft atIndex:0];
    }
}

- (void)updateResignStateIsActive:(BOOL)isActive {
    if (!isActive) {
        [self.videoPlayer pause];
        if (self.audioPlayer) {
            [self.audioPlayer pauseSound];
        }
        [self.gpuMoviePlayer endProcessing];
        
    } else {
        [self.videoPlayer play];
        [self.gpuMoviePlayer startProcessing];
        if (self.audioPlayer) {
            [self.audioPlayer playSound];
        }
    }
}

- (void)dealloc {
    NSLog(@"dealloc=> SLEditVideoViewController");
    if (self.audioPlayer) {
        [_audioPlayer pauseSound];
        [_audioPlayer releaseAudioPlayer];
        self.audioPlayer = nil;
    }
    [self _releaseGPUResources];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)_releaseGPUResources {
    
    if (self.gpuMoviePlayer) {
        [self.gpuMoviePlayer endProcessing];
        [_movieWriter cancelRecording];
        self.movieWriter = nil;
    }
    
    if (self.movieComposition) {
        [_movieComposition endProcessing];
        [_movieComposition removeAllTargets];
        self.movieComposition = nil;
    }
    
    if (self.gpuMoviePlayer) {
        [_gpuMoviePlayer endProcessing];
        [_gpuMoviePlayer removeAllTargets];
        self.gpuMoviePlayer = nil;
    }
    
    if (self.gpuRendererView) {
        [_gpuRendererView endProcessing];
        self.gpuRendererView = nil;
    }
    
   
    
    if (self.filtersCollectionView && [self.filtersCollectionView superview]) {
        [self.filtersCollectionView removeFromSuperview];
        self.filtersCollectionView = nil;
    }
   
    self.currentFilterModel = nil;
    self.videoPlayer = nil;
    self.commonFilter = nil;
    self.specialFilter = nil;
}

- (void)addStateChangeObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
     
}

- (void)removeStateChangeObserver {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark -  Jump to post controller
- (void)jumpToPostVC:(NSURL *)movieURL {
    [_videoPlayer pause];
    self.activePopupView = SLActivePopupViewNone;
    if (movieURL) {
        self.postViewModel.finalVideoPath = movieURL.path;
    }
    self.postViewModel.captureImage = [VideoUtilities generateThumbImage:self.postViewModel.finalVideoPath];

    //convert mp4 when sent video
    [VideoUtilities hideLoadingAt:self.navigationController.view];
        self.videoModel = _postViewModel;
    //Your Design Here

    UPloadViewController* obj = [[UPloadViewController alloc]initWithNibName:NSStringFromClass([UPloadViewController class]) bundle:[NSBundle mainBundle]];
    obj.postViewModel = _postViewModel;
    [self.navigationController pushViewController:obj animated:YES];

  
}

/**
 Delete the  disk File. We do not want it anymore
 */
- (void)deleteDiskFile {
    [SLFileTools deleteFileAtPath:_videoModel.finalVideoPath];
    if(_exportedMp4URL)
    {
    [SLFileTools deleteFileAtPath:_exportedMp4URL.path];
    _exportedMp4URL =  nil;
    }
}

- (void)popController  {
    [self deleteDiskFile];
}

- (void)onApplicationDidEnterBackgroundNew {
    [self updateMovieMusicState_pause:YES];

}
- (void)onApplicationDidBecomeActiveNew {
    
    [self updateMovieMusicState_pause:NO];
}
- (BOOL)isDeviceIsIphoneX {
    BOOL iPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.top > 24.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}

@end
