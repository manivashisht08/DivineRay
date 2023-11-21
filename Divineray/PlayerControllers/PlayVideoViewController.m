//
//  PlayVideoViewController.m
//  Divineray
//
//  Created by Tejas Dattani on 07/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

#import "PlaylistViewController.h"
#import "Divineray-Swift.h"
#import "SLPlayer.h"
#import "SDWebImagePrefetcher.h"
#import <Photos/Photos.h>
#import "SLFIFODownloadManager.h"
#import "SLVODPlaylistViewCell.h"
#import "UICollectionView+SLHelper.h"
#import "SLVideosDataSource.h"
#import "SLCollectionViewFlowLayout.h"
#import "SVProgressHUD.h"
#import "VideoUtilities.h"
#import "UIImage+animatedGIF.h"
#import "CommentViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "UIAlertController+SLBlocks.h"
#import "DivinerayVideoMerger.h"
#import "LiveEventsViewCell.h"
#import "PlayVideoViewController.h"
#import "LiveUsersViewCell.h"
#import <Foundation/Foundation.h>

static NSString *kSLVODPlaylistIdentifier = @"SLVODPlaylistViewCell";

@interface PlayVideoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource, UIGestureRecognizerDelegate,CommentDelagete>{
    
}

@property (strong, nonatomic) UILongPressGestureRecognizer *lpgr;
@property (strong, nonatomic) CommentViewController *commentMenu;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@property (weak, nonatomic) IBOutlet UIImageView *musicImage;
@property (strong,nonatomic) SLPlayer *player;
@property(nonatomic,assign) NSInteger page;
@property(nonatomic,strong) NSMutableArray *dataArray;
@property (strong, nonatomic) SLVideosDataSource *dataSource;
@property (strong, nonatomic) SLCollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) float lastContentOffset;

@end

@implementation PlayVideoViewController

- (void)setupBaseUI {
    
}

- (void)_setBasicUIElements {
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.collectionView configurePlaylistProperties];
    self.collectionView.delegate = self;
    self.flowLayout = [[SLCollectionViewFlowLayout alloc] initVodPlaylistFlowLayout];
    [self.collectionView setCollectionViewLayout:self.flowLayout animated:NO];
    self.collectionView.delegate = self;

    if (@available(iOS 11.0, *)) {
        _iphoneXIssueSolved = YES;
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.collectionView setHidden:false];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    tapGesture1.numberOfTapsRequired = 1;
    [tapGesture1 setDelegate:self];
    
    [self.IBBtnClose setHidden:true];
    self.currentVideoIndex = -1;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    _isUserPause = NO;
    self.musicImage.hidden = true;
    
    [self _setBasicUIElements];
    self.movingDirection = MovingDirectionInit;
    self.dataArray = [[NSMutableArray alloc] init];
    [self createDatSource];
    [self configPlayer];
    [self.musicImage bringSubviewToFront:self.player.view];
    
    [SLFIFODownloadManager sharedManager].maxConcurrentCount = 1;
    [SLFIFODownloadManager sharedManager].waitingQueueMode = SRWaitingQueueModeFIFO;
    
    self.page = 1;
    self.IBBtnClose.hidden = false;
    [self.dataArray removeAllObjects];
    self.clickedItemIndex = 0;
    [self.dataArray addObject:self.videoInfoPlay];
    [self createDatSource];
    [self drawExistingContents];
    [self.IBBtnClose setHidden:false];
    [self loadVideo];
    // Do any additional setup after loading the view from its nib.
}
- (void)drawExistingContents {
    [self downloadItems:self.clickedItemIndex withDirection:_movingDirection];
    [self.collectionView reloadData];
    self.collectionView.alpha = 0.0;
    [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(self.clickedItemIndex) inSection:0] atScrollPosition:(UICollectionViewScrollPositionBottom) animated:YES];
        
    } completion:^(BOOL finished) {
        self.collectionView.alpha = 1.0;
        [self showActivePlaylistVideo];
    }];
}

- (void)updateFrames {
    
    self.collectionView.frame = [[UIScreen mainScreen]bounds];
    self.playerView.frame = [[UIScreen mainScreen]bounds];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateFrames];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateFrames];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
    
    self.isViewVissible = NO;
    [self pauseVideo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeStateChangeObserver];
    self.isViewVissible = NO;
    [self pauseVideo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.isUserPause) {
        [self playVideo];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self addStateChangeObserver];
    self.isViewVissible = YES;
    [self.collectionView reloadData];
    self.navigationController.navigationBar.hidden = YES;
    //Refersh Service
}

