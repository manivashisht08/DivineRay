//
//  PlaylistViewController.m
//  Divineray
//
//  Created by     on 24/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
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
static NSString *kSLiveEventsViewIdentifier = @"LiveEventsViewCell";
static NSString *kSLiveUsersViewIdentifier = @"LiveUsersViewCell";

@interface PlaylistViewController ()<UICollectionViewDelegate,UICollectionViewDataSource, UIGestureRecognizerDelegate,CommentDelagete, MiddtatorVCProtocol>{
    
}
@property (weak, nonatomic) IBOutlet UIButton *IBBtnForYou;
@property (weak, nonatomic) IBOutlet UIButton *IBBtnLiveEvents;
@property (weak, nonatomic) IBOutlet UIButton *IBBtnLiveStream;
@property (weak, nonatomic) IBOutlet UIImageView *IBImgVwSeparator;
@property (strong, nonatomic) UILongPressGestureRecognizer *lpgr;
@property (strong, nonatomic) CommentViewController *commentMenu;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImg;
@property (weak, nonatomic) IBOutlet UIImageView *musicImage;
@property (strong,nonatomic) SLPlayer *player;
@property(nonatomic,assign) NSInteger page;
@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,strong) NSMutableArray *liveUsersArray;
@property(nonatomic,strong) NSMutableArray *liveEventsArray;
@property (strong, nonatomic) SLVideosDataSource *dataSource;
@property (strong, nonatomic) SLCollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) float lastContentOffset;
@property (weak, nonatomic) IBOutlet UIStackView *IBStackVwTop;

@end

@implementation PlaylistViewController

- (void)setupBaseUI {
    
}

- (UICollectionViewFlowLayout *)initwitFlowLayout {
    UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLiveEvents.collectionViewLayout;
    flowLayout.itemSize = UIScreen.mainScreen.bounds.size;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    return flowLayout;
}

- (void)_setBasicUIElements {
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.collectionView configurePlaylistProperties];
    self.collectionView.delegate = self;
    self.flowLayout = [[SLCollectionViewFlowLayout alloc] initVodPlaylistFlowLayout];
    [self.collectionView setCollectionViewLayout:self.flowLayout animated:NO];
    [self.collectionViewLiveEvents setCollectionViewLayout:[self initwitFlowLayout] animated:NO];
    
    self.collectionView.delegate = self;
    
    
    self.collectionViewLiveEvents.delegate = self;
    self.collectionViewLiveEvents.dataSource = self;
    if (@available(iOS 11.0, *)) {
        _iphoneXIssueSolved = YES;
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.IBBtnForYou setSelected:true];
    [self.IBBtnLiveEvents setSelected:false];
    
    [self.collectionView setHidden:false];
    [self.collectionViewLiveEvents setHidden:true];
    
    [self.IBBtnForYou setBackgroundColor:UIColor.clearColor];
    [self.IBBtnLiveEvents setBackgroundColor:UIColor.clearColor];
    
    [self.IBBtnForYou setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.IBBtnForYou setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    [self.IBBtnLiveEvents setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.IBBtnLiveEvents setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    [self.IBImgVwSeparator setBackgroundColor:UIColor.whiteColor];
    
    [self.IBBtnLiveStream setHidden:true];
    [self.IBBtnLiveStream setTintColor:[UIColor whiteColor]];
    [self.IBBtnLiveStream.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.collectionViewLiveEvents registerNib:[UINib nibWithNibName:NSStringFromClass([LiveEventsViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kSLiveEventsViewIdentifier];
    
    [self.collectionViewLiveEvents registerNib:[UINib nibWithNibName:NSStringFromClass([LiveUsersViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kSLiveUsersViewIdentifier];
    
    self.collectionViewLiveEvents.backgroundColor = [UIColor whiteColor];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.isFromMoreVideo) {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
    self.loadingImg.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    }
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    tapGesture1.numberOfTapsRequired = 1;
    
    [tapGesture1 setDelegate:self];
    
    
    self.currentVideoIndex = -1;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    _isUserPause = NO;
    self.musicImage.hidden = true;
    
    [self _setBasicUIElements];
    self.movingDirection = MovingDirectionInit;
    self.dataArray = [[NSMutableArray alloc] init];
    self.liveEventsArray = [[NSMutableArray alloc] init];
    self.liveUsersArray = [[NSMutableArray alloc] init];
    [self createDatSource];
    if(!self.isFromUser && !self.isFromMoreVideo) {
        [self _addPullToRefresh];
    }
    [self configPlayer];
    [self.musicImage bringSubviewToFront:self.player.view];
    //[self playerPause:NO];
    
    [SLFIFODownloadManager sharedManager].maxConcurrentCount = 1;
    [SLFIFODownloadManager sharedManager].waitingQueueMode = SRWaitingQueueModeFIFO;
    
    self.page = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDataNotification:)
                                                 name:@"DashBoardDataFetch"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLiveEventsDataNotification:)
                                                 name:@"DashBoardLiveEventsDataFetch"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLiveUsersDataNotification:)
                                                 name:@"DashBoardLiveUsersDataFetch"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUploadNotificationRefesh:)
                                                 name:@"VideoRefershCall"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector: @selector(reloadStreamUsers:)
                                                     name:@"RefreshLiveUsersListing" object:nil];
    

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
- (void)receiveUploadNotificationRefesh:(NSNotification *) notification{
    if(!self.isFromUser && !_isFromMoreVideo) {
        [self refreshFeeds];
    }
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
    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name: @"RefreshLiveUsersListing" object:nil];
    
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
    if (self.collectionView.isHidden == false) {
        [self.collectionView reloadData];
    }
    self.navigationController.navigationBar.hidden = YES;
    if(self.isFromMoreVideo) {
        self.loadingImg.hidden = NO;
        self.closeBtn.hidden = NO;
        [self.dataArray removeAllObjects];
        self.clickedItemIndex = 0;
        [self.dataArray addObject:self.videoInfoPlay];
        [self createDatSource];
        [self drawExistingContents];
        [self.IBStackVwTop setHidden:true];
    }
    else if(self.isFromUser) {
        self.loadingImg.hidden = NO;
        self.closeBtn.hidden = NO;
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:self.oldDataArray];
        [self createDatSource];
        [self drawExistingContents];
        [self.IBStackVwTop setHidden:true];
    }else {
        self.loadingImg.hidden = NO;
        self.closeBtn.hidden = YES;
        [self.IBStackVwTop setHidden:false];
        [self getServiceResponce:YES];
    }
    //Refersh Service
    
}

