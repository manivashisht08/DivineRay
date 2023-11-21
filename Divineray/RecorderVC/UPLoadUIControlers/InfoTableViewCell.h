//
//  InfoTableViewCell.h
//  Divineray
//
//  Created by     on 20/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InfoTableViewCell : UITableViewCell {
    
}
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UILabel *lblHint;
@property (weak, nonatomic) IBOutlet UITextField *txtField;

@end

NS_ASSUME_NONNULL_END
