//
//  SLCollectionViewFlowLayout.h
//  Divineray
//
//  Created by ""  on 24/11/18.
//

#import <UIKit/UIKit.h>
@interface SLCollectionViewFlowLayout : UICollectionViewFlowLayout

- (id)initVideosFlowLayout;
- (id)initLiveVideosFlowLayout;
- (id)initVodPlaylistFlowLayout;
- (id)initTagVideosFlowLayoutTwo:(NSInteger)height;
- (id)initTagVideosFlowLayoutThree;
-(id)initTagHeaderVideosFlowLayout:(NSInteger)height;
-(id)initTagHeaderVideosDispFlowLayout:(NSInteger)height;
-(id)initAppleTagHeaderVideosDispFlowLayout:(NSInteger)height;
@end

