//
//  SLCameraBaseView.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 10/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "ZScrollLabel.h"


@interface SLCameraBaseView : UIView {
}
@property(nonatomic,strong)  NSMutableArray* videoSegmentsArray;
@property (weak, nonatomic) IBOutlet UIImageView *recordingTopImageViewView;

@property (weak, nonatomic) IBOutlet UIView *recordingTopView;
@property (weak, nonatomic) IBOutlet UILabel *recordingTopLbl;

@property (weak, nonatomic) IBOutlet UIView *fileterView;
@property (weak, nonatomic) IBOutlet UIView *recordingView;
@property (weak, nonatomic) IBOutlet UILabel *recordingLbl;

@property (weak, nonatomic) IBOutlet UIButton *microphoneButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitchButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *beautifyFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *filtersButton;
@property (weak, nonatomic) IBOutlet UIButton *openGalleryButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteSegmentsButton;
@property (weak, nonatomic) IBOutlet UIView *virticalMenuBar;
@property (weak, nonatomic) IBOutlet UIView *recordingProgressView;
@property (weak, nonatomic) IBOutlet UIView *minRecordingView;
@property (weak, nonatomic) IBOutlet ZScrollLabel *scrollLabel;
@property (weak, nonatomic) IBOutlet UIImageView *soundImage;
@property (weak, nonatomic) IBOutlet UIButton  *addSoundButton;
@property (nonatomic, weak) IBOutlet UIButton *recordingButton;
@property (nonatomic, strong)IBOutlet UIView *topHeaderView;
@property (nonatomic, assign) BOOL isFlashOn; 
@property (weak, nonatomic) IBOutlet UIView *progressHeaderView;
@property (weak, nonatomic) IBOutlet UIView *captureBgView;
@property (weak, nonatomic) IBOutlet UIView *recordingButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *cameraTopLayerView;
@property (assign, nonatomic) BOOL tapRecordingIsActive;
@property (nonatomic, assign) BOOL isRecording;
@property (weak, nonatomic) IBOutlet UIImageView *topShadow;
@property (weak, nonatomic) IBOutlet UIImageView *bottomShadow;

@property (strong, nonatomic)IBOutlet GPUImageView*   slFilteredVideoView;
@property (nonatomic, strong) SLCameraBaseView *customView;
@property (nonatomic, strong) CALayer*   slFocusLayer;
@property (nonatomic, strong) GPUImageStillCamera* slVideoCamera;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput>*  slFilter;

- (void)addGuiElements;
- (void)initialiseCamera;
- (void)switchCameraMode;
- (void)toggleTorch;
- (void)setupCameraFocus:(CGPoint)location;
- (void)setupCameraWithEmptyFilter;
- (void)changeToBeautifyFilter:(BOOL)isBeautifyFilter;
- (void)_addGestureToCameraView;
- (void)zoomtoScale:(CGFloat)scale withZoom:(BOOL)hasBegunToZoom;
- (void)addLogPressGesture:(UIButton *)recordButton;
- (void)processSingleTapAction:(BOOL)isFromeTimerCliclk;
- (void)resetZoomFactor;

/**
 Animation
 */
- (void)startShootBtnAnimation:(UIView *)animButton;
- (void)stopShootBtnAnimation:(UIView *)animButton;

@end

