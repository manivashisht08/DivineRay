//
//  SLCameraView.m
//  SlikeVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 02/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "UIView+Tools.h"
#import "SLCameraView.h"
#import "SLGlobalShared.h"
#import "UPloadTimerControl.h"
#import "DivinerayVideoMerger.h"
#import "SLFileTools.h"
#import "SLFilterData.h"
#import "GPUImageWaveFilter.h"
#import "ZScrollLabel.h"
#import "SLAudioPlayer.h"
#import "PostVideoModel.h"
#import "DivinerayHighlightButton.h"

@interface SLCameraView ()  {
}
@property (nonatomic,assign) NSInteger min_record;
@property (nonatomic,assign) NSInteger max_record;

@property (nonatomic, assign) float curentRecodlength;
@property (nonatomic, assign) float lastTime;
@property (nonatomic, strong) NSURL *pathToMovie;
@property (nonatomic, strong) NSMutableArray *lastRecordedTimeArray;
@property (nonatomic, strong) NSMutableArray *virticalDeviderArray;
@property (nonatomic, assign) float progressStep;
@property (nonatomic, assign) float deviderWidth;
@property (nonatomic, strong) NSString* filtClassName;
@property (nonatomic, assign) float saturationValue;

@property (strong, nonatomic)SLAudioPlayer *audioPLayer;

// Animation Of UIlabels
@property(nonatomic,assign)MHShootSpeedType videoSpeedType;
@property(nonatomic,strong)PostVideoModel * videoModel;
@property(nonatomic,assign)BOOL addSeprator;
@property(nonatomic,assign)BOOL isImageClick;
@property (nonatomic, strong) UPloadTimerControl* divinerayTimer;

@end


@implementation SLCameraView
#pragma mark - Instance Initialisations
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

#pragma mark - View Initialisations
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _initialiseResource];
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    [self _initialiseResource];
    return self;
}
/**
 Initialise the Resources
 */

- (void)commitInstances {
    
    //Create path for saving the video output
    [SLFileTools createDirectoryInDocuments:KLUG_VIDEO_FOLDER];
    [SLFileTools createDirectoryInDocuments:KLUG_DRAFT_FOLDER];
    
    [PostVideoModel cleanShootTempCache];
    self.videoSpeedType = MHShootSpeedTypeNomal;
    self.videoModel = [[PostVideoModel alloc] init];
    
    _lastRecordedTimeArray = [[NSMutableArray alloc] init];
    _virticalDeviderArray = [[NSMutableArray alloc] init];
    _divinerayTimer = [[UPloadTimerControl alloc]init];
    
    _addSeprator = YES;
    _curentRecodlength = 0;
    _lastTime = 0;
    _deviderWidth = 2;
    _progressStep = ((SLSCREEN_WIDTH-20)*TIMER_INTERVAL)/self.max_record;
    
    float loopValue = 1/TIMER_INTERVAL;
    self.minRecordingView.frame = CGRectMake((loopValue*_progressStep)* self.min_record, 0, _deviderWidth, self.recordingProgressView.frame.size.height);
    
}

- (void)_initialiseResource {
    _min_record = 5;
    _max_record = 180;
    
    [self commitInstances];
    
    //initialise Camera
    [self initialiseCamera];
    //Set up with empty Filter
    [self setupCameraWithEmptyFilter];
    
    [self _addGUIComponents];
    [self _addGestureToCameraView];
    [self addLogPressGesture:self.cameraSwitchButton];
    
    //Start the Camera Capturing
    [self.slVideoCamera startCameraCapture];
    self.recordingTopLbl.text =  [self formatTime:_curentRecodlength];
    
}
/**
 Start the recording of the Movie
 */
