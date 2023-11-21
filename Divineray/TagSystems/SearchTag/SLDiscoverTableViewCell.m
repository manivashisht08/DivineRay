//
//  SLDiscoverTableViewCell.m
//  Divineray
//
//  Created by Ansh Kumat on 08/04/19.
//

#import "SLDiscoverTableViewCell.h"
#import "TagUICollectionViewCell.h"
#import "VideoUtilities.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "SLCollectionViewFlowLayout.h"

static NSString *kvodUserCellIdentifier = @"TagUICollectionViewCell";

@implementation SLDiscoverTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
    self.hashLbl.layer.cornerRadius =  15.0;
    self.hashLbl.clipsToBounds = YES;
    self.ctView.contentInset = UIEdgeInsetsMake(0, 20, 0, 0);
    [self.ctView registerNib:[UINib nibWithNibName:NSStringFromClass([TagUICollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kvodUserCellIdentifier];
    self.ctView.delegate =  self;
    self.ctView.dataSource = self;
    [self.ctView setCollectionViewLayout:[[SLCollectionViewFlowLayout alloc] initTagHeaderVideosDispFlowLayout:self.ctView.frame.size.height] animated:NO];
    self.ctView.backgroundColor =  [UIColor clearColor];
    
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSArray *videoItems = [self.cellModel valueForKey:@"tagVideos"];
    NSInteger totalVideos = [[self.cellModel valueForKey:@"totalVideos"] intValue];
    if(totalVideos > videoItems.count) {
        return videoItems.count + 1;

    }else
    {
    return videoItems.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *videoItems = [self.cellModel valueForKey:@"tagVideos"];
    NSInteger totalVideos = [[self.cellModel valueForKey:@"totalVideos"] intValue];

    if(totalVideos > videoItems.count && indexPath.row ==  videoItems.count)
    {
        TagUICollectionViewCell* collectionViewCell = (TagUICollectionViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:kvodUserCellIdentifier forIndexPath:indexPath];
        collectionViewCell.posterImage.contentMode = UIViewContentModeScaleAspectFill;
        collectionViewCell.posterImage.clipsToBounds = YES;
        collectionViewCell.posterImage.layer.cornerRadius =  1.0;
        collectionViewCell.posterImage.clipsToBounds = YES;
        collectionViewCell.posterImage.contentMode =  UIViewContentModeScaleAspectFill;
        collectionViewCell.backgroundColor =  [UIColor clearColor];
        collectionViewCell.posterImage.hidden =  YES;
        collectionViewCell.moreViewLbl.hidden =  NO;
        collectionViewCell.activityLoader.hidden =  YES;
        [collectionViewCell.activityLoader stopAnimating];
        return collectionViewCell;
        
    }else
    {
        
    NSDictionary* videoInfo =  videoItems[indexPath.row];
    TagUICollectionViewCell* collectionViewCell = (TagUICollectionViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:kvodUserCellIdentifier forIndexPath:indexPath];
    collectionViewCell.posterImage.contentMode = UIViewContentModeScaleAspectFill;
    collectionViewCell.posterImage.hidden =  NO;
        collectionViewCell.moreViewLbl.hidden =  YES;

    collectionViewCell.posterImage.clipsToBounds = YES;
    collectionViewCell.posterImage.layer.cornerRadius =  1.0;
    collectionViewCell.posterImage.clipsToBounds = YES;
    collectionViewCell.posterImage.contentMode =  UIViewContentModeScaleAspectFill;
    collectionViewCell.backgroundColor =  [UIColor clearColor];
        collectionViewCell.activityLoader.hidden =  NO;
        [collectionViewCell.activityLoader startAnimating];
        
        [collectionViewCell.posterImage sd_setImageWithURL:[NSURL URLWithString:[videoInfo valueForKey:@"postImage"]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL)
        {
            collectionViewCell.activityLoader.hidden =  YES;
            [collectionViewCell.activityLoader stopAnimating];
            collectionViewCell.posterImage.image = image;
        }];
    return collectionViewCell;
    }
}
-(void)scrollToTopCollectionView
{
    NSArray *videoItems = [self.cellModel valueForKey:@"tagVideos"];
    if(self.ctView && self.cellModel && videoItems.count > 0 )
    {
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.ctView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}
-(void)updateCellData:(NSDictionary*)model
{
    self.cellModel =  model;
    NSString *tagTitle = [self.cellModel valueForKey:@"tagTitle"];
    if([tagTitle hasPrefix:@"#"]) {
            tagTitle = [tagTitle substringFromIndex:1];
    }
    self.tilleLb.text =  [tagTitle capitalizedString];
    
    if([self.cellModel valueForKey:@"type"] && [[self.cellModel valueForKey:@"type"] length]>0) {
        self.despLbl.text =  [self.cellModel valueForKey:@"type"];

    }else {
        self.despLbl.text =  @"Trending";
    }
    if([self.cellModel valueForKey:@"totalVideosViews"] && [[self.cellModel valueForKey:@"totalVideosViews"] length]>0) {
        self.viewsLbl.text =  [self.cellModel valueForKey:@"totalVideosViews"];
    }else {
    self.viewsLbl.text =  @"0";
    }
    [self.ctView reloadData];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *videoItems = [self.cellModel valueForKey:@"tagVideos"];
       NSInteger totalVideos = [[self.cellModel valueForKey:@"totalVideos"] intValue];

    if(totalVideos > videoItems.count && indexPath.row ==  videoItems.count)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(itemPickerModelDidViewMoreClicked:)])
        {
        [self.delegate itemPickerModelDidViewMoreClicked:self.cellModel];
        }
    }else
    {
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemPickerModelDidClicked:withClickIndex:)])
    {
        [self.delegate itemPickerModelDidClicked:[self.cellModel valueForKey:@"tagVideos"] withClickIndex:indexPath.row];
     
    }
    }
}

@end