#pragma mark -  Action Methods
- (IBAction)IBBtnCloseTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -  State Observer
- (void)onApplicationWillResignActive {
    [self onResignActive];
}

- (void)onApplicationDidBecomeActive {
    [self onBecomeActive];
}

- (void)addStateChangeObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeStateChangeObserver {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        SLVODPlaylistViewCell *playlistCell = (SLVODPlaylistViewCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentVideoIndex inSection:0]];
        if (!playlistCell) {
            [self  pauseVideo];
        }
    }
}

- (void)loadVideo {
    [VideoUtilities hideLoadingAt:self.navigationController.view];
    [self.refreshControl endRefreshing];
    BOOL isDataStart = NO;
    if(self.dataArray.count == 0) {
        isDataStart = YES;
    }
    self.currentVideoIndex = -1;
    if(isDataStart) {
        [self createDatSource];
        [self.collectionView performBatchUpdates:^{}
                                      completion:^(BOOL finished){
            [self showActivePlaylistVideo];
        }];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            // do work here
            [self.collectionView reloadData];
            [self performSelector:@selector(showActivePlaylistVideo) withObject:nil afterDelay:0.3];
        });
    }
    [self performSelector:@selector(hideAnimations) withObject:nil afterDelay:5.0];
    
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DashBoardLiveEventsDataFetch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DashBoardLiveUsersDataFetch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DashBoardDataFetch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LikeDataFetch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoDownloadStatus" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoDownloadPercntage" object:nil];
}
#pragma mark - Downaloading Items functionality
- (void)downloadItems:(NSInteger)nextIndex  withDirection:(MovingDirection)_movingDirection {
    
    if (_movingDirection == MovingDirectionInit) {
        [self predownloadContentsAt:nextIndex withDirection:MovingDirectionInit];
        
    } else if (_movingDirection == MovingDirectionUpSide) {
        [self predownloadContentsAt:nextIndex withDirection:MovingDirectionUpSide];
        
    } else if (_movingDirection == MovingDirectionDownSide) {
        [self predownloadContentsAt:nextIndex withDirection:MovingDirectionDownSide];
    }
}
#pragma mark- Predownlaod Contents for the VOD playlist
- (void)predownloadContentsAt:(NSInteger)nextIndex  withDirection:(MovingDirection)direction {
    
    if (direction == MovingDirectionInit) {
        
        [self _addItemIntoQueue:nextIndex+0];
        [self _addItemIntoQueue:nextIndex+1];
        [self _addItemIntoQueue:nextIndex+2];
        [self _addItemIntoQueue:nextIndex-1];
        
    } else if (direction == MovingDirectionUpSide) {
        
        [self _addItemIntoQueue:nextIndex+1];
        [self _addItemIntoQueue:nextIndex+2];
        [self _addItemIntoQueue:nextIndex+3];
    } else if (direction == MovingDirectionDownSide) {
        
        [self _addItemIntoQueue:nextIndex-1];
        [self _addItemIntoQueue:nextIndex-2];
        [self _addItemIntoQueue:nextIndex-3];
    }
}

- (void)_addItemIntoQueue:(NSInteger)downloadIndex {
    
    if(downloadIndex >=0 && downloadIndex<[self.dataArray count] && [_dataArray count]>0) {
        NSDictionary *dict = [self.dataArray objectAtIndex:downloadIndex];
        if (!dict) {
            return;
        }
        
        NSString *urlString = [dict valueForKey:@"postImage"] ;
        if (urlString) {
            NSURL *imageUrl = [NSURL URLWithString:urlString];
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:@[imageUrl]];
        }
        NSString * playerUrl =  [dict valueForKey:@"postVideo"];
        [self _assignItemToDownloadManager:playerUrl];
        
    }
}
- (void)_assignItemToDownloadManager:(NSString *)urlString {
    if (urlString !=nil && [urlString hasPrefix:@"http"]) {
        [[SLFIFODownloadManager sharedManager]download:[NSURL URLWithString:urlString] destPath:nil state:nil progress:nil completion:nil];
    }
}
- (void)configPlayer {
    
    self.playerView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.view addSubview:self.playerView];
    _playerView.backgroundColor = [UIColor clearColor];
    
    self.player = [SLPlayer player];
    self.player.viewGravityMode = SLGravityModeResizeAspect;
    [self.player registerPlayerNotificationTarget:self stateAction:@selector(stateAction:) progressAction:@selector(progressAction:) playableAction:@selector(playableAction:) errorAction:@selector(errorAction:)];
    
    self.player.view.frame = [[UIScreen mainScreen]bounds];
    [self.playerView addSubview:self.player.view];
    self.player.view.backgroundColor = [UIColor clearColor];
    
    [self.player setViewTapAction:^(SLPlayer * _Nonnull player, SLPLFView * _Nonnull view) {
    }];
}