- (void)shootShouldBeginRecording {
    
    self.isRecording = YES;
    [self.recordingButton setSelected:YES];
    [self _hidesControlsWhileRecording];
    
    self.addSoundButton.enabled = NO;
    [self updateSoundView:NO withText:@""];
    [self playMusic];
    
    _lastTime = _curentRecodlength;
    [_lastRecordedTimeArray addObject:[NSString stringWithFormat:@"%f",_lastTime]];
    ShootSubVideo * subModel = [self.videoModel addSubVideoInfoWithSpeedType:self.videoSpeedType];
    _pathToMovie = [NSURL fileURLWithPath:subModel.subVideoPath];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_pathToMovie size:CGSizeMake(720.0, 1280.0)];
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    _movieWriter.hasAudioTrack = YES;
    _movieWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid;
    [self.slFilter addTarget:_movieWriter];
    self.slVideoCamera.audioEncodingTarget = _movieWriter;
    [_movieWriter startRecording];
    [self _initialiseTimer];
}
-(void)imageClickStop
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isImageClick =  NO;
    });
    
}
- (void)shootShouldEndRecording  {
    [_divinerayTimer clear];
    if(_curentRecodlength > self.min_record) {
        if (self.nextButton.alpha <= 0) {
            self.nextButton.alpha = 1.0;
        }
        [self setNextButtonState_IsEnabled:YES];
    }else {
        self.nextButton.alpha = 0.0;
        [self setNextButtonState_IsEnabled:NO];
    }
    if([self.audioPLayer isPlaying]) {
        [self.audioPLayer pauseSound];
    }
    [self.recordingButton setSelected:NO];
    [self _vissibleControlsWhileRecordingStoped];
    if (!self.isRecording) {
        return;
    }
    self.isRecording = NO;
    self.slVideoCamera.audioEncodingTarget = nil;
    if (_addSeprator) {
        [self _addVirticalDevider];
    }
    
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [self.slFilter removeTarget:self->_movieWriter];
        [self->_divinerayTimer clear];
    }];
    [self.videoSegmentsArray addObject:_pathToMovie];
    if (self.videoSegmentsArray.count) {
        
        //Need to comment this line for showing the galley button
        [self.recordingView Divineray_appearState:NO];
        [self.recordingLbl Divineray_appearState:NO];
        [self.recordingTopLbl Divineray_appearState:YES];
        [self.deleteSegmentsButton Divineray_appearState:YES];
    }
}

- (void)changeRecordingStatus:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = YES;
        [self shootShouldBeginRecording];
    } else {
        
        sender.selected = NO;
        [self shootShouldEndRecording];
    }
}

/**
 Stop the recording of the Movie
 */
- (void)stopRecording {
    [_divinerayTimer clear];
    [self cameraRecordingDidStop];
    
    NSString *path = [SLFileTools getVideoMergeFilePathString];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self mergeAndExportVideos:self.videoSegmentsArray withOutPath:path];
    });
}

- (void)checkPremission{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        self->_addSeprator = NO;
        [self stopRecording];
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
                self->_addSeprator = NO;
                [self stopRecording];
                NSLog(@"Granted access to %@", mediaType);
            } else {
                NSLog(@"Not granted access to %@", mediaType);
            }
        }];
    } else {
        // impossible, unknown authorization status
    }
}

/**
 Merge the Video Segments
 @param videosPathArray - Array Containg the Video Segments
 @param outpath - Path Where the Final Video will be Saved
 */
- (void)mergeAndExportVideos:(NSArray*)videosPathArray withOutPath:(NSString*)outpath {
    
    _addSeprator = YES;
    if (videosPathArray.count == 0) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoMergingWillStart:)]) {
        [self.delegate videoMergingWillStart:self];
    }
    
    [DivinerayVideoMerger mergeRecordedVideosWithFileURLs:videosPathArray videoStoredPath:outpath completion:^(NSURL *mergedVideoURL, NSError *error) {
        
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoMergingDidFailed:)]) {
                [self.delegate videoMergingDidFailed:self];
            }
            //Need to reset the resources. We have got the some errors during the merging of video segments...
            //[self _resetInstances];
            return ;
        }
        //Sucessfully merged the Video Segments...
        [self.slVideoCamera stopCameraCapture];
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordingDidCompleted: withCameraView:)]) {
            [self.delegate recordingDidCompleted:outpath withCameraView:self];
        }
    }];
}

