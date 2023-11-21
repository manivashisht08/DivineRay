//
//  SLVideosDataSource.m
#import "SLVideosDataSource.h"

@interface SLVideosDataSource ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) NSString *footerIdentifier;
@property (nonatomic, copy) NSString *headerIdentifier;

@property (nonatomic, copy) SLVideoViewCellConfigureBlock configureCellBlock;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end


@implementation SLVideosDataSource

- (id)init
{
    _showFooter=YES;
    return nil;
}

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(SLVideoViewCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        
        _showFooter=YES;
        self.items = anItems;
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
    }
    return self;
}

- (void)setupCollectionViewFooter:(NSString *)aFooterIdentifier {
    _footerIdentifier = aFooterIdentifier;
}
- (void)setupCollectionViewHeader:(NSString *)aHeaderIdentifier {
    _headerIdentifier = aHeaderIdentifier;
}



#pragma mark - collectionView delegate Implementation
- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
        return self.items[(NSUInteger) indexPath.item];
    }
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

-(NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* collectionViewCell = (UICollectionViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(collectionViewCell, item, indexPath);
    return collectionViewCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader ) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:_footerIdentifier forIndexPath:indexPath];

        //Pass user mode
        if (self.collectionSupplementaryConfigureBlock) {
            self.collectionSupplementaryConfigureBlock(headerView, kind, collectionView, indexPath);
        }
        return nil;
    }
    
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:_footerIdentifier forIndexPath:indexPath];
    if (footerView !=nil && [self.items count]>0) {
        
        if ([_activityIndicator superview]) {
            [_activityIndicator removeFromSuperview];
        }
        
        CGPoint center = self.activityIndicator.center;
        center.x = footerView.center.x;
        center.y = 20;
        self.activityIndicator.center = center;
        [footerView addSubview:self.activityIndicator];
    }
    
    return footerView;
}


- (void)showLoadingGettingMoreItems {
    _activityIndicator.hidden=NO;
    [self.activityIndicator startAnimating];
}

- (void)hideLoadingGotItems {
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden=YES;
}

- (void)dealloc {
   
}

@end
