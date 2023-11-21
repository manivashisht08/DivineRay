//
//  SLFiltersView.m
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 08/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import "SLFiltersView.h"
#import "SLFilterData.h"
#import "SLContentsDataSource.h"
#import "FilterItemCollectionViewCell.h"
#import "SLCollectionViewDataSource.h"

static NSString* const cellIdentifierString = @"FilterItemCollectionViewCell";

@interface SLFiltersView () <UICollectionViewDelegate> {
}

@property (unsafe_unretained, nonatomic) IBOutlet UICollectionView *collectionView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *arraowButton;

@property (nonatomic, strong) NSMutableArray* filterAry;
@property (nonatomic, strong) SLCollectionViewDataSource *dataSource;
@property (nonatomic, strong) NSIndexPath* lastFilterIndex;
@property (nonatomic, strong) NSIndexPath* nowFilterIndex;
@property (nonatomic, assign) NSInteger  currentFilterIndex;


@end

@implementation SLFiltersView


+ (SLFiltersView *)DivinerayFiltersView {
    SLFiltersView *_DivinerayFiltersView = [[[NSBundle mainBundle] loadNibNamed:@"SLFiltersView" owner:self options:nil] lastObject];
    return _DivinerayFiltersView;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createCollectionView];
    }
    return self;
}
#pragma mark - View Initialisations
- (void)awakeFromNib {
    [super awakeFromNib];
    [_arraowButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
    
    _arraowButton.alpha = 0.90;
    [self createCollectionView];
}

- (void)createCollectionView {
    
    [_collectionView registerNib:[UINib nibWithNibName:@"FilterItemCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellIdentifierString];

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate =self;
    _currentFilterIndex = 0;
}

/**
 Initialise the Filter Resources
 */
-(void)initialiseFiltersResource {
    
    _lastFilterIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    self.filterAry = [NSMutableArray arrayWithArray:[[SLContentsDataSource sharedContentsManager] getAllFiltersCollection]];
    
    _collectionView.backgroundColor = [UIColor clearColor];
    
    self.dataSource = [[SLCollectionViewDataSource alloc]initWithItems:self.filterAry cellIdentifier:cellIdentifierString configureCellBlock:^(id cell, id item, NSIndexPath *indexPath) {
        FilterItemCollectionViewCell *filterCell = (FilterItemCollectionViewCell *)cell;
        filterCell.backgroundColor = [UIColor clearColor];
        [filterCell configureFilterCell:item];
    }];
    
    _collectionView.dataSource = self.dataSource;
    [_collectionView reloadData];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 70);
}

- (void)reloadFilters {
     [self->_collectionView reloadData];
 }

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _nowFilterIndex = indexPath;
    
    if (_lastFilterIndex.row != _nowFilterIndex.row) {
        
        SLFilterData* dataNow = [_filterAry objectAtIndex:indexPath.row];
        dataNow.isSelected = YES;
        [_filterAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
        SLFilterData* dataLast = [_filterAry objectAtIndex:_lastFilterIndex.row];
        dataLast.isSelected = NO;
        [_filterAry replaceObjectAtIndex:_lastFilterIndex.row withObject:dataLast];
        [_collectionView reloadData];
        _lastFilterIndex = indexPath;
        [self->_collectionView scrollToItemAtIndexPath:_lastFilterIndex atScrollPosition:(UICollectionViewScrollPositionNone) animated:YES];

        if (self.selectedFilter) {
            SLFilterData* selectedItem = [_filterAry objectAtIndex:indexPath.row];
            self.selectedFilter(selectedItem, indexPath.row);
        }
    }
}

- (IBAction)arrowButtonDidClicked:(id)sender {
    if (_hideFilters) {
        _hideFilters();
    }
        
}

- (void)swapRightFilterGesture {
    _currentFilterIndex--;
    if (_currentFilterIndex >=0) {
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentFilterIndex inSection:0];
         [self collectionView:_collectionView didSelectItemAtIndexPath:indexPath];
    } else {
        _currentFilterIndex = 0;
    }
}

- (void)swapLeftFilterGesture  {
    _currentFilterIndex++;
    if (_currentFilterIndex <[_filterAry count]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentFilterIndex inSection:0];
        [self collectionView:_collectionView didSelectItemAtIndexPath:indexPath];
    } else {
        _currentFilterIndex = [_filterAry count]-1;
    }
}



@end
