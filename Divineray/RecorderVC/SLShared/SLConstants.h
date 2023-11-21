//
//  SLConstants.h
//  Vivek Dharmai
//
//  Created by Vivek Dharmai Rathor on 19/11/18.
//
#ifndef SLConstants_h
#define SLConstants_h

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, MovingDirection) {
    MovingDirectionInit = 0,
    MovingDirectionUpSide = 1,
    MovingDirectionDownSide
    
};

static NSString *const kHomeRefreshContentsNotification = @"HomeRefreshContentsNotification";
static NSString *const kStopHomeRefreshContentsNotification = @"StopHomeRefreshContentsNotification";
static NSString *const kStopHomeRefreshContentsNotificationLive = @"StopHomeRefreshContentsNotificationLive";

static NSString *const kRefresMyFeedshContentsNotification = @"RefresMyFeedshContentsNotification";

static NSString *const kRefreshLoginContentsContentsNotification = @"kRefreshLoginContentsContentsNotification";

static NSString *const kNetworkErrorNotificationLive = @"NetworkErrorNotificationLive";
static NSString *const kRefreshContentsNotificationLive = @"RefreshContentsNotificationLive";

static NSString *const kNetworkErrorNotification = @"NetworkErrorNotification";
static NSString *const kRefreshContentsNotification = @"RefreshContentsNotification";
static NSString *const kPhotoFooterViewIdentifier = @"PhotoFooterViewIdentifier";
static NSString *const kOfferHeaderViewIdentifier = @"offerHeaderCollectionView";
static NSString *const kOfferHeaderViewIdentifierTag = @"SLTagCollectionReusableView";

typedef void(^CellButtonClickedBlock)(id model);

#endif /* SLConstants_h */
