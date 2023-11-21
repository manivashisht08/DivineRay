//
//  SLFiltersView.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 08/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLFilterData;
typedef void(^selectedFilterBlock)(SLFilterData *filter, NSInteger itemIndex);
typedef void(^hideFooterViewBlock)(void);


@interface SLFiltersView : UIView {
    
}
@property (nonatomic , copy) selectedFilterBlock selectedFilter;
@property (nonatomic , copy) hideFooterViewBlock hideFilters;


+ (SLFiltersView *)DivinerayFiltersView;
- (void)initialiseFiltersResource;
- (void)reloadFilters;

- (void)swapLeftFilterGesture;
- (void)swapRightFilterGesture;

@end