#pragma mark -  Action Methods
- (IBAction)IBBtnForYouTapped:(UIButton *)sender {
    [self.collectionView setHidden:false];
    [self.collectionViewLiveEvents setHidden:true];
    
    [self.IBBtnForYou setSelected:true];
    [self.IBBtnLiveEvents setSelected:false];
    [self getServiceResponce:YES];
    
    [self.IBBtnForYou setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.IBBtnForYou setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    [self.IBBtnLiveEvents setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.IBBtnLiveEvents setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    [self.IBImgVwSeparator setBackgroundColor:UIColor.whiteColor];
    [self.view setBackgroundColor:UIColor.blackColor];
    [self.IBBtnLiveStream setHidden:true];
}

- (IBAction)IBBtnLiveEventsTapped:(UIButton *)sender {
    [self.collectionView setHidden:true];
    [self.collectionViewLiveEvents setHidden:false];
    [self.IBBtnForYou setSelected:false];
    [self.IBBtnLiveEvents setSelected:true];
    [self getServiceResponce:YES];
//    [self.collectionViewLiveEvents reloadData];
    
    [self.IBBtnForYou setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.IBBtnForYou setTitleColor:UIColor.blackColor forState:UIControlStateSelected];
    
    [self.IBBtnLiveEvents setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.IBBtnLiveEvents setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    [self.IBImgVwSeparator setBackgroundColor:UIColor.blackColor];
    [self.view setBackgroundColor:UIColor.whiteColor];
    [self.IBBtnLiveStream setHidden:false];
    [self.player pause];
}

- (IBAction)IBBtnLiveStreamTapped:(UIButton *)sender {
//    GoLiveViewController * vc = [[GoLiveViewController alloc]
//                                  initWithNibName:@"GoLiveViewController" bundle:nil];
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:vc animated:YES completion:nil];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GoLiveViewController *vc = [sb instantiateViewControllerWithIdentifier:@"GoLiveViewController"];
    [self.navigationController.interactivePopGestureRecognizer setEnabled: false];
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)reloadStreamUsers:(NSNotification *)note {
    NSLog(@"Received Notification - Someone seems to have logged in");
    
    [self getServiceResponce: false];
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    if (collectionView == self.collectionViewLiveEvents) {
        return 2;
//        if (self.liveEventsArray.count > 0 && self.liveUsersArray.count > 0 ) {
//            return 2;
//        } else {
//            return 1;
//        }
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.collectionView) {
        return _dataArray.count;
    } else {
        if (section == 0) {
            return self.liveUsersArray.count;
        } else {
            return self.liveEventsArray.count;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LiveUsersViewCell* cell = (LiveUsersViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"LiveUsersViewCell" forIndexPath:indexPath];
        NSDictionary* dict =  self.liveUsersArray[indexPath.row];
        [cell configureLiveUserlistCell:dict];
        return cell;
    } else {
        LiveEventsViewCell* cell = (LiveEventsViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"LiveEventsViewCell" forIndexPath:indexPath];
        NSDictionary* dict =  self.liveEventsArray[indexPath.row];
        [cell configureLiveEventlistCell:dict];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        SLVODPlaylistViewCell *playlistCell = (SLVODPlaylistViewCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentVideoIndex inSection:0]];
        if (!playlistCell) {
            [self  pauseVideo];
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionViewLiveEvents) {
//        return CGSizeMake(collectionView.frame.size.width, 240);
        return CGSizeMake(collectionView.frame.size.width, 270);
    } else {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        NSDictionary * dict = [self.liveUsersArray objectAtIndex:indexPath.row];
        
//        LiveStreamingViewController * viewController = [[LiveStreamingViewController alloc] initWithNibName: @"LiveStreamingViewController" bundle: nil];
        
        
        LiveStreamingViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LiveStreamingViewController"];
        
        
        [viewController setViewData: dict];
        
        [[self navigationController] pushViewController: viewController animated:true];
    } else {
        NSDictionary * dict = [self.liveEventsArray objectAtIndex:indexPath.row];
        PlayVideoViewController * vc = [[PlayVideoViewController alloc]
                                      initWithNibName:@"PlayVideoViewController" bundle:nil];
        vc.videoInfoPlay = dict;
    //    PlaylistViewController * vc = [[PlaylistViewController alloc]
    //                                  initWithNibName:@"PlaylistViewController" bundle:nil];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(void)getServiceResponce:(BOOL)isLoader {
    if(isLoader) {
        self.loadingImg.hidden = NO;
        self.view.userInteractionEnabled = false;
        // [VideoUtilities showLoadingAt:self.navigationController.view];
    }
    
    if (self.IBBtnForYou.isSelected == true) {
        MiddtatorVC *obj = [MiddtatorVC new];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
        [dict setValue:@"100000" forKey:@"perPage"];
        NSString *lastId = @"0";
        //    if(self.dataArray.count>0) {
        //        NSDictionary *dict = [self.dataArray lastObject];
        //        if(dict && [dict valueForKey:@"videoId"]) {
        //            lastId = [dict valueForKey:@"videoId"];
        //        }
        //    }
        [dict setValue:lastId forKey:@"lastId"];
        obj.postData = dict;
        [obj getHomeDashboard];
    } else {
        MiddtatorVC *obj = [MiddtatorVC new];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page_no"];
        [dict setValue:@"100000" forKey:@"per_page"];
        obj.postData = dict;
        obj.middtatorVCDelegate = self;
        [obj getHomeDashboardLiveEvents];
        [obj getLiveUsers];
        [obj setUpDispatchGroup];
    }
}

- (void)getLiveEventsAndLiveUsersWithJsonLiveEvents:(id)jsonLiveEvents dictLiveEventsFail:(NSDictionary<NSString *,NSString *> *)dictLiveEventsFail isSuccessLiveEvents:(BOOL)isSuccessLiveEvents jsonLiveUsers:(id)jsonLiveUsers isSuccessLiveUsers:(BOOL)isSuccessLiveUsers dictLiveUsersFail:(NSDictionary<NSString *,NSString *> *)dictLiveUsersFail {
    NSDictionary *dictLiveEvents = (NSDictionary*)jsonLiveEvents;
    NSDictionary *dictLiveUsers = (NSDictionary*)jsonLiveUsers;
    
    NSLog(@"dictLiveEvents \n%@",dictLiveEvents);
    NSLog(@"dictLiveUsers \n%@",dictLiveUsers);
    
    if (isSuccessLiveEvents == false && isSuccessLiveUsers == false) {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went wrong, please try again" isSucess:NO];
    } else {
        if(dictLiveEvents && [dictLiveEvents valueForKey:@"data"] && [[dictLiveEvents valueForKey:@"data"] isKindOfClass:[NSArray class]]) {
            [self.liveEventsArray removeAllObjects];
            [self.liveEventsArray addObjectsFromArray: [dictLiveEvents valueForKey:@"data"]];
        }
        if(dictLiveUsers && [dictLiveUsers valueForKey:@"data"] && [[dictLiveUsers valueForKey:@"data"] isKindOfClass:[NSArray class]]) {
            [self.liveUsersArray removeAllObjects];
            [self.liveUsersArray addObjectsFromArray: [dictLiveUsers valueForKey:@"data"]];
        }
        if ([[dictLiveUsers valueForKey:@"message"]  isEqual: @"No user found"]) {
            [self.liveUsersArray removeAllObjects];
        }
        self.view.userInteractionEnabled = true;
        self.loadingImg.hidden = YES;
        [self.collectionViewLiveEvents reloadData];
        
    }
}

- (void)receiveDataNotification:(NSNotification *) notification{
    NSDictionary *dict = (NSDictionary*)notification.object;
    //NSLog(@"%@",dict);
    [VideoUtilities hideLoadingAt:self.navigationController.view];
    [self.refreshControl endRefreshing];
    if(dict && [dict valueForKey:@"error"] && [[dict valueForKey:@"error"] isKindOfClass:[NSString class]]) {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went wrong, please try again" isSucess:NO];
        
        //self.loadingImg.hidden = YES;
    }
    BOOL isDataStart = NO;
    if(self.dataArray.count == 0) {
        isDataStart = YES;
    }
    if(dict && [dict valueForKey:@"data"] && [[dict valueForKey:@"data"] isKindOfClass:[NSArray class]]) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:[dict valueForKey:@"data"]];
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

- (void)receiveLiveEventsDataNotification:(NSNotification *) notification{
    NSDictionary *dict = (NSDictionary*)notification.object;
    //NSLog(@"%@",dict);
    [VideoUtilities hideLoadingAt:self.navigationController.view];
    [self.refreshControl endRefreshing];
    if(dict && [dict valueForKey:@"error"] && [[dict valueForKey:@"error"] isKindOfClass:[NSString class]]) {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went wrong, please try again" isSucess:NO];
        
        //self.loadingImg.hidden = YES;
    }
    BOOL isDataStart = NO;
    if(self.liveEventsArray.count == 0) {
        isDataStart = YES;
    }
    if(dict && [dict valueForKey:@"data"] && [[dict valueForKey:@"data"] isKindOfClass:[NSArray class]]) {
        [self.liveEventsArray removeAllObjects];
        [self.liveEventsArray addObjectsFromArray:[dict valueForKey:@"data"]];
    }
    
    [self.collectionViewLiveEvents reloadData];
//    self.currentVideoIndex = -1;
//
//    if(isDataStart) {
//        [self createDatSource];
//        [self.collectionView performBatchUpdates:^{}
//                                      completion:^(BOOL finished){
//            [self showActivePlaylistVideo];
//        }];
//    }else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // do work here
//            [self.collectionView reloadData];
//            [self performSelector:@selector(showActivePlaylistVideo) withObject:nil afterDelay:0.3];
//        });
//    }
    [self performSelector:@selector(hideAnimations) withObject:nil afterDelay:5.0];
    
    
}

- (void)receiveLiveUsersDataNotification:(NSNotification *) notification{
    NSDictionary *dict = (NSDictionary*)notification.object;
    NSLog(@"%@",dict);
    [VideoUtilities hideLoadingAt:self.navigationController.view];
    [self.refreshControl endRefreshing];
    if(dict && [dict valueForKey:@"error"] && [[dict valueForKey:@"error"] isKindOfClass:[NSString class]]) {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went wrong, please try again" isSucess:NO];
        
        //self.loadingImg.hidden = YES;
    }
    [self performSelector:@selector(hideAnimations) withObject:nil afterDelay:5.0];
    
    
}

- (void)receiveLikeDataNotification:(NSNotification *) notification{
    [VideoUtilities hideLoadingAt:self.navigationController.view];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LikeDataFetch" object:nil];
    if(notification.object && [notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)notification.object;
        if([dict valueForKey:@"status"] && [[dict valueForKey:@"status"] intValue]  == 1) {
            NSInteger indexCall = [[dict valueForKey:@"indexCall"] integerValue];
            if(_dataArray.count > indexCall && [[dict valueForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                [_dataArray replaceObjectAtIndex:indexCall withObject:[dict valueForKey:@"data"]];
                if(self.currentVideoIndex == indexCall) {
                    SLVODPlaylistViewCell *playlistCell = (SLVODPlaylistViewCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexCall inSection:0]];
                    [playlistCell configurePlaylistCell:[dict valueForKey:@"data"] withSims:NO];
                }
            }
        }
        
    }
    
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
}
- (void)progressAction:(id)state {
}
-(void)playableAction:(NSNotification *)notification {
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
        if (self.collectionView.isHidden == false) {
            [self.player play];
        } else {
            [self.player pause];
        }
    } else {
        [self.player pause];
    }
}

- (void)playVideo {
    if (self.player) {
        if (self.collectionView.isHidden == false) {
            [self.player play];
        } else {
            [self.player pause];
        }
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
        if (self.collectionView.isHidden == false) {
            [self.player play];
        } else {
            [self.player pause];
        }
        self.isUserPause =  NO;
        self.musicImage.hidden = NO;
        [playlistCell startLogoSpin:YES];
    }
}
- (void)likeAction :(SYFavoriteButton*)btn {
    NSString *isLiked = @"";
    if(btn.selected) {
        isLiked = @"0";
    }else {
        isLiked = @"1";
    }
    [self likeViewActionAction:isLiked withiView:NO];
    //    btn.selected = !btn.selected;
    
}
- (void)musicAction :(UIButton*)btn {
    if(self.dataArray.count > btn.tag) {
        NSDictionary* dict =  self.dataArray[btn.tag];
        if([dict valueForKey:@"musicId"] && ![[dict valueForKey:@"musicId"] isEqualToString:@""]  && [[dict valueForKey:@"musicName"] isKindOfClass:[NSString class]] && ![[dict valueForKey:@"musicName"] isEqualToString:@""]) {
            [self musicViewCall:[dict valueForKey:@"musicName"] withMusicId:[dict valueForKey:@"musicId"]];
        }else {
            [self userProfileTapGesture:nil];
        }
        
    }
}
- (void)likeViewActionAction :(NSString *)isLiked withiView:(BOOL)isView{
    
    self.viewsIndx = self.currentVideoIndex;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLikeDataNotification:)
                                                 name:@"LikeDataFetch"
                                               object:nil];
    MiddtatorVC *obj = [MiddtatorVC new];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(isView) {
        [dict setValue:@"1" forKey:@"isView"];
    }else {
        [VideoUtilities showLoadingAt:self.navigationController.view];
        [dict setValue:isLiked forKey:@"isLiked"];
    }
    NSDictionary* item =  _dataArray[self.currentVideoIndex];
    [dict setValue:[item valueForKey:@"videoId"] forKey:@"videoId"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)self.currentVideoIndex] forKey:@"indexCall"];
    
    obj.postData = dict;
    
    [obj getLikeService];
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
        if (self.collectionView.isHidden == false) {
        [self.player play];
        } else {
            [self.player pause];
        }
    } else {
        [self.player pause];
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
        if (self.collectionView.isHidden == false) {
            [self.player play];
        } else {
            [self.player pause];
        }
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
        cell.flagBtn.tag = indexPath.row;
        [cell.flagBtn addTarget:self action:@selector(functionName:) forControlEvents:UIControlEventTouchUpInside];
        cell.titleLbl.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
            [self tagViewCall:string];
        };
        if(cell.playerBtn.tag == 0) {
            if(self.isFromUser) {
                cell.lineImage.hidden = NO;
            }
            if(self.isFromMoreVideo) {
                cell.lineImage.hidden = NO;
            }
            cell.playerBtn.tag = 11;
            
            
            [cell.playerBtn addTarget:self action:@selector(togglePlayer) forControlEvents:UIControlEventTouchUpInside];
            if(self.isFromMoreVideo) {
                //do nothing
            }else  {
                [cell.shareBtn addTarget:self action:@selector(shareActionCall) forControlEvents:UIControlEventTouchUpInside];
                
                self.lpgr
                = [[UILongPressGestureRecognizer alloc]
                   initWithTarget:self action:@selector(handleLongPress:)];
                self->_lpgr.delegate = self;
                [self.collectionView addGestureRecognizer:self->_lpgr];
                
                [cell.likeBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.musicBtn addTarget:self action:@selector(musicAction:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.commentBtn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.profileImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *profiletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(userProfileTapGesture:)];
                profiletapGesture.numberOfTapsRequired = 1;
                [profiletapGesture setDelegate:self];
                [cell.profileImageView addGestureRecognizer:profiletapGesture];
            }
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

- (void) functionName:(UIButton *) sender {
    NSString* videoId =  self.dataArray[sender.tag][@"videoId"];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReportUserOptionVC *reportUserOptionVC = [sb instantiateViewControllerWithIdentifier:@"ReportUserOptionVC"];
    reportUserOptionVC.title = videoId;
    [self presentViewController:reportUserOptionVC animated:YES completion:nil];


}



- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        return;
    }
    
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        [self actionSheetForMoreOption];
    }
}
-(void)actionSheetForMoreOption {
    if(_dataArray.count > self.currentVideoIndex) {
        BOOL isMyVideo = NO;
        NSDictionary * dict = [self.dataArray objectAtIndex:self.currentVideoIndex];
        
        NSString *userId = @"";
        NSDictionary * userDetails = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_details"];
        if(userDetails) {
            userId =  [userDetails valueForKey:@"user_id"];
        }
        if([userId isEqualToString:[dict valueForKey:@"user_id"]]) {
            isMyVideo = YES;
        }
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"" message: @"" preferredStyle: UIAlertControllerStyleActionSheet];
        
        [alert addAction: [UIAlertAction actionWithTitle: @"Download video"
                                                   style: UIAlertActionStyleDefault
                                                 handler: ^(UIAlertAction * _Nonnull action)
                           {
            [self downloadVideo];
            
        }]
         ];
        if(self.myProfile) {
            [alert addAction: [UIAlertAction actionWithTitle: @"Delete"
                                                       style: UIAlertActionStyleDestructive
                                                     handler: ^(UIAlertAction * _Nonnull action)
                               {
                [self deleteVideo];
            }]
             ];
        }else {
            [alert addAction: [UIAlertAction actionWithTitle: @"Report Abuse"
                                                       style: UIAlertActionStyleDefault
                                                     handler: ^(UIAlertAction * _Nonnull action)
                               {
                [self openReportAbuse];
            }]
             ];
        }
        
        [alert addAction: [UIAlertAction actionWithTitle: @"Cancel"
                                                   style: UIAlertActionStyleDefault
                                                 handler: ^(UIAlertAction * _Nonnull action)
                           {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]
         ];
        
        [self presentViewController: alert
                           animated: true
                         completion: ^{
        }];
    }
    
}
-(void)deleteVideo {
    [UIAlertController showAlertInViewController:self withTitle:nil message:@"Are you sure you want to delete?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Confirm"] tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        if (buttonIndex>0){
            [self deleteUserVideoService];
        }
    }];
}
-(void)deleteUserVideoService {
    if(self.dataArray.count >self.currentVideoIndex) {
        [VideoUtilities showLoadingAt:self.navigationController.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveDeleteDataNotification:)
                                                     name:@"DeleteVideoNotifiction"
                                                   object:nil];
        NSDictionary* itemDict =  self.dataArray[self.currentVideoIndex];
        MiddtatorVC *obj = [MiddtatorVC new];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[itemDict valueForKey:@"videoId"] forKey:@"videoId"];
        obj.postData = dict;
        [obj deleteVideoForUser];
    }
}
- (void)receiveDeleteDataNotification:(NSNotification *) notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteVideoNotifiction" object:nil];
    
    NSDictionary *dict = (NSDictionary*)notification.object;
    // NSLog(@"%@",dict);
    [VideoUtilities hideLoadingAt:self.navigationController.view];
    [self.refreshControl endRefreshing];
    if(dict && [dict valueForKey:@"error"] && [[dict valueForKey:@"error"] isKindOfClass:[NSString class]]) {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went wrong, please try again" isSucess:NO];
        return;
        //self.loadingImg.hidden = YES;
    }
    if(notification.object && [notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)notification.object;
        if([dict valueForKey:@"status"] && [[dict valueForKey:@"status"] intValue]  == 1) {
            //        [[NSNotificationCenter defaultCenter]
            //        postNotificationName:@"VideoRefershCall"
            //        object:nil];
            [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:[dict valueForKey:@"message"] isSucess:YES];
            [self.dataArray removeObjectAtIndex:self.currentVideoIndex];
            if(self.delegate && [self.delegate conformsToProtocol:@protocol(PlaylistViewControllerDeleteVideo)]) {
                [self.delegate deleteVideoClick:self.currentVideoIndex];
            }
            if(self.currentVideoIndex == 0) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            [self downloadItems:0 withDirection:_movingDirection];
            [self.collectionView reloadData];
            self.collectionView.alpha = 0.0;
            [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(0) inSection:0] atScrollPosition:(UICollectionViewScrollPositionBottom) animated:YES];
                
            } completion:^(BOOL finished) {
                self.collectionView.alpha = 1.0;
                [self showActivePlaylistVideo];
            }];    }
    }
}
-(void)downloadVideo {
    [self downoadMediaAtIndex:self.currentVideoIndex containerView:self.tabBarController.view];
}
- (void)downoadMediaAtIndex:(NSInteger)videoIndex containerView:(UIView *)container {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
            
            //No permission. Trying to normally request it
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Divineray" message:@"For permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                        [alertController addAction:cancelAction];
                        
                        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }];
                        [alertController addAction:settingsAction];
                        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                    });
                }else   if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self downloadSelectedVideo:container videoIndex:videoIndex];
                    });
                }
            }];
            
        } else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self downloadSelectedVideo:container videoIndex:videoIndex];
                    });
                }
            }];
        }
    });
}
-(void)openReportAbuse {
    if(self.dataArray.count >self.currentVideoIndex) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ReportAbuseVC *reportAbuserVC = [sb instantiateViewControllerWithIdentifier:@"ReportAbuseVC"];
        NSDictionary* itemDict =  self.dataArray[self.currentVideoIndex];
        reportAbuserVC.reportId =  [itemDict valueForKey:@"videoId"];
        [self.navigationController pushViewController:reportAbuserVC animated:YES];
    }
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
    [self getServiceResponce:NO];
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

