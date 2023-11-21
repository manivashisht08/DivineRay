//
//  UICollectionView+SLHelper.m
//  Divineray
//
//  Created by ""  on 24/11/18.
//

#import "UICollectionView+SLHelper.h"
#import "SLConstants.h"

@implementation UICollectionView (SLHelper)

- (void)registerHeaderFooter {
    [self registerReusableCellFooter:[UICollectionReusableView class] withReusableId:kPhotoFooterViewIdentifier];
    
    [self registerReusableCellHeader:[UICollectionReusableView class] withReusableId:kOfferHeaderViewIdentifier];
}

- (void)registerCellWithNib:(Class)className withReusableId:(NSString *)reusableId {
    [self registerNib:[UINib nibWithNibName:NSStringFromClass([className class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reusableId];
}

- (void)registerReusableCellFooter:(Class)className withReusableId:(NSString *)reusableId {
     [self registerClass:[className class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reusableId];
}

- (void)registerReusableCellHeader:(Class)className withReusableId:(NSString *)reusableId {
    [self registerClass:[className class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reusableId];
}

- (void)registerCellWithNibHeader:(Class)className withReusableId:(NSString *)reusableId {
     [self registerNib:[UINib nibWithNibName:NSStringFromClass([className class]) bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reusableId];
}


- (void)configurePlaylistProperties {
    self.backgroundColor = [UIColor blackColor];
    self.frame = [[UIScreen mainScreen]bounds];
    self.bounds = [[UIScreen mainScreen]bounds];
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
}

@end
