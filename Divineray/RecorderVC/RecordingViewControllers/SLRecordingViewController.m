//
//  SLRecordingViewController.m
//  Vivek Dharmai
//
//  Created by Vivek Dharmai Rathor on 01/11/18.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import "SLRecordingViewController.h"
#import "SLCameraView.h"
#import "UIView+Tools.h"
#import "SLContentsDataSource.h"
#import "NSDictionary+SLTool.h"
#import "UIAlertController+SLBlocks.h"
#import "SLFiltersView.h"
#import "SLMusicListViewController.h"
#import <Photos/Photos.h>
#import "SLEditVideoViewController.h"
#import "PostVideoModel.h"
#import "UIView+Toast.h"
#import "SLFilterData.h"
#import "SLVideoTool.h"
#import "UIView+InnerShadow.h"
#import "ZFModalTransitionAnimator.h"

#import "SLGlobalShared.h"
#import "VideoUtilities.h"
typedef NS_ENUM(NSInteger, MusicOpertion) {
    KMusicOpertionChangeSound = 1,
    KMusicOpertionRemoveSound,
    KMusicOpertionNone
};

@interface SLRecordingViewController () <SLVideoCameraDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate> {
}
@property (weak, nonatomic) IBOutlet UIImageView *topShadow;

@property (strong, nonatomic) SLCameraView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (assign, nonatomic) BOOL hideStatusBar;
@property (nonatomic, strong) SLFiltersView *filtersView;
@property (strong, nonatomic) SLMusicListViewController * musicController;
@property (strong, nonatomic) NSString *musicFilePath;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@property (nonatomic,strong) PostVideoModel *postViewModel;
@property (assign,nonatomic) MusicOpertion musicOperation;
@property (nonatomic,strong) UISwipeGestureRecognizer* swipeLeft;
@property (nonatomic,strong) UISwipeGestureRecognizer* swipeRight;
@property (nonatomic,strong) UIButton* transparentButton;
@property (assign, nonatomic) BOOL isSwapEnabel;
@property (nonatomic,assign) NSInteger min_record;
@property (nonatomic,assign) NSInteger max_record;

@end

@implementation SLRecordingViewController
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _min_record = 5;
    _max_record = 60;
    _hideStatusBar = YES;
    _musicFilePath = nil;
    self.postViewModel = [[PostVideoModel alloc]init];
    [self initializeCameraView];
    [self.topShadow addInnerShadowWithRadius:self.view.frame.size.height/2 andColor:[UIColor blackColor] inDirection:NLInnerShadowDirectionTop];
    self.topShadow.alpha =  0.6;
//    NSString *mediaType = AVMediaTypeVideo;
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
//    if(authStatus == AVAuthorizationStatusAuthorized) {
//        // do your logic
//    } else if(authStatus == AVAuthorizationStatusDenied){
//        // denied
//    } else if(authStatus == AVAuthorizationStatusRestricted){
//        // restricted, normally won't happen
//    } else if(authStatus == AVAuthorizationStatusNotDetermined){
//        // not determined?!
//        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
//            if(granted){
//                NSLog(@"Granted access to %@", mediaType);
//            } else {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
//                                                                                   message:@"This is an alert."
//                                                                            preferredStyle:UIAlertControllerStyleAlert];
//                    
//                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                          handler:^(UIAlertAction * action) {}];
//                    
//                    [alert addAction:defaultAction];
//                    [self presentViewController:alert animated:YES completion:nil];
//                    NSLog(@"Not granted access to %@", mediaType);
//                });
//            }
//        }];
//    }
//    else {
//        
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isSwapEnabel =  NO;
    if (_cameraView) {
        [_cameraView removeStateObserver];
        [_cameraView pauseRecording];
        [_cameraView stopCameraCapture];
        [self.navigationController.view hideAllToasts];
    }
    [_cameraView resetFlashButton];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isSwapEnabel =  YES;
    [_cameraView addStateObserver];
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_cameraView) {
        [_cameraView startCameraCapture];
        [_cameraView resumeRecording];
    }
}

