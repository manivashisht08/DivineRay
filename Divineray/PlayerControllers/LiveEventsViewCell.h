//
//  LiveEventsViewCell.h
//  Divineray
//
//  Created by Tejas Dattani on 07/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveEventsViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *IBImgVwUserProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *IBLblUserName;
@property (weak, nonatomic) IBOutlet UILabel *IBLblUserVideoType;
@property (weak, nonatomic) IBOutlet UIImageView *IBImgVwVideoBackground;

- (void)configureLiveEventlistCell:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