/**
 Initialise the Timer
 */
- (void)_initialiseTimer {
    __weak typeof(self) _self = self;
    _divinerayTimer.executionBlock = ^(UPloadTimerControl * _Nonnull control) {
        [_self hanldeTimerValues];
    };
    [_divinerayTimer start];
}

/**
 Update te
 */
- (void)hanldeTimerValues
{
    _curentRecodlength += TIMER_INTERVAL;
    
    self.recordingTopLbl.text =  [self formatTime:_curentRecodlength];
    
    float progressWidth = self.recordingProgressView.frame.size.width +_progressStep;
    [self _updateRecordingProgressWidth:progressWidth];
    if (_curentRecodlength > self.min_record) {
        if (self.nextButton.alpha <= 0) {
            self.nextButton.alpha = 1.0;
        }
        [self setNextButtonState_IsEnabled:YES];
    }
    
    if (_curentRecodlength >= self.max_record) {
        [self nextButtonDidClicked:nil];
    }
}
-(NSString *)formatTime:(float) elapsedSeconds {
    
    if(elapsedSeconds <= 0) {
        self.recordingTopLbl.hidden = YES;
        return @"00:00";
    }
    self.recordingTopLbl.hidden = NO;
    int time = (int)elapsedSeconds;
    
    int seconds = time % 60;
    int minutes = (time / 60) % 60;
    NSString *str = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    
    return  str;
}

/**
 Create the GUI elements (Buttons)
 */
- (void)_addGUIComponents {
    
    [self addGuiElements];
    //Add Sound
    [self updateSoundView:YES withText:@"Add Sound"];
    self.deleteSegmentsButton.alpha =0.0;
    self.nextButton.alpha = 0.0;
    [self setNextButtonState_IsEnabled:FALSE];
    [self _updateRecordingProgressWidth:0];
}

- (void)_addVirticalDevider {
    
    if (_curentRecodlength > 0 &&_curentRecodlength <= self.max_record) {
        CGFloat xPosition =  CGRectGetMaxX(self.recordingProgressView.frame);
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){ceil(xPosition-_deviderWidth), 0, _deviderWidth, self.recordingProgressView.frame.size.height}];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self.recordingProgressView addSubview:lineView];
        [_virticalDeviderArray addObject:lineView];
    }
}
/**
 Hide the UI elements while recoding is going on
 */
- (void)_hidesControlsWhileRecording {
    
    [self.backButton Divineray_appearState:NO];
    [self.beautifyFilterButton Divineray_appearState:NO];
    [self.flashButton Divineray_appearState:NO];
    [self.cameraSwitchButton Divineray_appearState:NO];
    [self.fileterView Divineray_appearState:NO];
    ////Need to comment this line for showing the galley button
    [self.recordingView Divineray_appearState:NO];
    [self.recordingLbl Divineray_appearState:NO];
    [self.recordingTopLbl Divineray_appearState:YES];
    [self.deleteSegmentsButton Divineray_appearState:NO];
    [self.virticalMenuBar Divineray_appearState:NO];
    
    //Set the next Button state : YES
}

/**
 show the UI elements when recording has done
 */
- (void)_vissibleControlsWhileRecordingStoped {
    
    [self.backButton Divineray_appearState:YES];
    [self.beautifyFilterButton Divineray_appearState:YES];
    [self.flashButton Divineray_appearState:YES];
    [self.cameraSwitchButton Divineray_appearState:YES];
    [self.fileterView Divineray_appearState:YES];
    [self.virticalMenuBar Divineray_appearState:YES];
    
    //Set the next Button state : NO
}

/**
 Set the Next Button State.
 @param enabled - Button has enabled
 */
- (void)setNextButtonState_IsEnabled:(BOOL)enabled {
    if (enabled && self.nextButton.isEnabled) {
        return;
    }
    [UIView transitionWithView:self.nextButton
                      duration:0.1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
        self.nextButton.enabled = enabled;
    }
                    completion:nil];
}

/**
 Update the rocording width with the timer
 @param width - Updated width
 */
