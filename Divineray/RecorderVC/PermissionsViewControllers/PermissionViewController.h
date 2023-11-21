//
//  PermissionViewController.h
//  Vivek Dharmai
//
//  Created by     on 28/02/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SLPermissionViewController <NSObject>
@required
- (void)isPermissionDelegate:(NSInteger)isType;
@end

@interface PermissionViewController : UIViewController
{
    
}

@property(nonatomic,assign) BOOL isAudioAuthorize;
@property(nonatomic,assign) BOOL isVideoAuthorize;
@property (nonatomic, assign) id<SLPermissionViewController>delegate;

@end

NS_ASSUME_NONNULL_END
