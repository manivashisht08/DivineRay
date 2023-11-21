//
//  CommentViewController.m
//     
//
//  Created by     on 03/06/20.
//

#import "CommentViewController.h"
#import "CommentsCell.h"
#import "SLContentsDataSource.h"
#import "VideoUtilities.h"
#import "SLSharedDownloadManager.h"
#import "UIImageView+WebCache.h"
#import "Divineray-Swift.h"

@interface CommentViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
}
@property (weak, nonatomic) IBOutlet UILabel *commentTille;

@property (weak, nonatomic) IBOutlet UILabel *noCommentFoundLbl;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *sentLoader;
@property (weak, nonatomic) IBOutlet UITextField *txtField;
@property (weak, nonatomic) IBOutlet UIView *growingBtView;
@property (weak, nonatomic) IBOutlet UIButton *sentBtn;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *commentsListArray;
@property (nonatomic, assign) NSInteger radius;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

static NSString *kCommentCellIdentifier = @"CommentsCell";
@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noCommentFoundLbl.hidden = YES;
    self.sentLoader.hidden = YES;
    self.sentBtn.enabled = NO;
    self.txtField.delegate = self;
    self.txtField.keyboardType = UIKeyboardTypeASCIICapable;
    [_sentBtn setImage:[UIImage imageNamed:@"sentMessage"] forState:UIControlStateNormal];
   
    _radius = 20;
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _containerView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){_radius, _radius}].CGPath;
    
    _containerView.layer.mask = maskLayer;
    [_containerView setNeedsLayout];
    [_containerView layoutIfNeeded];
    
    _tableView.tableFooterView = [[UIView alloc]init];
    [_closeButton setImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
    _closeButton.showsTouchWhenHighlighted = YES;
    
    UINib *nibName = [UINib nibWithNibName:kCommentCellIdentifier bundle:[NSBundle    mainBundle]];
    [self.tableView registerNib:nibName forCellReuseIdentifier:kCommentCellIdentifier];
    _commentsListArray  = [[NSMutableArray alloc]init];
    
    // Creating the Data Source
    _tableView.dataSource = self;
    [_tableView reloadData];
    [self getCommentsList];
    
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
#pragma mark TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentsListArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentsCell * cell = (CommentsCell*)[tableView dequeueReusableCellWithIdentifier: kCommentCellIdentifier forIndexPath:indexPath];
    NSDictionary *commentItem  = [self.commentsListArray objectAtIndex:indexPath.row];
    cell.commentLbl.text = [commentItem valueForKey:@"comment"];
    cell.nameLbl.text = [commentItem valueForKey:@"comment_by"];
    cell.btnProfile.tag = indexPath.row;
    [cell.btnProfile addTarget:self action:@selector(openProfile:) forControlEvents:UIControlEventTouchUpInside];

    cell.userImageView.backgroundColor =  [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
    if([[commentItem valueForKey:@"image_user"] length]>0) {
        [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:[commentItem valueForKey:@"image_user"]]
                              placeholderImage:[UIImage imageNamed:@"userImg1"]];
    } else {
        cell.userImageView.image = [UIImage imageNamed:@"userImg"];
    }
    
    float seconds =  [[NSDate date]timeIntervalSince1970] - [[commentItem valueForKey:@"commentTime"] integerValue];
    float minutes = seconds / 60.0;
    cell.timeLbl.text = [self calculatePostTimeFrom:[NSString stringWithFormat:@"%f", minutes]];
    return cell;
}
-(void)openProfile:(UIButton*)btn {
    NSDictionary *commentItem  = [self.commentsListArray objectAtIndex:btn.tag];
    NSLog(@"%@",commentItem);
    if(self.delegate && [self.delegate respondsToSelector:@selector(openProfileCall:)]) {
        self.completionBlock(NO);
        [self.delegate openProfileCall:[commentItem valueForKey:@"userInfo"]];
    }
}
- (NSString*)calculatePostTimeFrom:(NSString*)postMinutes {
    NSInteger pMins = [postMinutes integerValue];
    
    if(pMins <= 0) {
        return @"a moment ago";
    }
    else
    {
        NSRange daysRange = NSMakeRange (1, 29);
        NSRange monthsRange = NSMakeRange (1, 11);
        
        NSInteger pHours = pMins/60;
        NSInteger pDays = pHours/24;
        NSInteger pMonths = pDays/30;
        
        NSInteger timeValue;
        NSString * timeUnit;
        if (pHours <= 0)
        {
            timeValue = pMins;
            timeUnit = (timeValue == 1) ? @"min ago" : @"mins ago";
        }
        else if (pHours < 24)
        {
            timeValue = pHours;
            timeUnit = (timeValue == 1) ? @"hr ago": @"hrs ago";
        }
        else if (NSLocationInRange(pDays, daysRange))
        {
            timeValue = pHours/24;
            timeUnit = (timeValue == 1) ? @"day ago" : @"days ago";
        }
        else if (NSLocationInRange(pMonths, monthsRange))
        {
            timeValue = pMonths;
            timeUnit = (timeValue == 1) ? @"month ago" : @"months ago";
        }
        else
        {
            timeValue = pMonths/12;
            timeUnit = (timeValue == 1) ? @"year ago" : @"years ago";
        }
        
        return [NSString stringWithFormat:@"%ld %@", (long)timeValue, timeUnit];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.txtField resignFirstResponder];
}