- (void)_updateRecordingProgressWidth:(float)width {
    self.recordingProgressView.frame = CGRectMake(0, 0 , width, self.recordingProgressView.frame.size.height);
}

/**
 Reset the instances and its values ..
 */
- (void)resetRecording {
    [_divinerayTimer clear];
    self.addSoundButton.enabled = YES;
    if (self.audioPLayer) {
        [_audioPLayer releaseAudioPlayer];
        self.audioPLayer = nil;
    }
    _curentRecodlength = 0;
    _lastTime = 0;
    self.deleteSegmentsButton.alpha = 0;
    //Need to comment this line for showing the galley button
    self.recordingView.alpha = 1;
    self.recordingButton.selected = NO;
    [_lastRecordedTimeArray removeAllObjects];
    for(UIView *devider in _virticalDeviderArray) {
        [devider removeFromSuperview];
    }
    [_virticalDeviderArray removeAllObjects];
    [self removeAllCachedSegments:YES];
    
    self.isRecording = false;
    self.tapRecordingIsActive = NO;
    self.nextButton.alpha = 0;
    [self _updateRecordingProgressWidth:0];
    
    self.recordingTopLbl.text =  [self formatTime:_curentRecodlength];
    [self.recordingLbl Divineray_appearState:YES];
    [self.recordingTopLbl Divineray_appearState:NO];
    
}

- (IBAction)cameraFiltersButtonDidClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaFiltersDidClicked:)]) {
        [self.delegate mediaFiltersDidClicked:self];
    }
}

- (void)removeAllCachedSegments:(BOOL)resetALL {
    if (resetALL) {
        for (NSString *pathSegment in self.videoSegmentsArray){
            [[NSFileManager defaultManager]removeItemAtPath:pathSegment error:nil];
        }
        [self.videoSegmentsArray removeAllObjects];
    }
}

/**
 Delete the recent recorded segment
 @param sender -  Button action
 */
- (IBAction)deleteSegmentsButtonDidClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteLastSegmentClicked:)]) {
        [self.delegate deleteLastSegmentClicked:self];
    }
}

- (void)deleteLastRecordedSegment {
    
    float progressWidth = [_lastRecordedTimeArray.lastObject floatValue]/self.max_record * (SLSCREEN_WIDTH-20);
    
    [self _updateRecordingProgressWidth:progressWidth];
    _curentRecodlength = [_lastRecordedTimeArray.lastObject floatValue];
    
    if (self.videoSegmentsArray.count) {
        NSString *filePath = self.videoSegmentsArray.lastObject;
        if (filePath) {
            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        }
        [self.videoSegmentsArray removeLastObject];
        [_lastRecordedTimeArray removeLastObject];
        
        if (self.videoSegmentsArray.count == 0) {
            //Need to comment this line for showing the galley button
            [self.recordingView Divineray_appearState:YES];
            [self.recordingLbl Divineray_appearState:YES];
            [self.recordingTopLbl Divineray_appearState:NO];
            [self.deleteSegmentsButton Divineray_appearState:NO];
            self.addSoundButton.enabled = YES;
            if(self.videoSegmentsArray.count >0 && (_curentRecodlength > self.min_record))
            {
                if (self.nextButton.alpha <= 0) {
                    self.nextButton.alpha = 1.0;
                }
                [self setNextButtonState_IsEnabled:YES];
            }else {
                self.nextButton.alpha = 0.0;
                [self setNextButtonState_IsEnabled:NO];
            }
            if (self.audioPLayer) {
                [_audioPLayer seekAudioPlayer:kCMTimeZero];
            }
        }else {
            if (self.audioPLayer) {
                [_audioPLayer seekAudioPlayer:CMTimeMakeWithSeconds(self.curentRecodlength, NSEC_PER_SEC)];
            }
        }
        
        
        [[_virticalDeviderArray lastObject] removeFromSuperview];
        [_virticalDeviderArray removeLastObject];
        if (_curentRecodlength < self.min_record) {
            self.nextButton.alpha = 0.0;
            [self setNextButtonState_IsEnabled:NO];
        }
    }
    self.recordingTopLbl.text =  [self formatTime:_curentRecodlength];
    
}

