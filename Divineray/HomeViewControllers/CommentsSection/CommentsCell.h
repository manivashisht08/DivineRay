//
//  CommentsCell.h
//     
//
//  Created by     on 03/06/20.
//

#import <UIKit/UIKit.h>


@interface CommentsCell : UITableViewCell
{
    
}
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@end

