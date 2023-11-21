//
//  UICollectionView+SLHelper.h
//  Divineray
//
//  Created by ""  on 24/11/18.
//

#import <UIKit/UIKit.h>
@interface UICollectionView (SLHelper)
- (void)registerHeaderFooter;
- (void)registerCellWithNib:(Class)className withReusableId:(NSString *)reusableId;
- (void)registerReusableCellFooter:(Class)className withReusableId:(NSString *)reusableId;
- (void)registerReusableCellHeader:(Class)className withReusableId:(NSString *)reusableId;
- (void)registerCellWithNibHeader:(Class)className withReusableId:(NSString *)reusableId;
/**
 Configure the Properties for Playlist
 */
- (void)configurePlaylistProperties;
@end

