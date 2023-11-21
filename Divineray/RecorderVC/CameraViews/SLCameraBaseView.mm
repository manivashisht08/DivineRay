//
//  SLCameraBaseView.m
//  SlikeVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 10/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import "SLCameraBaseView.h"
#import "GPUImageBeautifyFilter.h"
#import "LFGPUImageEmptyFilter.h"
#import "UIView+Tools.h"
#import "UIView+SmartHighlight.h"
#import "UIView+InnerShadow.h"
#import "NSLayoutConstraint+SSULayout.h"
#import "UITextField+slTextField.h"


typedef NS_ENUM(NSInteger, CameraManagerDevicePosition) {
    CameraManagerDevicePositionBack,
    CameraManagerDevicePositionFront,
};

@interface SLCameraBaseView () <UIGestureRecognizerDelegate> {
    
}
@property (assign)CGFloat initialPinchZoom;
@property (assign)CGFloat zoomFactor;
@property (nonatomic, assign) CameraManagerDevicePosition position;
@property (assign, nonatomic)CGPoint panStartPoint;
@property (assign, nonatomic)CGFloat panStartZoom;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapPressGesture;

@end

#define kBorderColor     [UIColor colorWithRed:253.0/255.0 green:49.0/255.0 blue:108.0/255.0 alpha:0.5].CGColor
#define kBorderColorZoom [UIColor colorWithRed:253.0/255.0 green:49.0/255.0 blue:108.0/255.0 alpha:1.0].CGColor
#define kButtonColor [UIColor colorWithRed:253.0/255.0 green:49.0/255.0 blue:108.0/255.0 alpha:1.0]

#define kRecordButtonWidth  65.0
#define kCornerRadiusWidth  40.0
#define kBorderWidth  6.0

@implementation SLCameraBaseView

- (void)addGuiElements {
    self.recordingTopView.layer.cornerRadius = 16.0;
    self.recordingTopView.layer.borderWidth = 1.0;
    self.recordingTopView.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0  blue:102.0/255.0  alpha:1.0].CGColor;
    
    self.recordingTopView.clipsToBounds =  YES;
    _recordingTopImageViewView.image = [UIImage imageNamed:@"nounRecording.png"];
    
    //Set the Header view properties
    [_backButton setImage:[UIImage imageNamed:@"popup_close.png"] forState:UIControlStateNormal];
    _backButton.showsTouchWhenHighlighted = YES;
    [_cameraSwitchButton setImage:[UIImage imageNamed:@"cameraSwitch.png"] forState:UIControlStateNormal];
    _cameraSwitchButton.showsTouchWhenHighlighted = YES;
    _microphoneButton.hidden = YES;
    [_flashButton setImage:[UIImage imageNamed:@"flashButton.png"] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@"flashButton_on.png"] forState:UIControlStateSelected];
//    [_nextButton setImage:[UIImage imageNamed:@"complete.png"] forState:UIControlStateNormal];
    _flashButton.showsTouchWhenHighlighted = YES;
    [_beautifyFilterButton setImage:[UIImage imageNamed:@"beautyOFF.png"] forState:UIControlStateNormal];
    [_beautifyFilterButton setImage:[UIImage imageNamed:@"beautyON.png"] forState:UIControlStateSelected];
    _beautifyFilterButton.showsTouchWhenHighlighted = YES;
    [_deleteSegmentsButton setImage:[UIImage imageNamed:@"delete_recording.png"] forState:UIControlStateNormal];
    [_filtersButton setImage:[UIImage imageNamed:@"filterIcon.png"] forState:UIControlStateNormal];
    [_filtersButton setImage:[UIImage imageNamed:@"filterIcon.png"] forState:UIControlStateSelected];
    
    
    [_openGalleryButton setImage:[UIImage imageNamed:@"gallery.png"] forState:UIControlStateNormal];
    //Need to comment this line for showing the galley button
    _openGalleryButton.hidden = NO;
    _recordingLbl.hidden =  NO;
    _recordingTopLbl.hidden = YES;

    [self.topShadow addInnerShadowWithRadius:self.frame.size.height/2 andColor:[UIColor blackColor] inDirection:NLInnerShadowDirectionTop];
    self.topShadow.alpha =  0.6;
    [self.bottomShadow addInnerShadowWithRadius:[UIApplication sharedApplication].keyWindow.frame.size.height/2 andColor:[UIColor blackColor] inDirection:NLInnerShadowDirectionBottom];

    self.bottomShadow.alpha =  0.6;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