- (void)initializeCameraView {
    
    _musicOperation = KMusicOpertionNone;
    self.postViewModel = [[PostVideoModel alloc]init];
    if (self.cameraView) {
        [self.cameraView removeFromSuperview];
        self.cameraView =nil;
    }
    self.cameraView = [[SLCameraView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:_cameraView];
    _cameraView.frame = [[UIScreen mainScreen]bounds];
    
    typeof(self) __weak weakself = self;
    _cameraView.delegate = self;
    _cameraView.backToHomeBlock = ^() {
        if ([weakself.cameraView isRecordingExists]) {
            [weakself cleanUpCamera];
            
        } else {
            weakself.hideStatusBar = NO;
            [weakself setNeedsStatusBarAppearanceUpdate];
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    };
    
    [self _createFiltersLisView];
}

- (void)cleanUpCamera {
    __weak typeof(self) _self = self;
    
    [UIAlertController showActionSheetInViewController:self withTitle:nil message:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reshoot" otherButtonTitles:@[@"Exit"] popoverPresentationControllerBlock:^(UIPopoverPresentationController * _Nonnull popover) {
        
    } tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            [_self.cameraView resetRecording];
        }
        else if (buttonIndex == 2) {
            [_self.cameraView releaseCameraResources];
            _self.hideStatusBar = NO;
            [_self setNeedsStatusBarAppearanceUpdate];
            [_self.navigationController popViewControllerAnimated:YES];
        }
        
        
    }];
    return;
   /* [UIAlertController showAlertInViewController:self withTitle:nil message:@"Discard current recording progress ?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        if (buttonIndex>0){
            [_self.cameraView releaseResources];
            _self.hideStatusBar = NO;
            [_self setNeedsStatusBarAppearanceUpdate];
            [_self.navigationController popViewControllerAnimated:YES];
        }
    }];*/
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

- (BOOL)prefersStatusBarHidden {
    
    if ([self isDeviceIsIphoneX]) {
        return NO;
    }
    
    return _hideStatusBar;
}

#pragma mark- SLVideoCameraDelegate
- (void)videoMergingWillStart:(SLCameraView *)cameraView {
    [VideoUtilities showLoadingAt:self.navigationController.view];
}

- (void)videoMergingDidFailed:(SLCameraView *)cameraView {
    [VideoUtilities hideLoadingAt:self.navigationController.view];
}

- (void)deleteLastSegmentClicked:(SLCameraView *)SLCameraView {
    
    [UIAlertController showAlertInViewController:self withTitle:nil message:@"Are you sure you want to delete last segment ?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Confirm"] tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        if (buttonIndex>0){
            [SLCameraView deleteLastRecordedSegment];
        }
    }];
}

/**
 Midea Picker has clicked. Need to open the Picker
 @param SLCameraView - Instance of Camera Class
 */
