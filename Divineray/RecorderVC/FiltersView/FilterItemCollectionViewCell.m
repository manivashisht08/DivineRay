//
//  FilterItemCollectionViewCell.m
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 08/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import "FilterItemCollectionViewCell.h"
#import "SLFilterData.h"

@implementation FilterItemCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    _containerView.layer.cornerRadius = 25.0;
    _containerView.layer.masksToBounds = YES;
    _checkMarkBgView.hidden = YES;
    
    
}

- (void)configureFilterCell:(SLFilterData *)filterData {
    
    __weak typeof(self) _self = self;
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        //self.checkMarkImgView.image = SLKlugSharedImagePath(@"filter_checked");
        _self.checkMarkImgView.layer.borderWidth = 3;
        _self.checkMarkImgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _self.checkMarkImgView.layer.masksToBounds = YES;
        _self.checkMarkImgView.layer.cornerRadius = 25.0;

        self.iconImgView.image = filterData.filterImage;
        self.nameLabel.text = filterData.name;
        self.checkMarkImgView.hidden = !filterData.isSelected;
        self.checkMarkBgView.hidden = !filterData.isSelected;
    //});
}

@end
