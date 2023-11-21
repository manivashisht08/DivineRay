//
//  LiveUsersViewCell.m
//  Divineray
//
//  Created by Tejas Dattani on 07/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

#import "LiveUsersViewCell.h"
#import "SDWebImagePrefetcher.h"
#import "UIImageView+WebCache.h"

static NSString * kStrLiveVideo = @"Live";

@implementation LiveUsersViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.IBLblUserVideoType.text = kStrLiveVideo;
    self.IBLblUserVideoType.textColor = [UIColor blackColor];
    
    self.IBVwLive.layer.cornerRadius =  16.0;
    self.IBVwLive.clipsToBounds = YES;
    
    self.IBVwRedDot.layer.cornerRadius =  2;
    self.IBVwRedDot.clipsToBounds = YES;
    
    self.IBImgVwUserProfilePic.layer.cornerRadius =  11.0;
    self.IBImgVwUserProfilePic.clipsToBounds = YES;
    
    self.IBImgVwVideoBackground.layer.cornerRadius =  10.0;
    self.IBImgVwVideoBackground.clipsToBounds = YES;
}

- (void)configureLiveUserlistCell:(NSDictionary *)dict {
    [self.IBImgVwVideoBackground sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
                        placeholderImage:[UIImage imageNamed:@"pl"]];
    [self.IBImgVwUserProfilePic sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
                        placeholderImage:[UIImage imageNamed:@"user_pl"]];
}

@end
