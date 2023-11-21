//
//  UPloadViewController.m
//  Divineray
//
//  Created by     on 20/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

#import "UPloadViewController.h"
#import "PhotoHeaderTableViewCell.h"
#import "InfoTableViewCell.h"
#import "LabelTableViewCell.h"
#import "SaveTableViewCell.h"
#import "Divineray-Swift.h"
#import "VideoUtilities.h"
#import "SVProgressHUD.h"

@class  MiddtatorVC;

static NSString *kPhotoHeaderTableViewCell = @"PhotoHeaderTableViewCell";
static NSString *kInfoTableViewCell = @"InfoTableViewCell";
static NSString *kLabelTableViewCell = @"LabelTableViewCell";
static NSString *kSaveTableViewCell = @"SaveTableViewCell";


@interface UPloadViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (strong, nonatomic) NSString *tagString;
@property (strong, nonatomic) NSString *priceString;
@property (strong, nonatomic) NSString *descriptionTxt;
@property (strong, nonatomic) UITextField *tagTextField;
@property (strong, nonatomic) UITextField *priceTextField;
@property (strong, nonatomic)  UITextView *txtViewDesp;
@end

@implementation UPloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self registerNib];
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(receiveUploadNotification:)
        name:@"VideoUploadStatus"
      object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
       selector:@selector(receiveUploadPercntageNotification:)
           name:@"VideoUploadPercntage"
         object:nil];
}
-(void)registerNib {
    [self.tbView registerNib:[UINib nibWithNibName:kPhotoHeaderTableViewCell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kPhotoHeaderTableViewCell];
    [self.tbView registerNib:[UINib nibWithNibName:kInfoTableViewCell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kInfoTableViewCell];
    [self.tbView registerNib:[UINib nibWithNibName:kLabelTableViewCell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kLabelTableViewCell];
    [self.tbView registerNib:[UINib nibWithNibName:kSaveTableViewCell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kSaveTableViewCell];

}
- (IBAction)closeAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)shareAction:(id)sender {
}
#pragma mark TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 200;
    }
    if(indexPath.row == 1) {
        return 100;
    }
    if(indexPath.row == 2) {
           return 160;
       }
   
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
    PhotoHeaderTableViewCell * cell = (PhotoHeaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier: kPhotoHeaderTableViewCell forIndexPath:indexPath];
        cell.photoView.image = _postViewModel.captureImage;
        cell.photoView.contentMode = UIViewContentModeScaleAspectFit;
        
    return cell;
    }else if(indexPath.row == 1) {
    InfoTableViewCell * cell = (InfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier: kInfoTableViewCell forIndexPath:indexPath];
        if(indexPath.row == 1) {
            cell.lblHint.text = @"Add Tags";
            cell.txtField.hidden = NO;
            cell.bgImg.hidden = NO;
            self.tagTextField =  cell.txtField;
            self.tagTextField.tag = 11;
            self.tagTextField.delegate = self;
            self.tagTextField.keyboardType = UIKeyboardTypeDefault;
            
        }
//        else {
//            cell.lblHint.text = @"Add Price";
//            cell.txtField.hidden = NO;
//            cell.bgImg.hidden = NO;
//            self.priceTextField =  cell.txtField;
//            self.priceTextField.tag = 12;
//            self.priceTextField.delegate = self;
//            self.priceTextField.keyboardType = UIKeyboardTypeNumberPad;
//
//
//        }
    return cell;
    }else if (indexPath.row == 2) {
        LabelTableViewCell * cell = (LabelTableViewCell*)[tableView dequeueReusableCellWithIdentifier: kLabelTableViewCell forIndexPath:indexPath];
        self.txtViewDesp = cell.txtView;
        self.txtViewDesp.delegate = self;
        
        return cell;

    }
    else {
    SaveTableViewCell * cell = (SaveTableViewCell*)[tableView dequeueReusableCellWithIdentifier: kSaveTableViewCell forIndexPath:indexPath];
        [cell.saveBtn addTarget:self action:@selector(uploadVideoStart) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    }
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(textField == self.tagTextField && newLength > 70) {
return NO;
    }
    if([string isEqualToString:@" "] && newLength == 1) {
          return NO;
       }
    
    if(textField == self.tagTextField && newLength > 2) {
        if([string isEqualToString:@"#"] && [self.tagTextField.text hasSuffix:@"#"]) {
            return  NO;
        }
    }
    NSString *currentString = textField.text;

    NSString *newString = [currentString stringByReplacingCharactersInRange:range withString:string];

    if(newString.length == 1 && textField == self.tagTextField && ![string isEqualToString:@" "]){
        if(![newString isEqualToString:@"#"]) {
            self.tagTextField.text = [NSString stringWithFormat:@"#%@",self.tagTextField.text];
        }else {
            self.tagTextField.text = @"";
        }
    }else if(newString.length != 1 && textField == self.tagTextField && [string isEqualToString:@" "]){
        self.tagTextField.text = [NSString stringWithFormat:@"%@ #",self.tagTextField.text];
return NO;
    }
    if(newString.length == 1 && textField == self.priceTextField && ![string isEqualToString:@" "]){
        if(![newString isEqualToString:@"$"]) {
            self.priceTextField.text = [NSString stringWithFormat:@"$%@",self.priceTextField.text];
        }else {
            self.priceTextField.text = @"";
        }
    }
    return newLength <= 70;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSInteger length = textView.text.length + (text.length - range.length);
    if((length == 1 && [text isEqualToString:@" "]) || (length == 0 && [text isEqualToString:@" "])) {
           return NO;
       }
    if(length <= 1000) {
        return YES;
    }else {
        return NO;
    }
}
-(void)uploadVideoStart {
   
   NSString *tags = self.tagTextField.text;
    if ([tags hasPrefix:@"#"] && [tags length] > 1) {
        tags = [tags substringFromIndex:1];
    }
    if([tags length] == 0) {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Please enter tags" isSucess:false];
       return;
    }
    NSString *string = tags;

    NSString *specialCharacterString = @"!~`@$%^&*-+();:={}[],.<>?\\/\"\'";
    NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                           characterSetWithCharactersInString:specialCharacterString];

    if ([string.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].length) {
        NSLog(@"contains special characters");
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Please enter valid tags" isSucess:false];

        return;
    }
    
    if([self.txtViewDesp.text length] == 0) {
        [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:@"Please enter description" isSucess:false];
        return;
    }
    self.btnBack.userInteractionEnabled = NO;
       self.tbView.userInteractionEnabled = NO;
    [SVProgressHUD showProgress:0.01 status:@"Uploading"];
    [VideoUtilities showLoadingAt:self.navigationController.view];
    [VideoUtilities exportVideoInMp4Format:[[NSURL alloc] initFileURLWithPath:self->_postViewModel.finalVideoPath] completion:^(NSURL *mp4VideoURL, NSError *error) {
        if(!error) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mp4VideoURL options:nil];
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *track = [tracks objectAtIndex:0];
            CGSize mediaSize = track.naturalSize;

            MiddtatorVC *obj = [MiddtatorVC new];
               NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            if(self->_postViewModel.muisicId) {
                [dict setValue:self->_postViewModel.muisicId forKey:@"musicId"];
            }
            [dict setValue:[NSString stringWithFormat:@"%f",mediaSize.width] forKey:@"postWidth"];
            [dict setValue:[NSString stringWithFormat:@"%f",mediaSize.height] forKey:@"postHeight"];
            [dict setValue:self.tagTextField.text forKey:@"tags"];
               [dict setValue:self.txtViewDesp.text forKey:@"description"];
               obj.postData = dict;
            NSData *imageData = UIImageJPEGRepresentation(self->_postViewModel.captureImage, 1.0);
               obj.imagesData = imageData;
            obj.videoPathUrl = mp4VideoURL;
               [obj upload];

        }else {
            [VideoUtilities hideLoadingAt:self.navigationController.view];
            //Show Error
            self.btnBack.userInteractionEnabled = YES;
            self.tbView.userInteractionEnabled = YES;
        }
    }];
    
   
}
- (void)receiveUploadNotification:(NSNotification *) notification{
    self.btnBack.userInteractionEnabled = YES;
    self.tbView.userInteractionEnabled = YES;

    [VideoUtilities hideLoadingAt:self.navigationController.view];
//    [[NSNotificationCenter defaultCenter]
//    postNotificationName:@"VideoRefershCall"
//    object:nil];
    NSDictionary *dict = (NSDictionary*)notification.object;
    
//    [VideoUtilities showDropDownAlertWithTitle:@"" withMessage:[dict valueForKey:@"message"] isSucess:true];
    [self.navigationController popToRootViewControllerAnimated:YES];
   
}
- (void) receiveUploadPercntageNotification:(NSNotification *) notification{
    NSLog(@"Percentage %@",notification.object);
    self.btnBack.userInteractionEnabled = NO;
    self.tbView.userInteractionEnabled = NO;
    [SVProgressHUD showProgress:[notification.object floatValue] status:@"Uploading"];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoUploadStatus" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoUploadPercntage" object:nil];
}

@end
