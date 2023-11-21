//
//  LiveEventsViewCell.m
//  Divineray
//
//  Created by Tejas Dattani on 07/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

#import "LiveEventsViewCell.h"
#import "SDWebImagePrefetcher.h"
#import "UIImageView+WebCache.h"

static NSString * kStrRecordedVideo = @"Recorded Video";

@implementation LiveEventsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.IBLblUserVideoType.text = kStrRecordedVideo;
    self.IBLblUserVideoType.backgroundColor = [UIColor colorWithRed:255/255.0f green:69/255.0f blue:34/255.0f alpha:1.0f];
    self.IBLblUserVideoType.layer.cornerRadius =  13.0;
    self.IBLblUserVideoType.clipsToBounds = YES;
    
    self.IBImgVwUserProfilePic.layer.cornerRadius =  25.0;
    self.IBImgVwUserProfilePic.clipsToBounds = YES;
    
    self.IBImgVwVideoBackground.layer.cornerRadius =  10.0;
    self.IBImgVwVideoBackground.clipsToBounds = YES;
}

- (void)configureLiveEventlistCell:(NSDictionary *)dict {
    self.IBLblUserName.text = [dict valueForKey:@"name"];
    [self.IBImgVwVideoBackground sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
                        placeholderImage:[UIImage imageNamed:@"pl"]];
    
    [self.IBImgVwUserProfilePic sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
                        placeholderImage:[UIImage imageNamed:@"user_pl"]];
}

@end
