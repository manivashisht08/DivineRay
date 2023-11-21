//
//  FilterItemCollectionViewCell.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 08/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLFilterData;
@class SLMusicData;

NS_ASSUME_NONNULL_BEGIN

@interface FilterItemCollectionViewCell : UICollectionViewCell

- (void)configureFilterCell:(SLFilterData *)filterCell;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic,weak) IBOutlet UIImageView* iconImgView;
@property (nonatomic,weak) IBOutlet UILabel* nameLabel;
@property (nonatomic,weak) IBOutlet UIImageView* checkMarkImgView;
@property (nonatomic,weak) IBOutlet UIView* checkMarkBgView;

@end

NS_ASSUME_NONNULL_END
