//
//  SLCollectionViewDataSource.h
//  Follo
//
//  Created by "" Rathor on 10/02/16.
//  Copyright © 2016 "" Rathor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^SLDataSourceConfigureBlock)(id cell, id item, NSIndexPath* indexPath);

@interface SLCollectionViewDataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource>

- (id)initWithItems:(NSMutableArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(SLDataSourceConfigureBlock)aConfigureCellBlock;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;



@end
