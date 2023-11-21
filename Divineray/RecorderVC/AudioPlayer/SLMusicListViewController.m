//
//  SLMusicListViewController.m


#import "SLMusicListViewController.h"
#import "SLCollectionViewDataSource.h"
#import "AddSoundTableCell.h"
#import "SLMusicData.h"
#import "SLContentsDataSource.h"
#import "SLAudioPlayer.h"
#import "VideoUtilities.h"
#import "SLSharedDownloadManager.h"
#import "Divineray-Swift.h"

@interface SLMusicListViewController () <UITableViewDelegate, AddSoundDelegate> {
    AVPlayerItem *audioPlayerItem;
}
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SLCollectionViewDataSource *dataSource;
@property (strong, nonatomic) NSMutableArray *musicListArray;
@property (strong, nonatomic) NSString *soundFilePath;
@property (nonatomic, strong) SLAudioPlayer *audioPlayer;
@property (nonatomic, assign) NSInteger currentAudioIndex;
@property (nonatomic, assign) NSInteger radius;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

static NSString *kMusicCellIdentifier = @"AddSoundTableCell";
@implementation SLMusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentAudioIndex =-1;
    
    _radius = 20;
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _containerView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){_radius, _radius}].CGPath;
    
    _containerView.layer.mask = maskLayer;
    [_containerView setNeedsLayout];
    [_containerView layoutIfNeeded];
    
    _tableView.tableFooterView = [[UIView alloc]init];
    [_closeButton setImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
    _closeButton.showsTouchWhenHighlighted = YES;
    
    UINib *nibName = [UINib nibWithNibName:@"AddSoundTableCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nibName forCellReuseIdentifier:kMusicCellIdentifier];
    _tableView.rowHeight = 70;
    _musicListArray  = [[NSMutableArray alloc]init];
    
    
    // Creating the Data Source
    _dataSource  = [[SLCollectionViewDataSource alloc]initWithItems:self.musicListArray cellIdentifier:kMusicCellIdentifier configureCellBlock:^(AddSoundTableCell *cell, SLMusicData *item, NSIndexPath *indexPath) {
        
        cell.audioIndex = indexPath.row;
        [cell configureMusicCell:item ];
        cell.delegate = self;
    }];
    
    _tableView.dataSource = _dataSource;
    [_tableView reloadData];
    [self getAudioList];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _containerView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){_radius, _radius}].CGPath;
    _containerView.layer.mask = maskLayer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_currentAudioIndex == indexPath.row) {
        
        AddSoundTableCell *tableCell = [_tableView cellForRowAtIndexPath:indexPath];
        SLMusicData *audioItem = _musicListArray[_currentAudioIndex];
        if ([audioItem.musicPath length]> 0) {
            BOOL isPlaying =  FALSE;
            if ([_audioPlayer isPlaying]) {
                isPlaying = NO;
                [_audioPlayer pauseSound];
            } else {
                isPlaying = YES;
                [_audioPlayer playSound];
            }
            [tableCell updateMusicPlayingCell:isPlaying];
        } else {
            [tableCell updateMusicPlayingCell:NO];
        }
        
    } else {
        _currentAudioIndex = indexPath.row;
        [self changeSoundIndex:indexPath.row];
    }
}

- (IBAction)cancelButtonDidClicked:(id)sender {
    if(self.audioPlayer) {
        [_audioPlayer pauseSound];
        self.audioPlayer = nil;
    }
    self.completionBlock(nil,nil,nil,NO);
}

#pragma mark - AddSoundDelegate
- (void)soundIndexDidClicked:(NSInteger)index {
    
    SLMusicData *musicData = _musicListArray[index];
    if(self.audioPlayer) {
        [_audioPlayer pauseSound];
        self.audioPlayer = nil;
    }
    
    if ([musicData.musicPath length]>0) {
        self.completionBlock(musicData.musicPath, musicData.name, musicData.muisicId, YES);
    } else {
        if (![VideoUtilities isNetworkReachible]) {
            [VideoUtilities showErrorDropDownAlertWithTitle:@"" withMessage:@"No network connection" isSucess:NO];
        }
    }
}

- (void)changeSoundIndex:(NSInteger)index {
    
    if(self.audioPlayer) {
        [_audioPlayer pauseSound];
        self.audioPlayer = nil;
    }
    
    SLMusicData *audioItem = _musicListArray[index];
    for (SLMusicData * audio in  _musicListArray) {
        audio.isSelected = FALSE;
        audio.playerState = SLAudioStatePaused;
    }
    audioItem.isSelected = YES;
    audioItem.playerState = SLAudioStateLoading;
    [self.tableView reloadData];
    
    [[SLSharedDownloadManager sharedManager]download:[NSURL URLWithString:audioItem.soundUrlString] destPath:nil state:nil progress:nil completion:^(BOOL success, NSString *filePath, NSError *error) {
        __weak typeof(self) _self = self;
        if (!error && success) {
            audioItem.playerState = SLAudioStatePlaying;
            audioItem.musicPath = filePath;
            SLMusicData * audioData = _self.musicListArray[index];
            _self.audioPlayer  = [[SLAudioPlayer alloc]initWithAudioFile:audioData.musicPath];
            [_self.audioPlayer playSound];
        } else {
            audioItem.playerState = SLAudioStatePaused;
        }
        
        AddSoundTableCell *audioCell = (AddSoundTableCell *) [_self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if (audioCell) {
            [audioCell updateAudioCellWithInfo:audioItem];
        }else {
            [_self.tableView reloadData];
        }
    }];
}

- (void)getAudioList {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAudioDataNotification:)
                                                 name:@"AudioDataFetch"
                                               object:nil];
    MiddtatorVC *obj = [MiddtatorVC new];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    obj.postData = dict;
    [obj getAudioListService];
    
}
- (void)receiveAudioDataNotification:(NSNotification *) notification{
    [VideoUtilities hideLoadingAt:self.navigationController.view];
    [self.loadingView stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioDataFetch" object:nil];
    if(notification.object && [notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)notification.object;
        if([dict valueForKey:@"status"] && [[dict valueForKey:@"status"] intValue]  == 1) {
            if([dict valueForKey:@"data"] && [[dict valueForKey:@"data"] isKindOfClass:[NSArray class]]) {
                NSArray *data = [dict valueForKey:@"data"];
                for (NSDictionary *infoDict in data) {
                    SLMusicData *musicModel = [[SLMusicData alloc]init];
                    musicModel.name = [infoDict valueForKey:@"musicName"];
                    musicModel.muisicId = [infoDict valueForKey:@"musicId"];
                    musicModel.soundUrlString = [infoDict valueForKey:@"musicFile"];
                    musicModel.iconPath = [infoDict valueForKey:@"musicImage"];
                    musicModel.duration = @"";
                    musicModel.category = [infoDict valueForKey:@"musicCat"];
                    [self.musicListArray addObject:musicModel];
                }
                [self.tableView reloadData];
            }
        }
    }
    
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DashBoardDataFetch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LikeDataFetch" object:nil];
}

@end