if(![device hasFlash])
{
    _flashButton.userInteractionEnabled = false;
    _flashButton.alpha = 0.3;
}
    [self.deleteSegmentsButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteSegmentsButton setTitle:@"Delete" forState:UIControlStateSelected];
    [self.deleteSegmentsButton centerVertically:0];
    
_nextButton.layer.cornerRadius = 2.0;
  _nextButton.layer.masksToBounds = YES;
  _nextButton.showsTouchWhenHighlighted = YES;
  _nextButton.layer.borderColor = [UIColor colorWithRed:27.0/255.0 green:66.0/255.0 blue:141.0/255.0 alpha:1.0].CGColor;
  _nextButton.layer.borderWidth = 2;
  [_nextButton setTitleColor:[UIColor colorWithRed:27.0/255.0 green:66.0/255.0 blue:141.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        _customView.frame = self.bounds;
        if(CGRectIsEmpty(frame)) {
            self.bounds = _customView.bounds;
        }
        [self addSubview:_customView];
        
        _panStartPoint = CGPointZero;
        _panStartZoom = 0.0;
        [self setupRecording];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if(self) {
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        _customView.frame = self.bounds;
        [self addSubview:_customView];
        
        _panStartPoint = CGPointZero;
        _panStartZoom = 0.0;
        
        [self setupRecording];
        
    }
    return self;
}

- (void)setupRecording {
    self.videoSegmentsArray = [[NSMutableArray alloc]init];
    _captureBgView.layer.borderColor = kBorderColor;
    _recordingButton.backgroundColor =  kButtonColor;
    _captureBgView.layer.borderWidth = kBorderWidth;
    _captureBgView.layer.cornerRadius = kCornerRadiusWidth;
    _recordingButton.layer.cornerRadius = kRecordButtonWidth/2;
    
}


#pragma mark - View Initialisations
- (void)awakeFromNib {
    [super awakeFromNib];
    _panStartPoint = CGPointZero;
    _panStartZoom = 0.0;
    [self setupRecording];
}

/**
 Initiase the camera.
 */
- (void)initialiseCamera {
    
    [self setupRecording];
    _panStartPoint = CGPointZero;
    _panStartZoom = 0.0;
    
    // _topHeaderView.hidden = YES;
    //Initialze the camera and set the postion for the Camera
    
    _slVideoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
 
    if ([_slVideoCamera.inputCamera lockForConfiguration:nil]) {
        
        if ([_slVideoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [_slVideoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        if ([_slVideoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [_slVideoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        if ([_slVideoCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [_slVideoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [_slVideoCamera.inputCamera unlockForConfiguration];
    }
    
    _position = CameraManagerDevicePositionBack;
    _slVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    [_slVideoCamera addAudioInputsAndOutputs];
    _slVideoCamera.horizontallyMirrorFrontFacingCamera = YES;
    _slVideoCamera.horizontallyMirrorRearFacingCamera = NO;
    self.progressHeaderView.layer.cornerRadius = 3;
    self.progressHeaderView.layer.masksToBounds = YES;

    [self.progressHeaderView activateConstraints:^{
        self.progressHeaderView.height_attr.constant = 6;
        [self.progressHeaderView.leading_attr equalTo: self.leading_attr constant:10];
        [self.progressHeaderView.trailing_attr equalTo: self.trailing_attr constant:-10];
        [self.progressHeaderView.top_attr equalTo: self.top_attr_safe constant:4];
    }];
}

- (void)resetZoomFactor {
    if ([_slVideoCamera.inputCamera lockForConfiguration:nil]) {
        _slVideoCamera.inputCamera.videoZoomFactor = 1;
        [_slVideoCamera.inputCamera unlockForConfiguration];
    }
}


- (IBAction)flasButtonDidClicked:(id)sender {
    [self toggleTorch];
    self.flashButton.selected = [self isFlashOn];
}
/**
 Switch the Camera Mode
 */
- (void)switchCameraMode {
    
    switch (_position) {
        case CameraManagerDevicePositionBack: {
            if (_slVideoCamera.cameraPosition == AVCaptureDevicePositionBack) {
                [_slVideoCamera pauseCameraCapture];
                _position = CameraManagerDevicePositionFront;
                [_slVideoCamera rotateCamera];
                [_slVideoCamera resumeCameraCapture];
                [_slVideoCamera removeAllTargets];
                _slFilter = [[GPUImageBeautifyFilter alloc] init];
                [_slVideoCamera addTarget:_slFilter];
                [_slFilter addTarget:_slFilteredVideoView];
                _flashButton.userInteractionEnabled = false;
                _flashButton.alpha = 0.3;
                self.flashButton.selected =  NO;
            }
        }
            break;
        case CameraManagerDevicePositionFront: {
            if (_slVideoCamera.cameraPosition == AVCaptureDevicePositionFront) {
                [_slVideoCamera pauseCameraCapture];
                _position = CameraManagerDevicePositionBack;
                [_slVideoCamera rotateCamera];
                [_slVideoCamera resumeCameraCapture];
                [_slVideoCamera removeAllTargets];
                _slFilter = [[LFGPUImageEmptyFilter alloc] init];
                [_slVideoCamera addTarget:_slFilter];
                [_slFilter addTarget:_slFilteredVideoView];
                _flashButton.userInteractionEnabled = true;
                _flashButton.alpha = 1.0;
                if(self.isFlashOn)
                {
                    self.isFlashOn =  NO;
                    [self toggleTorch];
                    self.flashButton.selected =  self.isFlashOn;

                }
            }
        }
            break;
        default:
            break;
    }
    if ([_slVideoCamera.inputCamera lockForConfiguration:nil] && [_slVideoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [_slVideoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [_slVideoCamera.inputCamera unlockForConfiguration];
    }
    
   
}

- (void)toggleTorch {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if(captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if([device hasTorch] && [device hasFlash]) {
            if(!self.isFlashOn) {
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [device unlockForConfiguration];
                [self setIsFlashOn:YES];
            } else {
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [device unlockForConfiguration];
                [self setIsFlashOn:NO];
            }
        }
    }
}

/**
 Add the Basic Filters to Camera
 */
- (void)setupCameraWithEmptyFilter {
    _slFilter = [[LFGPUImageEmptyFilter alloc] init];
    _slFilteredVideoView.frame = [[UIScreen mainScreen] bounds];
    [_slFilteredVideoView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    [_slFilteredVideoView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    [_slVideoCamera addTarget:_slFilter];
    [_slFilter addTarget:_slFilteredVideoView];
}

- (void)changeToBeautifyFilter:(BOOL)isBeautifyFilter {
    
    [_slVideoCamera removeAllTargets];
    if( isBeautifyFilter) {
        _slFilter = [[GPUImageBeautifyFilter alloc] init];
    } else {
        _slFilter = [[LFGPUImageEmptyFilter alloc] init];
    }
    [_slVideoCamera addTarget:_slFilter];
    [_slFilter addTarget:_slFilteredVideoView];
}
-(CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates withFrameSize:(CGSize) frameSize {
    
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize apertureSize = CGSizeMake(1280, 720);
    CGPoint point = viewCoordinates;
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    CGFloat xc = .5f;
    CGFloat yc = .5f;
    
    if (viewRatio > apertureRatio) {
        CGFloat y2 = frameSize.height;
        CGFloat x2 = frameSize.height * apertureRatio;
        CGFloat x1 = frameSize.width;
        CGFloat blackBar = (x1 - x2) / 2;
        if (point.x >= blackBar && point.x <= blackBar + x2) {
            xc = point.y / y2;
            yc = 1.f - ((point.x - blackBar) / x2);
        }
    }else {
        CGFloat y2 = frameSize.width / apertureRatio;
        CGFloat y1 = frameSize.height;
        CGFloat x2 = frameSize.width;
        CGFloat blackBar = (y1 - y2) / 2;
        if (point.y >= blackBar && point.y <= blackBar + y2) {
            xc = ((point.y - blackBar) / y2);
            yc = 1.f - (point.x / x2);
        }
    }
    pointOfInterest = CGPointMake(xc, yc);
    return pointOfInterest;
}

+ (CALayer *)setFocusImage {
    
    UIImage *focusImage = [UIImage imageNamed:@"cam_focus.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
    imageView.image = focusImage;
    CALayer *layer = imageView.layer;
    layer.hidden = YES;
    return layer;
}

- (void)setupCameraFocus:(CGPoint)location {
    
    [self _setfocusImage];
    [self _layerAnimationWithPoint:location];
    
    AVCaptureDevice *device = _slVideoCamera.inputCamera;
    CGPoint pointOfInterest = [self convertToPointOfInterestFromViewCoordinates:location withFrameSize:_slFilteredVideoView.frame.size];
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [device setFocusPointOfInterest:pointOfInterest];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [device setExposurePointOfInterest:pointOfInterest];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
    } else {
        NSLog(@"ERROR = %@", error);
    }
}
/**
 Set the Focus Image
 */
- (void)_setfocusImage {
    CALayer *focusLayer = [self setFocusImage];
    [_slFilteredVideoView.layer addSublayer:focusLayer];
    _slFocusLayer = focusLayer;
}
-(CALayer *)setFocusImage {
    
    UIImage *focusImage = [UIImage imageNamed:@"cam_focus.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
    imageView.image = focusImage;
    CALayer *layer = imageView.layer;
    layer.hidden = YES;
    return layer;
}

/**
 Layer Animation with the Point
 @param point - Layer Points
 */
- (void)_layerAnimationWithPoint:(CGPoint)point {
    if (_slFocusLayer) {
        [UIView layerAnimationWithPoint:point withLayer:_slFocusLayer];
        [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:0.5f];
    }
}

/**
 Make Focus layer Normal
 */
- (void)focusLayerNormal {
    _slFilteredVideoView.userInteractionEnabled = YES;
    _slFocusLayer.hidden = YES;
}

/**
 Add Gesture to the View to get the TAP action
 */
- (void)_addGestureToCameraView {
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraViewTapAction:)];
    singleFingerOne.numberOfTouchesRequired = 1;
    singleFingerOne.numberOfTapsRequired = 1;
    [_slFilteredVideoView addGestureRecognizer:singleFingerOne];
    
    UIPinchGestureRecognizer* pich = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    [_slFilteredVideoView addGestureRecognizer:pich];
    
}
-(void)pinch:(UIPinchGestureRecognizer*)gestureRecognizer {
    [self zoomtoScale:gestureRecognizer.scale withZoom:gestureRecognizer.state == UIGestureRecognizerStateBegan];
}

- (void)zoomtoScale:(CGFloat)scale withZoom:(BOOL)hasBegunToZoom {
    if (hasBegunToZoom) {
        _initialPinchZoom =  _slVideoCamera.inputCamera.videoZoomFactor;
    }
    
    if ([_slVideoCamera.inputCamera lockForConfiguration:nil]) {
        if (scale < 1.0) {
            _zoomFactor = _initialPinchZoom - pow(_slVideoCamera.inputCamera.activeFormat.videoMaxZoomFactor, 1.0 - scale);
        } else {
            _zoomFactor = _initialPinchZoom + pow(_slVideoCamera.inputCamera.activeFormat.videoMaxZoomFactor, (scale - 1.0f) / 2.0f);
        }
        
        _zoomFactor = fmin(10.0, _zoomFactor);
        _zoomFactor = fmax(1.0, _zoomFactor);
        _slVideoCamera.inputCamera.videoZoomFactor = _zoomFactor;
        [_slVideoCamera.inputCamera unlockForConfiguration];
        
    }
}

/**
 Camera Tap Action
 @param tgr - Recognizer
 */
- (void)cameraViewTapAction:(UITapGestureRecognizer *)tgr {
    if (tgr.state == UIGestureRecognizerStateRecognized && (_slFocusLayer == nil || _slFocusLayer.hidden)) {
        CGPoint location = [tgr locationInView:_slFilteredVideoView];
        [self setupCameraFocus:location];
    }
}


- (void)addLogPressGesture:(UIButton *)recordButton {
    
    self.recordingButton.userInteractionEnabled = false;
    self.captureBgView.userInteractionEnabled = true;
    self.recordingButtonContainerView.userInteractionEnabled = true;
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    _longPressGesture.delegate = self;
    _longPressGesture.numberOfTapsRequired = 0;
    _longPressGesture.minimumPressDuration = 0.2;
    _longPressGesture.allowableMovement = 1.0;
    [_recordingButtonContainerView addGestureRecognizer:_longPressGesture];
    
    _tapPressGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapRecordingGestureRecognizer:)];
    _tapPressGesture.numberOfTapsRequired =1;
    [_recordingButtonContainerView addGestureRecognizer:_tapPressGesture];

}

- (void)singleTapRecordingGestureRecognizer:(UIGestureRecognizer *) gestureRecognizer  {
    [self processSingleTapAction:YES];
}

- (void)processSingleTapAction:(BOOL)isFromeTimerCliclk
{
    if (!_tapRecordingIsActive) {
        _tapRecordingIsActive = YES;
        _longPressGesture.enabled = NO;
        [self _willStartRecording];
    } else {
        self.tapRecordingIsActive = NO;
        _longPressGesture.enabled = YES;
        [self _willStopRecording];
    }
}


- (void)handleLongPressGestureRecognizer:(UIGestureRecognizer *) gestureRecognizer {
    
    if (_tapRecordingIsActive) {
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        self.panStartPoint = [gestureRecognizer locationInView:self];
        self.panStartZoom = _slVideoCamera.inputCamera.videoZoomFactor;
        
        float difx = [gestureRecognizer locationInView:self].x - _panStartPoint.x;
        float dify = [gestureRecognizer locationInView:self].y - _panStartPoint.y;
        CGAffineTransform newTransform = CGAffineTransformTranslate(_recordingButtonContainerView.transform, difx, dify);
        _recordingButtonContainerView.transform = newTransform;
        [self  _willStartRecording];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint newPoint = [gestureRecognizer locationInView:self];
        float difx = newPoint.x - _panStartPoint.x;
        float dify = newPoint.y - _panStartPoint.y;
        CGAffineTransform newTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, difx, dify);
        _recordingButtonContainerView.transform = newTransform;
        CGFloat scale = (self.panStartPoint.y / newPoint.y);
        CGFloat newZoom = (scale * self.panStartZoom);
        [self zoomCamera:newZoom];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
               gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        
        [self _willStopRecording];
    }
}

- (void)_willStopRecording {
    [self cameraRecordingDidStop];
}

- (void)_willStartRecording {
    [self cameraRecordingDidStart];
}

- (void)cameraRecordingDidStart {
    //Will called the derived
}

- (void)cameraRecordingDidStop {
    //Will called the derived
}

/**
 Zooming Camera
 @param newZoom - New Zoom Value
 */
- (void)zoomCamera:(CGFloat)newZoom {
    if ([_slVideoCamera.inputCamera lockForConfiguration:nil]) {
        CGFloat zoom  = fmax(1, fmin(newZoom, _slVideoCamera.inputCamera.activeFormat.videoMaxZoomFactor));
        _slVideoCamera.inputCamera.videoZoomFactor = zoom;
        [_slVideoCamera.inputCamera unlockForConfiguration];
    }
}

#pragma mark - Recording Animations
- (void)startShootBtnAnimation:(UIView *)animButton {
   
        //Video capure
    [self startRecordVideo:animButton];
    
}
- (void)stopShootBtnAnimation:(UIView *)animButton {
    [self _stopRecordVideo:animButton];
}

#pragma mark - Animations 
- (void)startRecordVideo:(UIView *)captureButton {
    
    self.captureBgView.layer.borderColor = kBorderColorZoom;
    [UIView animateWithDuration:HIGHLIGHT_SCALE_DURATION animations:^{
        captureButton.layer.cornerRadius = (8);
        captureButton.transform = CGAffineTransformMakeScale(0.6, 0.6);
        self.captureBgView.transform = CGAffineTransformMakeScale(1.7, 1.7);
        
    } completion:^(BOOL finished) {
        [self startRecordVideo];
    }];
}

- (void)_stopRecordVideo:(UIView *)captureButton {
    __weak __typeof__(self) _self = self;
    self.tapRecordingIsActive = NO;
    _longPressGesture.enabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:HIGHLIGHT_SCALE_DURATION animations:^{
            captureButton.layer.cornerRadius = kRecordButtonWidth/2;
            _self.captureBgView.layer.borderColor = kBorderColor;
            _self.captureBgView.layer.cornerRadius = kCornerRadiusWidth;
            _self.captureBgView.transform = CGAffineTransformMakeScale(1, 1);
            _self.captureBgView.transform = CGAffineTransformIdentity;
            _self.recordingButtonContainerView.transform = CGAffineTransformIdentity;
            captureButton.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            _self.captureBgView.transform = CGAffineTransformIdentity;
            [_self.recordingButton .layer removeAllAnimations];
            [_self.recordingButtonContainerView.layer removeAllAnimations];
            [_self.captureBgView.layer removeAllAnimations];
            
        }];
    });
}

- (void)startRecordVideo {
    [_captureBgView.layer addAnimation:[self createAnimationWithDuration:HIGHLIGHT_SCALE_DURATION delay:0] forKey:@"setBorderWidth"];
}


- (CABasicAnimation *)createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    anim.fromValue = [NSNumber numberWithFloat:8];
    anim.toValue = [NSNumber numberWithFloat:5];
    anim.autoreverses = YES;
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.beginTime = CACurrentMediaTime()+delay;
    anim.repeatCount = INFINITY;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}
@end
