//
//  SLVideosDataSource.h
//  OakHeads
//
//  Created by "" Rathor on 15/03/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^SLVideoViewCellConfigureBlock)(id cell, id item, NSIndexPath* indexPath);
typedef void (^SLVideoViewSupplementaryViewConfigureBlock)(id view,                 // the header/footer view
 NSString *kind,          // the kind of reusable view
 UICollectionView *cv,    // the parent collection view
 NSIndexPath *indexPath); // index path where this view appears



@interface SLVideosDataSource : NSObject <UICollectionViewDataSource>

@property (readwrite, nonatomic)BOOL showFooter;
@property (nonatomic, copy) SLVideoViewSupplementaryViewConfigureBlock collectionSupplementaryConfigureBlock;

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(SLVideoViewCellConfigureBlock)aConfigureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (void)setupCollectionViewFooter:(NSString *)aFooterIdentifier;
- (void)setupCollectionViewHeader:(NSString *)aHeaderIdentifier;
- (void)showLoadingGettingMoreItems;
- (void)hideLoadingGotItems;

@end