- (IBAction)openGalleryButtonDidClicked:(id)sender {
    //Need to comment this line for showing the galley button
    // return;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPickerDidClicked:)]) {
        [self.delegate mediaPickerDidClicked:self];
    }
}

- (IBAction)cameraSwitchButtonDidClicked:(id)sender
{
    [self switchCameraMode];
    
    
}


- (IBAction)nextButtonDidClicked:(id)sender {
    [self checkPremission];
    
}

- (IBAction)beautifyFilterButton:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = YES;
        [self changeToBeautifyFilter:YES];
    } else {
        sender.selected = NO;
        [self changeToBeautifyFilter:NO];
    }
}

#pragma mark - New Function

- (void)releaseCameraResources {
    
    [self.slVideoCamera stopCameraCapture];
    if (self.isRecording) {
        [_movieWriter cancelRecording];
        [self.slFilter removeTarget:_movieWriter];
        self.isRecording = NO;
    }
    [self resetRecording];
    
}

- (BOOL)isRecordingExists {
    if ([_lastRecordedTimeArray count] >0) {
        return YES;
    }
    return NO;
}

- (IBAction)backButtonDidClicked:(id)sender {
    //Completion Block moving back to Parent Screen
    if (self.backToHomeBlock) {
        self.backToHomeBlock();
    }
}

- (void)applyFilters:(SLFilterData *)filterModel {
    
    _filtClassName = filterModel.fillterName;
    
    if ([filterModel.fillterName isEqualToString:@"GPUImageSaturationFilter"]) {
        GPUImageSaturationFilter* gpuFilter = [[NSClassFromString(_filtClassName) alloc] init];
        gpuFilter.saturation = [filterModel.value floatValue];
        _saturationValue = [filterModel.value floatValue];
        self.slFilter = gpuFilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImageWaveFilter"]) {
        GPUImageWaveFilter* gpuFilter = [[NSClassFromString(_filtClassName) alloc] init];
        gpuFilter.normalizedPhase = [filterModel.value floatValue];
        self.slFilter = gpuFilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImageGammaFilter"]) {
        GPUImageGammaFilter* gpuFilter = [[NSClassFromString(_filtClassName) alloc] init];
        gpuFilter.gamma = [filterModel.value floatValue];
        self.slFilter = gpuFilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImagePosterizeFilter"]) {
        GPUImagePosterizeFilter* gpuFilter = [[NSClassFromString(_filtClassName) alloc] init];
        gpuFilter.colorLevels = [filterModel.value floatValue];
        self.slFilter = gpuFilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImageLuminanceRangeFilter"]) {
        GPUImageLuminanceRangeFilter* gpuFilter = [[NSClassFromString(_filtClassName) alloc] init];
        gpuFilter.rangeReductionFactor = [filterModel.value floatValue];
        self.slFilter = gpuFilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImageExposureFilter"]) {
        GPUImageExposureFilter* gpuFilter = [[NSClassFromString(_filtClassName) alloc] init];
        gpuFilter.exposure = [filterModel.value floatValue];
        self.slFilter = gpuFilter;
    }
    else {
        self.slFilter = [[NSClassFromString(_filtClassName) alloc] init];
    }
    [self.slVideoCamera removeAllTargets];
    if (_movieWriter) {
        [self.slFilter addTarget:_movieWriter];
    }
    [self.slVideoCamera addTarget:self.slFilter];
    [self.slFilter addTarget:self.slFilteredVideoView];
}

#pragma mark - Sound Functionality
- (IBAction)soundButtonDidClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(soundPickerDidClicked:)]) {
        [self.delegate soundPickerDidClicked:self];
    }
}
- (void)playMusic {
    if (self.audioPLayer) {
        if([self.audioPLayer isPlaying]) {
            [self.audioPLayer pauseSound];
        } else {
            [self.audioPLayer playSound];
        }
    }
}