- (void)errorAction:(id)state {
    NSLog(@"errorAction");
}

- (void)progressAction:(id)state {
    NSLog(@"progressAction");
}

-(void)playableAction:(NSNotification *)notification {
    NSLog(@"progressAction");
    //SLPlayable * playable = [SLPlayable playableFromUserInfo:notification.userInfo];
}


- (void)stateAction:(NSNotification *)notification {
    
    SLState * state = [SLState stateFromUserInfo:notification.userInfo];
    switch (state.current) {
        case SLPlayerStateNone:
            [self performSelector:@selector(showAnimations) withObject:self afterDelay:0.0];
            break;
        case SLPlayerStateBuffering: {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                if(self.player.state ==  SLPlayerStateBuffering) {
                    [self performSelector:@selector(showAnimations) withObject:self afterDelay:0.0];
                }
            });
        }
            break;
        case SLPlayerStateReadyToPlay: {
            [self playerPause:NO];
            //            [self.slikeControlView updatePausePlayer:YES];
            [self hideAnimations];
            // [self.slikeControlView startLogoSpin:YES];
        }
            break;
        case SLPlayerStatePlaying:
            
            [self playerPause:NO];
            //[self.slikeControlView startLogoSpin:YES];
            [self performSelector:@selector(hideAnimations) withObject:self afterDelay:0.2];
            //[self.slikeControlView updatePausePlayer:YES];
            break;
        case SLPlayerStateSuspend:
            if (_isUserPause) {
                [self playerPause:YES];
                //  [self.slikeControlView updatePausePlayer:NO];
                // [self.slikeControlView stopLogoSpin];
            } else {
                [self playerPause:YES];
                // [self.slikeControlView updatePausePlayer:YES];
                // [self.slikeControlView startLogoSpin:YES];
            }
            
            break;
        case SLPlayerStateFinished: {
            [self replay];
        }
            break;
        case SLPlayerStateFailed: {
            [self hideAnimations];
        }
            break;
    }
}
-(void)playerPause:(BOOL)isPaused{
    self.musicImage.hidden = !isPaused;
}
- (void)replay {
    if (_isViewVissible) {
        [self.player seekToTime:0];
        [self.player play];
    } else {
        [self.player pause];
    }
}

- (void)playVideo {
    if (self.player) {
        [self.player play];
    }
}

- (void)pauseVideo {
    if (self.player) {
        [self.player pause];
    }
}

- (void)stopVideo {
    if (self.player) {
        [self.player stop];
    }
}

- (void)togglePlayer {
    SLVODPlaylistViewCell *playlistCell = (SLVODPlaylistViewCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentVideoIndex inSection:0]];
    
    if(self.player.state == SLPlayerStatePlaying) {
        [self.player pause];
        self.isUserPause =  YES;
        self.musicImage.hidden = YES;
        [playlistCell stopLogoSpin];
    }else if(self.player.state == SLPlayerStateSuspend) {
        [self.player play];
        self.isUserPause =  NO;
        self.musicImage.hidden = NO;
        [playlistCell startLogoSpin:YES];
    } else if(self.player.state == SLPlayerStateNone) {
        self.musicImage.hidden = NO;
        [self.player pause];
        self.isUserPause =  YES;
        [playlistCell stopLogoSpin];
    } else {
        self.musicImage.hidden = NO;
    }
}

- (float)playerProgress {
    if (self.player) {
        return self.player.progress;
    }
    return -1;
}

- (void)playVideoForContentURL:(NSURL *)contentURL resizeAspectFill:(BOOL)reSizeFill {
    
    if(reSizeFill) {
        self.player.viewGravityMode = SLGravityModeResizeAspectFill;
    } else {
        self.player.viewGravityMode = SLGravityModeResizeAspect;
    }
    
    [self.player replaceVideoWithURL:contentURL];
    _playerView.frame = [[UIScreen mainScreen]bounds];
    
    if (_isViewVissible) {
        [self.player play];
    } else {
        [self.player pause];
        [self.musicImage setHidden:false];
    }
}

- (void)onResignActive {
    if(self.player.state == SLPlayerStatePlaying) {
        [self.player pause];
        _isUserPause = NO;
    }
}

