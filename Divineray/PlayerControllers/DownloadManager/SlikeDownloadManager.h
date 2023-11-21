//
//  SlikeDownloadManager.h
//  SlikeMediaDownload
//
//  Created by ""  on 30/11/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlikeDownloadConstants.h"

@class SlikeMediaItem;

@protocol SlikeDownloadManagerDelegate <NSObject>
- (void)downloadMediaAssetProgress:(id)mediaAsset;
@end

@interface SlikeDownloadManager : NSObject
+ (instancetype)sharedManager;

- (void)attachDownloadsListener:(id<SlikeDownloadManagerDelegate>)listener;

/**
 Need to set the User id.
 @param userId - User Id
 */
- (void)setUserIdForDownloads:(NSString *)userId;

/**
 Starts a file download action with URL, download state, download progress and download completion block.
 
 @param asset      A Slike Asset
 @param state      A block object to be executed when the download state changed.
 @param progress   A block object to be executed when the download progress changed.
 @param completion A block object to be executed when the download completion.
 */
- (void)downloadMedia:(SlikeMediaItem *)asset
                state:(void (^)(SLDownloadState state))state
             progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, double progress))progress
           completion:(void (^)(BOOL success, NSString *filePath, NSError *error))completion;

/**
 Has the file download for the given URL
 @param URL - Item URL
 @return - TRUE | FALSE
 */
- (BOOL)isDownloadCompletedOfURL:(NSURL *)URL;

/**
 Get the progress of Item at the URL
 @param URL - File URL
 @return - Progress
 */
- (float)downloadProgressAtURL:(NSURL *)URL;

/**
 Return the size of file at the URL
 @param URL - File URL
 @return - File Size
 */
- (NSInteger)fileSizeAtURL:(NSURL *)URL;

/**
 Returns File Full Path..
 @param URL - File URL
 @return - Path
 
 Note: In IOS 8 bove Path changes on every run
 */
- (NSString *)fileFullPathOfURL:(NSURL *)URL;

/**
 Cancle the download of the URL.
 */
- (void)cancelDownloadOfURL:(NSURL *)URL cacheRemove:(BOOL)removeFromCache;

/**
 Delete the file of the URL in the current cache files directory.
 */
- (void)deleteFileOfURL:(NSURL *)URL;

/**
 Cancle the download of asset.
 */
- (void)cancelDownloadForAsset:(SlikeMediaItem *)asset cacheRemove:(BOOL)removeFromCache;

/**
 Cancel All the Active downloads
 @param removeFromCache - Also Remove From the Cache
 */
- (void)cancelActiveDownloadsAlsoCacheRemove:(BOOL)removeFromCache;

#pragma mark - delete functionlity 

/**
 Delete the file of the asset in the current cache files directory.
 */
- (void)deleteFileForAsset:(SlikeMediaItem *)asset;

/**
 Delete all files from cache also from DISK
 */
- (void)deleteAllCachedFilesAlsoFromDisk;

/**
 Delete All the Cached files for the current User
 */
- (void)deleteAllCachedFilesForCurrentUser;

/*
 This should be called before accesing the shared instance . bydefault SDK uses the
 background session to download the contents
 
 // [SlikeDownloadManager disableBackgroundDownloading];
 */

/**
 Calculate the Items size that are being downloaded
 */
- (float)calculateActiveDownloadingItemsSize;

/**
 By default happens in background queue.
 */
+ (void)disableBackgroundDownloading;

/*
 - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
 [SlikeDownloadManager sharedManager].backgroundTransferCompletionHandler = completionHandler;
 }
 */
@property (nonatomic, copy) void (^backgroundTransferCompletionHandler)(void);


@end

