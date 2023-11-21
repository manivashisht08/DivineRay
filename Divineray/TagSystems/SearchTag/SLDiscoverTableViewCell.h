//
//  SLDiscoverTableViewCell.h
//  Divineray
//
//  Created by Ansh Kumat on 08/04/19.
//

#import <UIKit/UIKit.h>

@protocol SLDiscoverTableViewCellDelegate <NSObject>
- (void)itemPickerModelDidClicked:(NSArray*)infoArray withClickIndex:(NSInteger)index;
- (void)itemPickerModelDidViewMoreClicked:(NSDictionary*)model;

@end

@interface SLDiscoverTableViewCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource>
{
}
@property (nonatomic, assign) id<SLDiscoverTableViewCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIButton *viewActionBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLine;
@property (weak, nonatomic) IBOutlet UILabel *hashLbl;
@property (weak, nonatomic) IBOutlet UILabel *viewsLbl;
@property (weak, nonatomic) IBOutlet UILabel *tilleLb;
@property (weak, nonatomic) IBOutlet UILabel *despLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *ctView;
-(void)scrollToTopCollectionView;
-(void)updateCellData:(NSDictionary*)model;
@property(nonatomic,strong) NSDictionary *cellModel;
@end