- (void)removeSound {
    if (self.audioPLayer) {
        [self.audioPLayer pauseSound];
        self.audioPLayer = nil;
    }
    self.videoModel.muisicId = @"";
    [self updateSoundView:YES withText:@"Add Sound"];
}
- (void)applySound:(NSString *)soundFilePath {
    
    [self.audioPLayer releaseAudioPlayer];
    self.audioPLayer = nil;
    self.audioPLayer = [[SLAudioPlayer alloc]initWithAudioFile:soundFilePath];
}

- (void)pauseRecording {
    if(_movieWriter){
        [_movieWriter setPaused:YES];
    }
}

- (void)resumeRecording {
    if ([_movieWriter isPaused] && _movieWriter) {
        [_movieWriter setPaused:NO];
    }
}

- (void)stopCameraCapture {
    [self.slVideoCamera stopCameraCapture];
}
- (void)startCameraCapture {
    [self resetZoomFactor];
    [self.slVideoCamera startCameraCapture];
    
}
-(void)resetFlashButton
{
    if(self.isFlashOn)
    {
        [self toggleTorch];
        self.flashButton.selected = [self isFlashOn];
    }
}
#pragma mark -
- (void)onApplicationDidBecomeActive {
    
    [self startCameraCapture];
}
- (void)onApplicationWillResignActive {
    if(self.isFlashOn)
    {
        [self toggleTorch];
        self.flashButton.selected = [self isFlashOn];
    }
    if (self.recordingButton.isSelected && self.isRecording ) {
        self.recordingButton.selected = YES;
        [self stopShootBtnAnimation:self.recordingButton];
        [self changeRecordingStatus:self.recordingButton];
    }
    [self stopCameraCapture];
    
}

#pragma mark - Recording Button Actions
/**
 Recording through the Touch Down
 */
- (void)cameraRecordingDidStart {
    if (_curentRecodlength >= self.max_record) {
        return;
    }
    
    self.recordingButton.selected = NO;
    [self startShootBtnAnimation:self.recordingButton];
    [self changeRecordingStatus:self.recordingButton];
}

- (void)cameraRecordingDidStop {
    self.recordingButton.selected = YES;
    [self stopShootBtnAnimation:self.recordingButton];
    [self changeRecordingStatus:self.recordingButton];
}
- (void)pauseMusicForceFully {
    if (self.audioPLayer) {
        [self.audioPLayer pauseSound];
    }
}


#pragma mark - Sound Functionlity
- (void)updateSoundView:(BOOL)enable withText:(NSString *)titleText {
    [self.scrollLabel setFont:[UIFont systemFontOfSize:15]];
    if (enable) {
        //self.soundImage.image = SLKlugSharedImagePath(@"add_sound");
        self.scrollLabel.textColor = [UIColor whiteColor];
    } else {
        //self.soundImage.image = SLKlugSharedImagePath(@"add_sound_des");
        self.scrollLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    }
    if (![titleText isEqualToString:@""] && titleText != nil) {
        self.scrollLabel.text = titleText;
    }
}

- (void)updateSoundViewText:(NSString *)titleText {
    if (![titleText isEqualToString:@""] && titleText != nil) {
        self.scrollLabel.text = titleText;
    }
}
- (void)updateSoundViewText:(NSString *)titleText withMuisicId:(NSString*)muisicId{
    if (![titleText isEqualToString:@""] && titleText != nil) {
        self.scrollLabel.text = titleText;
        self.videoModel.muisicId = muisicId;
    }else {
        self.scrollLabel.text = @"Add Sound";
        self.videoModel.muisicId = muisicId;
    }
}

- (void)dealloc {
    if (self.audioPLayer) {
        [_audioPLayer pauseSound];
        self.audioPLayer = nil;
    }
    self.slFilteredVideoView = nil;
    self.customView = nil;
    self.slFocusLayer = nil;
    self.slVideoCamera = nil;
    self.slFilter = nil;
    [self removeStateObserver];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.cameraTopLayerView.frame = [[UIScreen mainScreen]bounds];
}


- (void)addStateObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)removeStateObserver {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}



@end

