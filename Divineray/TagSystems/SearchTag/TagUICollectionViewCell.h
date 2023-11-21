//
//  TagUICollectionViewCell.h
//  Divineray
//
//  Created by Ansh Kumat on 03/04/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TagUICollectionViewCell : UICollectionViewCell
    @property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *moreViewLbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoader;

@end

NS_ASSUME_NONNULL_END
