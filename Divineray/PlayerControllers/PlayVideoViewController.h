//
//  PlayVideoViewController.h
//  Divineray
//
//  Created by Tejas Dattani on 07/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlayVideoViewController : UIViewController

@property (strong, nonatomic) NSDictionary * dict;

@property (nonatomic, assign) id<PlaylistViewControllerDeleteVideo>delegate;
@property (weak, nonatomic) IBOutlet UIButton *IBBtnClose;
@property(nonatomic,strong) NSDictionary *videoInfoPlay;
@property(nonatomic,strong) NSString *userId;
@property (assign, nonatomic)  NSInteger clickedItemIndex;

@property (assign, nonatomic)  NSInteger currentVideoIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic)  NSInteger viewsIndx;
@property (nonatomic, assign) BOOL isUserPause;
@property (nonatomic, strong) UIView *playerView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
// Player
- (void)configPlayer;
- (void)playVideo;
- (void)pauseVideo;
- (void)stopVideo;
- (void)togglePlayer;
- (float)playerProgress;
- (void)playVideoForContentURL:(NSURL *)contentURL resizeAspectFill:(BOOL)reSizeFill;

- (void)onResignActive;
- (void)onBecomeActive;

- (void)createDatSource;
- (void)setupBaseUI;
@property (nonatomic, assign) BOOL isViewVissible;
@property (assign, nonatomic) BOOL iphoneXIssueSolved;
@property (nonatomic, assign) MovingDirection movingDirection;
@end

NS_ASSUME_NONNULL_END
