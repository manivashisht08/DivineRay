//
//  PlaylistViewController.h
//  Divineray
//
//  Created by     on 24/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLConstants.h"

@protocol PlaylistViewControllerDeleteVideo <NSObject>
- (void)deleteVideoClick:(NSInteger)index;
@end

@interface PlaylistViewController : UIViewController {
    
}
@property (nonatomic, assign) id<PlaylistViewControllerDeleteVideo>delegate;
@property(nonatomic,assign) BOOL isFromUser;
@property(nonatomic,assign) BOOL isFromMoreVideo;
@property(nonatomic,strong) NSMutableArray *oldDataArray;
@property(nonatomic,strong) NSDictionary *videoInfoPlay;
@property(nonatomic,strong) NSString *userId;
@property(nonatomic,assign) BOOL myProfile;
@property(nonatomic,strong) NSString *tagString;
@property (assign, nonatomic)  NSInteger clickedItemIndex;

@property (assign, nonatomic)  NSInteger currentVideoIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewLiveEvents;
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

