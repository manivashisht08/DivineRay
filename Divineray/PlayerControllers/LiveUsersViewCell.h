//
//  LiveUsersViewCell.h
//  Divineray
//
//  Created by Tejas Dattani on 07/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveUsersViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *IBVwLive;
@property (weak, nonatomic) IBOutlet UIView *IBVwRedDot;
@property (weak, nonatomic) IBOutlet UIImageView *IBImgVwUserProfilePic;
@property (weak, nonatomic) IBOutlet UIImageView *IBImgVwVideoBackground;
@property (weak, nonatomic) IBOutlet UILabel *IBLblUserVideoType;

- (void)configureLiveUserlistCell:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