- (void)onBecomeActive {
    if(self.player.state == SLPlayerStateSuspend && !_isUserPause) {
        [self.player play];
        
    } else if (self.player.state == SLPlayerStateFailed) {
        [self _setNextPageUI:self.currentVideoIndex];
        [self playVideoAtContentURL:self.currentVideoIndex];
    }
    
}

- (void)viewWillBecomeInActive:(BOOL)isActive {
    if (isActive) {
        [self playVideo];
        [self addStateChangeObserver];
    } else {
        [self removeStateChangeObserver];
        [self pauseVideo];
    }
}
#pragma mark -  State Observer
- (void)createDatSource {
    
    [self.collectionView registerCellWithNib:[SLVODPlaylistViewCell class] withReusableId:kSLVODPlaylistIdentifier];
    
    SLVideoViewCellConfigureBlock configureCell = ^(SLVODPlaylistViewCell *cell, NSDictionary* item, NSIndexPath *indexPath) {
        
        cell.backgroundColor =  [UIColor clearColor];
        [cell configurePlaylistCell:item withSims:YES];
        
        if(cell.playerBtn.tag == 0) {
            cell.playerBtn.tag = 11;
            [cell.leftView setHidden:true];
            [cell.titleLbl setHidden:true];
            [cell.audioContainerView setHidden:true];
            [cell.lineImage setHidden:true];
            
            [cell.playerBtn addTarget:self action:@selector(togglePlayer) forControlEvents:UIControlEventTouchUpInside];

            self.lpgr
            = [[UILongPressGestureRecognizer alloc]
               initWithTarget:self action:@selector(handleLongPress:)];
            self->_lpgr.delegate = self;
            [self.collectionView addGestureRecognizer:self->_lpgr];
        }
        cell.likeBtn.tag = indexPath.row;
        cell.musicBtn.tag = indexPath.row;
        
    };

    self.dataSource = [[SLVideosDataSource alloc] initWithItems:
                       self.dataArray cellIdentifier:kSLVODPlaylistIdentifier
                                             configureCellBlock:configureCell];
    
    [self.dataSource setupCollectionViewFooter:kPhotoFooterViewIdentifier];
    [self.dataSource setupCollectionViewHeader:kOfferHeaderViewIdentifier];
    self.collectionView.dataSource = self.dataSource;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lastContentOffset < scrollView.contentOffset.y) {
        self.movingDirection = MovingDirectionUpSide;
    } else if (self.lastContentOffset > scrollView.contentOffset.y) {
        self.movingDirection = MovingDirectionDownSide;
    }
    [self showActivePlaylistVideo];
    [self performSelector:@selector(iScrollUnHide) withObject:nil afterDelay:0.3];
}
- (void)iScrollUnHide{
}
- (void)refreshFeeds {
    
}
- (void)showActivePlaylistVideo {
    
    for(SLVODPlaylistViewCell *visibleCell in [self.collectionView visibleCells]) {
        if([visibleCell isKindOfClass:[SLVODPlaylistViewCell class]]) {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:visibleCell];
            UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
            
            CGRect cellRect = [self.collectionView convertRect:attributes.frame toView:self.view];
            
            CGRect intersect = CGRectIntersection(self.collectionView.frame, cellRect);
            float visibleHeight = CGRectGetHeight(intersect);
            
            if (!_iphoneXIssueSolved) {
                _iphoneXIssueSolved = true;
                visibleHeight = visibleHeight+44;
            }
            
            if(visibleHeight == [UIScreen mainScreen].bounds.size.height) {
                if (self.currentVideoIndex == indexPath.row ) {
                    return;
                }
                //NSLog(@"%ld",(long)self.currentVideoIndex);
                
                self.currentVideoIndex = indexPath.row;
                [self downloadItems:self.currentVideoIndex withDirection:_movingDirection];
                [self _setNextPageUI:self.currentVideoIndex];
                if ([self.playerView superview]) {
                    [self.playerView removeFromSuperview];
                }
                SLVODPlaylistViewCell *distryingCell = (SLVODPlaylistViewCell *)visibleCell;
                [distryingCell updatePlayerView:self.playerView];
                [self playVideoAtContentURL:self.currentVideoIndex];
                //                if(self.dataArray.count > self.currentVideoIndex) {
                //                                  NSLog(@"AAAA");
                //                              [distryingCell configurePlaylistCell:[self.dataArray objectAtIndex:self.currentVideoIndex]];
                //                              }
            }
        }
    }
}

- (void)showAnimations {
    for (SLVODPlaylistViewCell *distryingCell in self.collectionView.visibleCells) {
    }
}

