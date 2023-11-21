//
//  SLCollectionViewDataSource.m
//  Follo
//
//  Created by "" Rathor on 10/02/16.
//  Copyright © 2016 "" Rathor. All rights reserved.
//

#import "SLCollectionViewDataSource.h"

@interface SLCollectionViewDataSource ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) SLDataSourceConfigureBlock configureCellBlock;
@end


@implementation SLCollectionViewDataSource

- (id)init {
    return nil;
}

- (id)initWithItems:(NSMutableArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(SLDataSourceConfigureBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        
        self.items = anItems;
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.items[(NSUInteger) indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * offerCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier: self.cellIdentifier forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(offerCell, item, indexPath);
    return offerCell;
}

#pragma mark - collectionView delegate Implementation
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* collectionViewCell = (UICollectionViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(collectionViewCell, item, indexPath);
    return collectionViewCell;
}

@end
