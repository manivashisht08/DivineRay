//
//  SLCameraView.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 02/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "SLCameraBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^clickBackToHomeBtnBlock)(void);

@class SLCameraView;
@class SLFilterData;

@protocol SLVideoCameraDelegate <NSObject>
- (void)videoMergingWillStart:(SLCameraView *)cameraView;
- (void)videoMergingDidFailed:(SLCameraView *)cameraView;
- (void)deleteLastSegmentClicked:(SLCameraView *)SLCameraView;
- (void)mediaPickerDidClicked:(SLCameraView *)SLCameraView;
- (void)mediaFiltersDidClicked:(SLCameraView *)SLCameraView;
- (void)soundPickerDidClicked:(SLCameraView *)SLCameraView;
- (void)captureDidCompleted:(UIImage *)image withCameraView:(SLCameraView *)cameraView;
- (void)recordingDidCompleted:(NSString *)movePath withCameraView:(SLCameraView *)cameraView;
@end

@interface SLCameraView : SLCameraBaseView {
    GPUImageMovieWriter*    _movieWriter;
}

/**
 Proerty Declarations
 */
@property (nonatomic , copy) clickBackToHomeBtnBlock backToHomeBlock;
@property (nonatomic, assign) id<SLVideoCameraDelegate>delegate;

/**
 Create the Instance of SLCameraView
 
 1 - Through the - initWithFrame
 2 - Through the - DivineraySLCameraView
 3 - Through the - XIB
 */

- (instancetype)initWithFrame:(CGRect)frame;
/**
 Utility Methods -
 */
- (void)deleteLastRecordedSegment;
- (void)applyFilters:(SLFilterData *)filterModel;
- (void)applySound:(NSString *)soundFilePath;
- (BOOL)isRecordingExists;

- (void)stopCameraCapture;
- (void)startCameraCapture;

- (void)pauseRecording;
- (void)resumeRecording;
- (void)releaseCameraResources;
- (void)resetRecording;
- (void)pauseMusicForceFully;
- (void)updateSoundViewText:(NSString *)titleText withMuisicId:(NSString*)muisicId;
- (void)addStateObserver;
- (void)removeStateObserver;
-(void)resetFlashButton;
@end

NS_ASSUME_NONNULL_END
