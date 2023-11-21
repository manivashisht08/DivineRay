//
//  CommentsCell.m
//     
//
//  Created by     on 03/06/20.
//

#import "CommentsCell.h"

@implementation CommentsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _userImageView.image = [UIImage imageNamed:@"user"];
    _userImageView.backgroundColor =  [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
    _userImageView.layer.cornerRadius = _userImageView.frame.size.width/2;
    _userImageView.layer.borderWidth = 1.0;
    _userImageView.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8].CGColor;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnProfile:(id)sender {
}
@end
