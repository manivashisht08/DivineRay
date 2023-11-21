//
//  SLPlayerNetworkManager.m
//  
//
//  Created by ""  on 15/06/20.
//  Copyright © 2020 Timesinternet ltd. All rights reserved.
//

#import "SLPlayerNetworkManager.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <CoreFoundation/CoreFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


typedef NS_ENUM(NSInteger, NetworkType) {
    NetworkWiFi = 1,
    Network2G,
    Network3G,
    Network4G,
    NetworkNone
};


extern NSString *kSlikeReachabilityChangedNotification;


@interface SLPlayerNetworkManager() {
    
}
@property (strong, nonatomic) APHReachability *reachability;
@end

@implementation SLPlayerNetworkManager

- (id)init {
    if (self = [super init]) {
        self.reachability = [APHReachability reachabilityForInternetConnection];
        [_reachability startNotifier];
    }
    return self;
}

/**
 Creats the shared instance of DataProvider
 @return - Singleton class  instance
 */
+ (instancetype)sharedNetworkMonitor {
    
    static SLPlayerNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

- (BOOL)isNetworkReachible {
    
    if ([[APHReachability reachabilityForInternetConnection] currentReachabilityStatus] == APNotReachable) {
        return NO;
    }
    return  YES;
}

@end

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


NSString *kSlikeReachabilityChangedNotification = @"kNetworkSlikeReachabilityChangedNotification";
static NSString *__strNetwork = @"NONE";
static NSInteger __ncnt = 0;


#pragma mark - Supporting functions

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
    /*  DLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
     (flags & kSCNetworkReachabilityFlagsIsWWAN)                ? 'W' : '-',
     (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
     
     (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
     (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
     (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
     (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
     (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
     (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
     (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
     comment
     );
     */
}


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [APHReachability class]], @"info was wrong class in ReachabilityCallback");
    
    APHReachability* noteObject = (__bridge APHReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kSlikeReachabilityChangedNotification object: noteObject];
}


#pragma mark - Reachability implementation

@implementation APHReachability
{
    SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
    APHReachability* returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL)
    {
        returnValue= [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    
    APHReachability* returnValue = NULL;
    
    if (reachability != NULL)
    {
        returnValue = [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityForInternetConnection
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

+(NSInteger) getNetworkTypeEnum
{
    NSString *str = [APHReachability getNetworkType];
    if([str isEqualToString:@"WIFI"]) return 1;
    else if([str isEqualToString:@"4G"]) return 4;
    else if([str isEqualToString:@"EDGE"] || [str isEqualToString:@"GPRS"] || [str isEqualToString:@"CDMA1x"]) return 2;
    else if([str isEqualToString:@"WCDMA"] || [str isEqualToString:@"HSUPA"] || [str isEqualToString:@"HSDPA"] || [str isEqualToString:@"CDMAEVDORev0"]|| [str isEqualToString:@"CDMAEVDORev1"] || [str isEqualToString:@"CDMAEVDORev2"] || [str isEqualToString:@"HRPD"] ) return 3;
    return 0;
}

+(NSString *) getNetworkType
{
    if([__strNetwork isEqualToString:@"NONE"] || __ncnt > 2)
    {
        APHReachability *reachability = [APHReachability reachabilityForInternetConnection];
        APNetworkStatus status = [reachability currentReachabilityStatus];
        if(status == APNotReachable)
        {
            __strNetwork = @"NONE";
        }
        else if (status == APReachableViaWiFi)
        {
            __strNetwork = @"WIFI";
        }
        else if (status == APReachableViaWWAN)
        {
            //connection type
            CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
            NSString *carrier = [[netinfo subscriberCellularProvider] carrierName];
            if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                __strNetwork = @"GPRS";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
                __strNetwork = @"EDGE";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
                __strNetwork = @"WCDMA";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
                __strNetwork = @"HSDPA";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
                __strNetwork = @"HSUPA";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
                __strNetwork = @"CDMA1x";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
                __strNetwork = @"CDMAEVDORev0";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
                __strNetwork = @"CDMAEVDORev1";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
                __strNetwork = @"CDMAEVDORev2";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
                __strNetwork = @"HRPD";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                __strNetwork = @"4G";
            }
            else __strNetwork = carrier;
            
        }
        __ncnt = 0;
    }
    __ncnt++;
    return __strNetwork;
}

#pragma mark reachabilityForLocalWiFi
//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.
//+ (instancetype)reachabilityForLocalWiFi



#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}


- (void)stopNotifier
{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}


- (void)dealloc
{
    [self stopNotifier];
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
}


#pragma mark - Network Flag Handling

- (APNetworkStatus)SlikeNetworkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
    PrintReachabilityFlags(flags, "SlikeNetworkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return APNotReachable;
    }
    
    APNetworkStatus returnValue = APNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = APReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = APReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = APReachableViaWWAN;
    }
    
    return returnValue;
}


- (BOOL)connectionRequired
{
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}


- (APNetworkStatus)currentReachabilityStatus {
    NSAssert(_reachabilityRef != NULL, @"currentSlikeNetworkStatus called with NULL SCNetworkReachabilityRef");
    APNetworkStatus returnValue = APNotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        returnValue = [self SlikeNetworkStatusForFlags:flags];
    }
    
    return returnValue;
}

@end