- (void)hideAnimations {
    for (SLVODPlaylistViewCell *distryingCell in self.collectionView.visibleCells) {
    }
}

- (void)playVideoAtContentURL:(NSInteger)itemIndex {
    if(self.dataArray.count >itemIndex) {
        
        NSDictionary* itemDict =  self.dataArray[itemIndex];
        NSURL *contentURL =  [self vodPlayerUrlAtIndex:itemIndex];
        //NSLog(@"contentURL %@",itemDict);
        
        BOOL aspectFill = YES;
        SLVODPlaylistViewCell *playlistCell = (SLVODPlaylistViewCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentVideoIndex inSection:0]];
        
        NSString *width = [itemDict valueForKey:@"postWidth"];
        NSString *height = [itemDict valueForKey:@"postHeight"];
        if(width && height) {
            if([VideoUtilities calculateMode:width withHeight:height] == UIViewContentModeScaleAspectFill) {
                aspectFill = YES;
                
            }else {
                aspectFill = NO;
            }
        }
        [playlistCell configurePlaylistCell:itemDict withSims:YES];
        [self playVideoForContentURL:contentURL resizeAspectFill:aspectFill];
        
    }
}

- (NSURL *)vodPlayerUrlAtIndex:(NSInteger)itemIndex {
    if (itemIndex < [_dataArray count]) {
        NSDictionary* item =  _dataArray[itemIndex];
        NSString * urlString =  @"";
        urlString = [item valueForKey:@"video_link"];
//      urlString = @"https://www.rmp-streaming.com/media/big-buck-bunny-360p.mp4";
        if (urlString && [urlString length]>0) {
            NSURL *contentURL =  [NSURL URLWithString:urlString];
            NSString * fileExists = [[SLFIFODownloadManager sharedManager] fileFullPathOfURL:contentURL];
            if ([[NSFileManager defaultManager]fileExistsAtPath:fileExists]) {
                contentURL = [NSURL fileURLWithPath:fileExists];
                return contentURL;
            }
            return contentURL;
        }
    }
    return nil;
}

- (void)_setNextPageUI:(NSInteger)playlistIndex {
    if (playlistIndex >=[self.dataArray count]) {
        return;
    }
    //    [self.slikeControlView _setNextPageUI:model];
}

- (void) tapGesture: (id)sender {
    [self togglePlayer];
}

-(void)ddd {
    [self pauseVideo];
}

@end


//#import "PlayVideoViewController.h"
//#import "SDWebImagePrefetcher.h"
//#import "VideoUtilities.h"
//#import "UIImageView+WebCache.h"
//#import "UIView+WebCache.h"
//
//@interface PlayVideoViewController ()
//
//@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
//@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
//@property (weak, nonatomic) IBOutlet UIButton *playerBtn;
//
//@end
//
//@implementation PlayVideoViewController
//@synthesize dict;
//
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view from its nib.
//    [self playVideo];
//
//    self.playerBtn.tag = 11;
//    [self.playerBtn addTarget:self action:@selector(togglePlayer) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (IBAction)IBBtncloseTapped:(id)sender {
//    [self dismissViewControllerAnimated:true completion:nil];
//}
//
//- (void)playVideo {
//    if([self.dict valueForKey:@"video_link"] != nil) {
//        [self.posterImage setHidden:true];
//        [self.posterImage sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
//                            placeholderImage:[UIImage imageNamed:@"users"]];
//        self.posterImage.contentMode = UIViewContentModeScaleAspectFill;
//    } else {
//        [self.posterImage sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
//                            placeholderImage:[UIImage imageNamed:@"users"]];
//        self.posterImage.frame =  CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
//        BOOL aspectFill = YES;
//        NSString *width = [dict valueForKey:@"postWidth"];
//        NSString *height = [dict valueForKey:@"postHeight"];
//        if(width && height) {
//            if([VideoUtilities calculateMode:width withHeight:height] == UIViewContentModeScaleAspectFill) {
//                aspectFill = YES;
//            }else {
//                aspectFill = NO;
//            }
//        }
//        if(aspectFill) {
//            self.posterImage.contentMode = UIViewContentModeScaleAspectFill;
//        }
//        else {
//            self.posterImage.contentMode = UIViewContentModeScaleAspectFit;
//        }
//        self.posterImage.backgroundColor = [UIColor clearColor];
//    }
//}
//
//- (void)updatePlayerView:(UIView*)playerContainerView {
//    [_posterImage addSubview:playerContainerView];
//    playerContainerView.frame =  CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
//
//}
//
//
//@end