- (void)showAnimations {;
    self.view.userInteractionEnabled = false;
    for (SLVODPlaylistViewCell *distryingCell in self.collectionView.visibleCells) {
    }
}

- (void)hideAnimations {
    self.view.userInteractionEnabled = true;
    self.loadingImg.hidden = YES;
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
        if(_isFromMoreVideo) {
            aspectFill = YES;
        }else  {
            NSString *width = [itemDict valueForKey:@"postWidth"];
            NSString *height = [itemDict valueForKey:@"postHeight"];
            if(width && height) {
                if([VideoUtilities calculateMode:width withHeight:height] == UIViewContentModeScaleAspectFill) {
                    aspectFill = YES;
                    
                }else {
                    aspectFill = NO;
                }
            }
        }
        [playlistCell configurePlaylistCell:itemDict withSims:YES];
        if(!_isFromMoreVideo) {
            [self likeViewActionAction:@"" withiView:YES];
        }
        [self playVideoForContentURL:contentURL resizeAspectFill:aspectFill];
        
    }
}
- (NSURL *)vodPlayerUrlAtIndex:(NSInteger)itemIndex {
    
    if (itemIndex < [_dataArray count]) {
        NSDictionary* item =  _dataArray[itemIndex];
        NSString * urlString =  @"";
        
        if(_isFromMoreVideo) {
            urlString = [item valueForKey:@"media"];
        }else  {
            urlString = [item valueForKey:@"postVideo"];
        }
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

/**
 Add pull to refresh Functionality
 */
- (void)_addPullToRefresh {
    
    [self.refreshControl addTarget:self action:@selector(refreshFeeds) forControlEvents:UIControlEventValueChanged];
    if (@available(iOS 10.0, *)) {
        self.collectionView.refreshControl = self.refreshControl;
    } else {
        [self.collectionView addSubview:self.refreshControl];
    }
    
}

- (void) tapGesture: (id)sender {
    [self togglePlayer];
}
#pragma markComment Action
- (void)commentAction:(id)sender {
    self.commentMenu = [[CommentViewController alloc]initWithNibName:NSStringFromClass([CommentViewController class]) bundle:[NSBundle mainBundle]];
    self.commentMenu.dict = self.dataArray[self.currentVideoIndex];
    self.commentMenu.delegate = self;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:_commentMenu];
    self.animator.dragable = NO;
    self.animator.bounces = NO;
    self.animator.behindViewAlpha = 1.0f;
    self.animator.behindViewScale = 1.0f;
    self.animator.transitionDuration = 0.7f;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    _commentMenu.transitioningDelegate = self.animator;
    _commentMenu.modalPresentationStyle = UIModalPresentationCurrentContext;
    _commentMenu.view.backgroundColor = [UIColor clearColor];
    _commentMenu.providesPresentationContextTransitionStyle = YES;
    _commentMenu.definesPresentationContext = YES;
    [_commentMenu setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self.player pause];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_commentMenu animated:true completion:nil];
    __weak typeof(self) _self = self;
    [_commentMenu setCompletionBlock:^(BOOL isSucess) {
        [_self.commentMenu dismissViewControllerAnimated:YES completion:^{
            _self.commentMenu  = nil;
            if(!_self.isUserPause) [_self.player play];
        }];
    }];
}
- (void)updateCommentCount:(NSString*)comments {
    if(_dataArray.count > self.currentVideoIndex) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:[self.dataArray objectAtIndex:self.currentVideoIndex]];
        [dict setValue:comments forKey:@"totalComments"];
        [_dataArray replaceObjectAtIndex:self.currentVideoIndex withObject:dict];
        SLVODPlaylistViewCell *playlistCell = (SLVODPlaylistViewCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentVideoIndex inSection:0]];
        [playlistCell configurePlaylistCell:dict withSims:NO];
    }
}
- (void)openProfileCall:(NSDictionary*)userInfo{
    [self performSelector:@selector(ddd) withObject:nil afterDelay:1.0];
    NSString *userId = @"";
    NSDictionary * userDetails = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_details"];
    if(userDetails) {
        userId =  [userDetails valueForKey:@"user_id"];
    }
    if([userId isEqualToString:[userInfo valueForKey:@"user_id"]]) {
        self.tabBarController.selectedIndex = 4 ;
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *profileObject = [sb instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileObject.userData = userInfo;
    [self.navigationController pushViewController:profileObject animated:YES];

}
-(void)ddd {
    [self pauseVideo];
}
- (void)userProfileTapGesture:(id)sender {
    NSDictionary * dict = [self.dataArray objectAtIndex:self.currentVideoIndex];
    
    NSString *userId = @"";
    NSDictionary * userDetails = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_details"];
    if(userDetails) {
        userId =  [userDetails valueForKey:@"user_id"];
    }
    if([userId isEqualToString:[dict valueForKey:@"user_id"]]) {
        self.tabBarController.selectedIndex = 4 ;
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *profileObject = [sb instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileObject.userData = [dict valueForKey:@"userDetails"];
    [self.navigationController pushViewController:profileObject animated:YES];
    
}

- (IBAction)closeAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)tagViewCall:(NSString*)tagString {
    TagListViewController *tagListObject = [[TagListViewController alloc] initWithNibName:@"TagListViewController" bundle:nil];
    tagListObject.tagString = tagString;
    [self.navigationController pushViewController:tagListObject animated:YES];
}
-(void)musicViewCall:(NSString*)musicName withMusicId:(NSString*)musicId {
    TagListViewController *tagListObject = [[TagListViewController alloc] initWithNibName:@"TagListViewController" bundle:nil];
    tagListObject.musicName = musicName;
    tagListObject.musicId = musicId;
    [self.navigationController pushViewController:tagListObject animated:YES];
}
- (void)shareActionCall {
    [self removeStateChangeObserver];
    [self onApplicationWillResignActive];
    __weak typeof(self) _self = self;
    NSDictionary *dict =   self.dataArray[self.currentVideoIndex];
    NSURL *playerUrl =  [NSURL URLWithString:[dict valueForKey:@"shareUrl"]];
    [self showShareActivity:playerUrl completionBlock:^(BOOL status) {
        if (status) {
            [_self addStateChangeObserver];
            [_self onApplicationDidBecomeActive];
        }
    }];
}
- (void)showShareActivity:(NSURL *)shareUrl completionBlock:(void(^)(BOOL status))handler {
    //    __weak __typeof__(self) weakSelf = self;
    NSArray* dataToShare = @[shareUrl];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    [activityViewController setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if(completed) {
            //NSLog(@"Complete");
        }
        handler(YES);
    }];
    activityViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:activityViewController animated:YES completion:^{
        
    }];
}
- (void)downloadSelectedVideo:(UIView *)container videoIndex:(NSInteger)videoIndex {
    if (![VideoUtilities isNetworkReachible])  {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"No network connection" isSucess:NO];
    } else {
        NSDictionary *dictData = [self.dataArray objectAtIndex:videoIndex];
        if (!dictData) {
            return;
        }
        MiddtatorVC *obj = [MiddtatorVC new];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[dictData valueForKey:@"postVideo"] forKey:@"url"];
        obj.postData = dict;
        [obj downloadVideoFromUrl];
        [VideoUtilities showLoadingAt:self.navigationController.view];
        self.view.userInteractionEnabled = NO;
        
        [SVProgressHUD showProgress:0.01 status:@"Downloading..."];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveDownloadNotification:)
                                                     name:@"VideoDownloadStatus"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveDownloadPercntageNotification:)
                                                     name:@"VideoDownloadPercntage"
                                                   object:nil];
    }
    
}
- (void) receiveDownloadPercntageNotification:(NSNotification *) notification{
    self.view.userInteractionEnabled = NO;
    float Percentage = [notification.object floatValue];
    Percentage = Percentage*100;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showProgress:[notification.object floatValue] status:[NSString stringWithFormat:@"%.0f%% Download",Percentage]];
    });
}
- (void)receiveDownloadNotification:(NSNotification *) notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoDownloadStatus" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoDownloadPercntage" object:nil];
        
        [VideoUtilities hideLoadingAt:self.navigationController.view];
        self.view.userInteractionEnabled = YES;
        
        NSDictionary *dict = (NSDictionary*)notification.object;
        if(dict && [dict valueForKey:@"videoURL"]) {
            
            [DivinerayVideoMerger writeSLVideoToPhotoLibrary:[dict valueForKey:@"videoURL"] completion:^(BOOL status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (status) {
                        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Video saved sucessfully" isSucess:true];
                        
                    }else  {
                        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went Wrong! Please try again"
                                                          isSucess:false];
                    }
                });
            }];
        }else {
            [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Something went Wrong! Please try again"
                                              isSucess:false];
        }
    });
}

@end
