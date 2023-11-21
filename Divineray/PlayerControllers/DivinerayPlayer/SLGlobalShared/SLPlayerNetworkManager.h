//
//  SLPlayerNetworkManager.h
//  
//
//  Created by ""  on 15/06/20.
//  Copyright © 2020 Timesinternet ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    APNotReachable = 0,
    APReachableViaWiFi,
    APReachableViaWWAN
} APNetworkStatus;


NS_ASSUME_NONNULL_BEGIN

@interface SLPlayerNetworkManager : NSObject
+ (instancetype)sharedNetworkMonitor;
- (BOOL)isNetworkReachible;
@end

@interface APHReachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

+(NSInteger) getNetworkTypeEnum;
+(NSString *) getNetworkType;

#pragma mark reachabilityForLocalWiFi
//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.
//+ (instancetype)reachabilityForLocalWiFi;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)startNotifier;
- (void)stopNotifier;

- (APNetworkStatus)currentReachabilityStatus;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)connectionRequired;

@end




NS_ASSUME_NONNULL_END
