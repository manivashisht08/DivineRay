//
//  CommentViewController.h
//
//
//  Created by     on 03/06/20.
//

#import <UIKit/UIKit.h>

@protocol CommentDelagete <NSObject>
@required
- (void)updateCommentCount:(NSString*)comments;
- (void)openProfileCall:(NSDictionary*)userInfo;
@end

typedef void (^CommentsCompletionBllock)(BOOL isSucess);
@interface CommentViewController : UIViewController{
    
}
@property (copy, nonatomic)CommentsCompletionBllock completionBlock;
@property (nonatomic, assign) id<CommentDelagete>delegate;
@property(nonatomic,strong) NSDictionary *dict;
@end