- (void)mediaPickerDidClicked:(nonnull SLCameraView *)SLCameraView {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes=[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
    imagePicker.allowsEditing = YES;
    imagePicker.navigationBarHidden = NO;
    imagePicker.videoMaximumDuration = self.max_record;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)infoDic {
    
     
    NSURL *videoURL = [infoDic objectForKey:UIImagePickerControllerMediaURL];
    NSURL *videoAsset = [infoDic objectForKey:UIImagePickerControllerReferenceURL];
    NSString *type =  [infoDic objectForKey:UIImagePickerControllerMediaType];
  
    if (videoURL && ![type isEqualToString:@"public.image"]) {
        //CGFloat duration = [SLVideoTool mh_getVideolength:videoURL];
        //NSLog(@"duration: %.2f", duration);
//        if (duration > self.max_record) {
//            [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:[NSString stringWithFormat:@"Please choose video less than %.0ld sec",(long)self.max_record] isSucess:NO];
//        } else {
            [self _processVideoData:videoURL];
        //}
        
        [picker dismissViewControllerAnimated:YES completion:^{
            picker.navigationBarHidden = YES;
        }];
        
    } else if(videoAsset && ![type isEqualToString:@"public.image"]) {
        
        PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[videoAsset] options:nil];
        PHAsset *asset = result.firstObject;
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequestOptions resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                NSURL *originURL = [(AVURLAsset *)asset URL];
                NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[originURL lastPathComponent]];
                NSError *error = nil ;
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                }
                BOOL result =  [[NSFileManager defaultManager] copyItemAtPath:originURL.path toPath:path error:&error];
                if (result) {
                    [self _processVideoData:[NSURL fileURLWithPath:path]];
                    
                } else if (error && error.code == 516) {
                    [self _processVideoData:[NSURL fileURLWithPath:path]];
                }
                else {
                    [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"The video is corrupted, please choose another" isSucess:NO];
                }
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    [picker dismissViewControllerAnimated:YES completion:^{
                        picker.navigationBarHidden = YES;
                    }];
                }];
            }
        }];
        
        
    } else
    {
        //Image Process
        
        __block UIImage *image = (UIImage *) [infoDic objectForKey:UIImagePickerControllerOriginalImage];
        if(!image)
        {
        if (@available(iOS 11.0, *))
        {
            PHAsset * asset = (PHAsset*)[infoDic objectForKey:UIImagePickerControllerPHAsset];
            PHImageManager *manager = [PHImageManager defaultManager];
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            requestOptions.synchronous = true;
            [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^void(UIImage *img, NSDictionary *info) {
               if(img != nil)
               {
                   [self openImagePreview:img];
               }
                [picker dismissViewControllerAnimated:YES completion:^{
                    picker.navigationBarHidden = YES;
                }];

            }];
        }else
        {
            [picker dismissViewControllerAnimated:YES completion:^{
                picker.navigationBarHidden = YES;
            }];
        }
        }else
        {
            if(image != nil)
            {
        [self openImagePreview:image];
            }
        [picker dismissViewControllerAnimated:YES completion:^{
            picker.navigationBarHidden = YES;
        }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Video Processing Completed. Perform the Next Operation
- (void)captureDidCompleted:(UIImage *)image withCameraView:(SLCameraView *)cameraView
{
    [self openImagePreview:image];
    
}
-(void)openImagePreview:(UIImage*)img {
    
}
- (void)recordingDidCompleted:(nonnull NSString *)movePath withCameraView:(nonnull SLCameraView *)cameraView {
    
   [VideoUtilities hideLoadingAt:self.navigationController.view];
    SLEditVideoViewController *editController = [[SLEditVideoViewController alloc]initWithNibName:NSStringFromClass([SLEditVideoViewController class]) bundle:[NSBundle mainBundle]];
    self.postViewModel.captureImage =  nil;
    self.postViewModel.shootFinishMergedVideoPath = movePath;
    self.postViewModel.isGalleryVideo = NO;
    if ([_musicFilePath length]>0 && _musicFilePath) {
        self.postViewModel.havingAudioOnRecording = YES;
        _postViewModel.bgMusicPath = _musicFilePath;
    }

    editController.postViewModel = _postViewModel;
    [self.navigationController pushViewController:editController animated:YES];
}

- (IBAction)backButtonDidClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 Process the Video for uplaod
 @param videoURL -  Video URL
 */
- (void)_processVideoData:(NSURL *)videoURL {

    SLEditVideoViewController *editController = [[SLEditVideoViewController alloc]initWithNibName:NSStringFromClass([SLEditVideoViewController class]) bundle:[NSBundle mainBundle]];

    self.postViewModel.shootFinishMergedVideoPath = videoURL.path;
    self.postViewModel.isGalleryVideo = YES;
    if ([_musicFilePath length]>0 && _musicFilePath) {
        self.postViewModel.havingAudioOnRecording = YES;
        _postViewModel.bgMusicPath = _musicFilePath;
    }

    editController.postViewModel = _postViewModel;
    [self.navigationController pushViewController:editController animated:YES];
}



#pragma mark -  Filters View
- (void)mediaFiltersDidClicked:(nonnull SLCameraView *)SLCameraView {
    [self showFiltersView];
}
/**
 Create the Filters list View
 */

- (void)dissmissButtonDidClicked:(id)sender{
    if (!_transparentButton.hidden) {
        [self hideFiltersView];
    }
}

- (void)_createFiltersLisView {
    
    _transparentButton = [[UIButton alloc]init];
    _transparentButton.backgroundColor = [UIColor clearColor];
    _transparentButton.frame = CGRectMake(0,0, SLSCREEN_WIDTH,SLSCREEN_HEIGHT);
    [_transparentButton addTarget:self action:@selector(dissmissButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.filtersView = [SLFiltersView DivinerayFiltersView];
    [self.cameraView addSubview:_filtersView];
    _filtersView.frame = CGRectMake(0, SLSCREEN_HEIGHT - 140, SLSCREEN_WIDTH, 140);
    [self.cameraView.slFilteredVideoView addSubview:_transparentButton];
    _transparentButton.hidden=YES;
    
    [_filtersView initialiseFiltersResource];
    [_filtersView reloadFilters];
    _filtersView.alpha=0.0;
    __weak typeof(self) _self = self;
    _filtersView.selectedFilter = ^(SLFilterData * _Nonnull filterModel,  NSInteger itemIndex) {
        
        [_self.navigationController.view hideAllToasts];
        [_self.navigationController.view makeToast:filterModel.name
                                         duration:1.5
                                         position:CSToastPositionCenter];
        
        
        [_self.cameraView applyFilters:filterModel];
    };
    
    _filtersView.hideFilters = ^{
        [_self hideFiltersView];
    };
    
    _swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    _swipeLeft.numberOfTouchesRequired=1;
    _swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    self.cameraView.slFilteredVideoView.userInteractionEnabled = YES;
    [self.cameraView.slFilteredVideoView addGestureRecognizer:_swipeLeft];
    
    _swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    _swipeRight.numberOfTouchesRequired=1;
    _swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.cameraView.slFilteredVideoView addGestureRecognizer:_swipeRight];
}

- (void)swipe:(UISwipeGestureRecognizer*)sender
{
    if(!_isSwapEnabel) return;
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft ) {
        if (_filtersView) {
            [_filtersView swapLeftFilterGesture  ];
        }
        
    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight ) {
        if (_filtersView) {
            [_filtersView swapRightFilterGesture];
        }
    }
    
    [self.view bringSubviewToFront:_filtersView];
}

- (void)showFiltersView {
    
    _transparentButton.hidden = NO;
    _filtersView.frame = CGRectMake(0, SLSCREEN_HEIGHT, SLSCREEN_WIDTH, 140);
    _filtersView.alpha = 1.0;
    [_filtersView reloadFilters];
    
    __weak typeof(self) _self = self;
    [UIView animateWithDuration:.50
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _self.filtersView.frame = CGRectMake(0, SLSCREEN_HEIGHT - 140, SLSCREEN_WIDTH, 140);
                     }
                     completion:nil];
    
}

- (void)hideFiltersView {
    
    _transparentButton.hidden = YES;
    _filtersView.frame = CGRectMake(0, SLSCREEN_HEIGHT - 140, SLSCREEN_WIDTH, 140);
    _filtersView.alpha = 1.0;
    [_filtersView reloadFilters];
    
    __weak typeof(self) _self = self;
    [UIView animateWithDuration:.50
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _self.filtersView.frame = CGRectMake(0, SLSCREEN_HEIGHT, SLSCREEN_WIDTH, 140);
                     }
                     completion:nil];
    
}

#pragma mark - Sound Impementation
- (void)soundPickerDidClicked:(SLCameraView *)SLCameraView {
    
    __weak typeof(self) _self = self;
    if (self.musicFilePath  && [self.musicFilePath length] >0) {
        
        [self performMusicChange:^(MusicOpertion operation) {
            if (operation == KMusicOpertionChangeSound) {
                [_self openMusicListController];
                
            } else if (operation == KMusicOpertionRemoveSound) {
                _self.musicFilePath = @"";
                [_self.cameraView updateSoundViewText:@"" withMuisicId:@""];                
            }
        }];
    } else {
        [_self openMusicListController];
    }
}

- (void)openMusicListController {
    
    __weak typeof(self) _self = self;
    self.musicController = [[SLMusicListViewController alloc]initWithNibName:NSStringFromClass([SLMusicListViewController class]) bundle:nil];
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:_musicController];
    self.animator.dragable = NO;
    self.animator.bounces = NO;
    self.animator.behindViewAlpha = 0.5f;
    self.animator.behindViewScale = 0.5f;
    self.animator.transitionDuration = 0.7f;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    _musicController.transitioningDelegate = self.animator;
    _musicController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:_musicController animated:true completion:nil];
    
    
    [_musicController setCompletionBlock:^(NSString * musicPath, NSString * fileName, NSString * muisicId, BOOL isSucess) {
        [_self.musicController dismissViewControllerAnimated:YES completion:^{
            if (isSucess) {
                [_self.cameraView updateSoundViewText:fileName withMuisicId:muisicId];
                [_self.cameraView applySound:musicPath];
                _self.postViewModel.muisicId = muisicId;
                _self.musicFilePath = [NSString stringWithFormat:@"%@",musicPath];
            }
        }];
    }];
}



- (void)performMusicChange:(void(^)(MusicOpertion operation))completionBlock {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Change sound" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionBlock (KMusicOpertionChangeSound);
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove sound" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        completionBlock (KMusicOpertionRemoveSound);
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionBlock (KMusicOpertionNone);
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (void)dealloc {
    if (self.cameraView) {
        [self.cameraView removeFromSuperview];
        self.cameraView =nil;
    }
}
@end