- (IBAction)cancelButtonDidClicked:(id)sender {
    [self.txtField resignFirstResponder];
    self.completionBlock(NO);
}

- (void)getCommentsList{
    [self sentLoderVisible:NO];
    self.noCommentFoundLbl.hidden = YES;
    self.loadingView.hidden = NO;
    [self getAllComments];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength == 1 && [string isEqualToString:@" "]) {
        self.sentBtn.enabled = NO;
       return NO;
    }
    if(newLength == 0 && [string isEqualToString:@" "]) {
           self.sentBtn.enabled = NO;
          return NO;
       }
    if(newLength == 0) {
        self.sentBtn.enabled = NO;
    }else {
        self.sentBtn.enabled = YES;
    }
    return newLength <= 110;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)sentAction:(id)sender{
    [self.txtField resignFirstResponder];
    NSDictionary *params = @{
        @"videoId" : [self.dict valueForKey:@"videoId"],
        @"comment"    :  self.txtField.text,@"commentId":@"0"
    };
    [self sentLoderVisible:YES];
[[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveSentCommentDataNotification:)
                                              name:@"SentCommentAction"
                                            object:nil];
 MiddtatorVC *obj = [MiddtatorVC new];
 obj.postData = params;
 [obj sentCommentService];
}
- (void)receiveSentCommentDataNotification:(NSNotification *) notification{
[VideoUtilities hideLoadingAt:self.navigationController.view];
[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SentCommentAction" object:nil];
    [self sentLoderVisible:NO];
if(notification.object && [notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)notification.object;
    if([dict valueForKey:@"status"] && [[dict valueForKey:@"status"] intValue]  == 1) {
          self.txtField.text = @"";
        if(self.delegate && [self.delegate respondsToSelector:@selector(updateCommentCount:)]) {
            [self.delegate updateCommentCount:[dict valueForKey:@"totalComments"]];
            if([dict valueForKey:@"data"] &&  [[dict valueForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                [self.commentsListArray addObject:[dict valueForKey:@"data"]];
                [self.tableView reloadData];
                [self scrollBottom];
            }
        }
    }else {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:[dict valueForKey:@"message"] isSucess:NO];
    }
 }
}

-(void)sentLoderVisible:(BOOL)isVisible {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.sentBtn.hidden = isVisible;
        self.sentLoader.hidden = !isVisible;
        if(!isVisible) {
            [self.sentLoader stopAnimating];
        }else {
            [self.sentLoader startAnimating];
        }
    });
}
-(void)scrollBottom {
    if (self.commentsListArray.count > 1) {
[self.tableView
               scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.commentsListArray.count-1
               inSection:0]
               atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }
    if(self.commentsListArray.count == 0) {
        self.noCommentFoundLbl.hidden = NO;
        self.commentTille.text = @"Comments";

    }else {
        self.noCommentFoundLbl.hidden = YES;
//        if(self.commentsListArray.count == 1) {
        self.commentTille.text = [NSString stringWithFormat:@"Comments (%lu)",(unsigned long)self.commentsListArray.count];
//        }else {
//            self.commentTille.text = [NSString stringWithFormat:@"Comments(%lu)",(unsigned long)self.commentsListArray.count];
//        }
    }
    if(self.delegate) {
        [self.delegate updateCommentCount:[NSString stringWithFormat:@"%lu",(unsigned long)self.commentsListArray.count]];
    }
}
#pragma mark get All comments -
-(void)getAllComments{
//    [VideoUtilities showLoadingAt:self.navigationController.view];
    NSDictionary *params = @{
        @"videoId" : [self.dict valueForKey:@"videoId"], };
    [self sentLoderVisible:YES];
[[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(receiveListCommentDataNotification:)
                                              name:@"ListCommentAction"
                                            object:nil];
 MiddtatorVC *obj = [MiddtatorVC new];
 obj.postData = params;
 [obj listCommentService];
}
- (void)receiveListCommentDataNotification:(NSNotification *) notification{
[VideoUtilities hideLoadingAt:self.navigationController.view];
[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SentCommentAction" object:nil];
    [self sentLoderVisible:NO];
    self.loadingView.hidden = YES;
    self.txtField.text = @"";
if(notification.object && [notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)notification.object;
    if([dict valueForKey:@"status"] && [[dict valueForKey:@"status"] intValue]  == 1) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(updateCommentCount:)]) {
            [self.delegate updateCommentCount:[dict valueForKey:@"totalComments"]];
            if([dict valueForKey:@"data"] &&  [[dict valueForKey:@"data"] isKindOfClass:[NSArray class]]) {
                [self.commentsListArray addObjectsFromArray:[dict valueForKey:@"data"]];
                [self.tableView reloadData];
                [self scrollBottom];
            }
        }
    }
 }
}
@end
