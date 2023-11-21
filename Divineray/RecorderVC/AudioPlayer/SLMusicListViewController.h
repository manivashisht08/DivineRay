//
//  SLMusicListViewController.h


#import <UIKit/UIKit.h>

typedef void (^MusicIemCompletionBllock)(id musicPath, id fileTitle, id muisicId, BOOL isSucess);
@interface SLMusicListViewController : UIViewController

@property (copy, nonatomic)MusicIemCompletionBllock completionBlock;

@end

