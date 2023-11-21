//
//  SlikeDownloadManager.m
//  SlikeMediaDownload
//
//  Created by ""  on 30/11/18.
//  Copyright © 2018 "" . All rights reserved.
//

#import "SlikeDownloadManager.h"
#import "SLDownloadService.h"
#import "SlikeDownloadModel.h"
#import "SlikeCoreMediaAsset.h"
#import "SlikeDownloadConstants.h"
#import "SlikeMediaItem.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>


#define SLDownloadDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject \
stringByAppendingPathComponent:NSStringFromClass([self class])]

// use URL's last path component as the file's name

//#define SLFileName(URL) [URL lastPathComponent]
//#define SLFilePath(URL) [SLDownloadDirectory stringByAppendingPathComponent:SLFileName(URL)]

@interface SlikeDownloadManager() <NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *downloadSession;
@property (nonatomic, strong) SLDownloadService *downloadService;
@property (nonatomic, strong) NSString *userIDString;
@property (nonatomic, assign)id<SlikeDownloadManagerDelegate>delegate;
@end

@implementation SlikeDownloadManager

static BOOL disableBgDownloading = YES;

NSString * const kSlikeDownloadItemProgressKey           = @"slikedownloadItemProgressKey";
NSString * const kSlikeDownloadItemProgressNotification  = @"slikeDownloadItemProgressNotification";
NSString * const kSlikeDownloadItemsDeletedNotification  = @"slikeDownloadItemsDeletedNotification";
NSString * const kSlikeDownloadItemsDeletedKey           = @"slikeDownloadItemsDeletedKey";

#pragma mark - Main Methods
- (instancetype)init {
    [NSException raise:@"SingletonPattern"
                format:@"Cannot instantiate singleton using init method, must be use sharedManager."];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    [NSException raise:@"SingletonPattern"
                format:@"Cannot copy singleton using copy method, must be use sharedManager."];
    return nil;
}

+ (void)disableBackgroundDownloading {
    disableBgDownloading = YES;
}


#pragma mark - Lazy Load
- (NSURLSession *)downloadSession {
    if (!_downloadSession) {
        NSURLSessionConfiguration *backgroundConfigurationObject = nil;
        if (disableBgDownloading) {
            backgroundConfigurationObject = [NSURLSessionConfiguration  defaultSessionConfiguration];
            
        } else {
            backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"slike.ios.bgSessionConfiguration"];
            
        }
        backgroundConfigurationObject.sessionSendsLaunchEvents = YES;
        backgroundConfigurationObject.discretionary = NO;
        backgroundConfigurationObject.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _downloadSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject
                                                         delegate:self
                                                    delegateQueue:nil];
        
       //backgroundConfigurationObject.HTTPMaximumConnectionsPerHost = 10;
        
    }
    return _downloadSession;
}


+ (instancetype)sharedManager {
    static SlikeDownloadManager *downloadManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[self alloc] initManager];
    });
    return downloadManager;
}

- (void)attachDownloadsListener:(id<SlikeDownloadManagerDelegate>)listener {
    self.delegate = listener;
}

- (void)_createDownloadedDirectory {
    
    NSString *downloadDirectory = SLDownloadDirectory;
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:downloadDirectory isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [fileManager createDirectoryAtPath:downloadDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (instancetype)initManager {
    
    if (self = [super init]) {
        self.userIDString = @"com.klug.offline";
        //Create the download repository
        [self _createDownloadedDirectory];
        //Create the download service
        self.downloadService  = [[SLDownloadService alloc]init];
        //Set the download session
        self.downloadService.downloadsSession = self.downloadSession;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    
    return self;
}

- (void)setUserIdForDownloads:(NSString *)userId {
    self.userIDString = userId;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if(totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown Transfer size of data");
    }
    else {
        
        NSURL *originalURL = downloadTask.originalRequest.URL;
        SlikeDownloadModel* downloadModel = _downloadService.activeDownloads[originalURL];
        if (!downloadModel) {
            return;
        }
        NSString *fileSize = [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleFile];
        
        double downloadProgress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        downloadModel.asset.coreAsset.progress = downloadProgress;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _postNotificationForListeners:downloadModel.asset];
            if (downloadModel.progressBlock) {
                downloadModel.progressBlock(totalBytesWritten, [fileSize integerValue], downloadProgress);
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && error.code == -999) {
        //cancel task will call this delegate method and the error's code is -999
        return;
    }
    
    if (error) {
        
        NSURL *sourceURL = task.originalRequest.URL;
        if (!sourceURL) {
            return;
        }
        
        SlikeDownloadModel* downloadModel = _downloadService.activeDownloads[sourceURL];
        if (!downloadModel) {
            return;
        }
    
        // download has failed. Now need to save into database about this state
        downloadModel.asset.coreAsset.downloadingState =  SLDownloadStateFailed;
        [self _updateMediaItemStatusIntoRepository:downloadModel];
        
        downloadModel.asset.coreAsset.error = error;
        //Need to send the post the notification
        [self _postNotificationForListeners:downloadModel.asset];
        
        if (downloadModel.stateBlock) {
            downloadModel.stateBlock(SLDownloadStateFailed);
        }
        
        if (downloadModel.completionBlock) {
            downloadModel.completionBlock(NO, nil, error);
        }
        
        _downloadService.activeDownloads[sourceURL] = nil;
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.backgroundTransferCompletionHandler) {
            self.backgroundTransferCompletionHandler();
            self.backgroundTransferCompletionHandler = nil;
        }
    });
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSURL *sourceURL = downloadTask.originalRequest.URL;
    if (!sourceURL) {
        return;
    }
    
    SlikeDownloadModel* downloadModel = _downloadService.activeDownloads[sourceURL];
    if (!downloadModel) {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:SLFileName(sourceURL)];
    NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:_encodedFileNameForURL(sourceURL, _userIDString)];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    NSError *error=nil;
    if( [[NSFileManager defaultManager]copyItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:&error]) {
        
        //Need to store it some container
        downloadModel.asset.coreAsset.downloadingState = SLDownloadStateCompleted;
        downloadModel.asset.coreAsset.downloadedPath = filePath;
        downloadModel.asset.coreAsset.progress = 1.0;
        
        [self _updateMediaItemStatusIntoRepository:downloadModel];
        NSLog(@"FILE PATH = %@", filePath);
        
        //Need to send the post the notification
        [self _postNotificationForListeners:downloadModel.asset];
        
        if (downloadModel.stateBlock) {
            downloadModel.stateBlock(SLDownloadStateCompleted);
        }
        if (downloadModel.completionBlock) {
            downloadModel.completionBlock(YES, filePath, nil);
        }
        
        //Need to remove the file from download Queue
        _downloadService.activeDownloads[sourceURL] = nil;
        
    } else {
        
        downloadModel.asset.coreAsset.error = error;
        downloadModel.asset.coreAsset.downloadingState = SLDownloadStateFailed;
        [self _updateMediaItemStatusIntoRepository:downloadModel];
        
        //Need to send the post the notification
        [self _postNotificationForListeners:downloadModel.asset];
        
        if (downloadModel.stateBlock) {
            downloadModel.stateBlock(SLDownloadStateFailed);
        }
        
        if (downloadModel.completionBlock) {
            downloadModel.completionBlock(NO, nil, error);
        }
        
        //Need to remove the file from download Queue
        _downloadService.activeDownloads[sourceURL] = nil;
        
    }
}

- (void)downloadMedia:(SlikeMediaItem *)asset
                state:(void (^)(SLDownloadState state))state
             progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progress
           completion:(void (^)(BOOL success, NSString *filePath, NSError *error))completion {
    
    if (asset.coreAsset.downloadURL == nil) {
        NSLog(@"URL can not be nil, please pass the resource's URL which you want to download");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self isDownloadCompletedOfURL:asset.coreAsset.downloadURL]) { // if this URL has been downloaded
            if (state) {
                state(SLDownloadStateCompleted);
            }
            if (completion) {
                
                asset.coreAsset.downloadedPath = [self fileFullPathOfURL:asset.coreAsset.downloadURL];
                asset.coreAsset.progress = 1.0;
                asset.coreAsset.downloadingState = SLDownloadStateCompleted;
                
                completion(YES, [self fileFullPathOfURL:asset.coreAsset.downloadURL], nil);
                
                //send the notification for listeners
                [self _postNotificationForListeners:asset];
            }
            return;
        }
        
        if (![self _isItemAlreayAddedIntoQueue:asset.coreAsset.downloadURL]) {
            //Add item into Queue
            [self _addDownloadItemIntoQueue:asset withState:state progress:progress completion:completion];
        }
    });
}

- (BOOL) _isItemAlreayAddedIntoQueue:(NSURL *)URL {
    if(!URL){
        return NO;
    }
    SlikeDownloadModel* downloadModel = _downloadService.activeDownloads[URL];
    if (downloadModel) {
        return YES;
    }
    return NO;
}

/**
 Add item into downlaod Queue
 
 @param asset - Media Asset
 @param state - State Block
 @param progress - Progress Block
 @param completion - Completion Block
 */
- (void)_addDownloadItemIntoQueue:(SlikeMediaItem *)asset withState:(SLStateBlock)state
                         progress:(SLProgressBlock)progress
                       completion:(SLCompletionBlock)completion {
    
    SlikeDownloadModel* downloadModel = [[SlikeDownloadModel alloc]initWithAsset:asset];
    downloadModel.progressBlock = progress;
    downloadModel.completionBlock = completion;
    downloadModel.stateBlock = state;
    downloadModel.asset.coreAsset.downloadingState = SLDownloadStateDownloading;
    [self.downloadService startDownload:downloadModel];
    
    //Update the DataBase for the current Model
    [self _updateMediaItemStatusIntoRepository:downloadModel];
    [self _postNotificationForListeners:asset];
    
}

#pragma mark - Public Utility Methods Methods
- (BOOL)isDownloadCompletedOfURL:(NSURL *)URL {
    
    if (!URL) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:SLFileName(URL)];
    NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:_encodedFileNameForURL(URL, _userIDString)];
    
    BOOL hasDownloaded = [self _hasMediaItemCompletedDownloadOfURL:URL];
    if ([fileManager fileExistsAtPath:filePath] && hasDownloaded) {
        return YES;
    }
    return NO;
}

- (float)downloadProgressAtURL:(NSURL *)URL {
    if (!URL) {
        return 0;
    }
    SlikeDownloadModel* downloadModel = _downloadService.activeDownloads[URL];
    if (!downloadModel && downloadModel.asset) {
        return downloadModel.asset.coreAsset.progress;
    }
    return 0;
}

- (NSString *)fileFullPathOfURL:(NSURL *)URL {
    if (!URL) {
        return @"";
    }
    if ([URL.scheme containsString:@"http"]) {
        NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:_encodedFileNameForURL(URL, _userIDString)];
        return filePath;
    }
    
    NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:URL.lastPathComponent];
    return filePath;
}

- (NSInteger)fileSizeAtURL:(NSURL *)URL {
    if (!URL) {
        return 0;
    }
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self fileFullPathOfURL:URL] error:nil];
    if (!fileAttributes) {
        return 0;
    }
    return [fileAttributes[NSFileSize] integerValue];
}

#pragma mark- Private method
- (void) _removeMediaItemFromCache:(NSURL *)URL {
    
    //Delete from the Disk/Repository
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:SLFileName(URL)];
    NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:_encodedFileNameForURL(URL, _userIDString)];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

#pragma mark-  Post Notifications
/**
 Post the Notifications to listeners ...
 - Notification can be posted through the Broacast|Delegate
 @param mediaAsset - Media Asset
 */
- (void)_postNotificationForListeners:(SlikeMediaItem*)mediaAsset {
    
    if (mediaAsset) {
        if([self.delegate respondsToSelector:@selector(downloadMediaAssetProgress:)]) {
            [self.delegate downloadMediaAssetProgress:mediaAsset];
        }
        NSDictionary *progress = @ {
            kSlikeDownloadItemProgressKey : mediaAsset
        };
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kSlikeDownloadItemProgressNotification object:nil userInfo:progress];
    }
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    if (_downloadSession) {
        [self _cancelActiveDownloads];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [_downloadSession.configuration.URLCache removeAllCachedResponses];
    }
}

#pragma mark- DataBase Utilities
/**
 Update the item Status into repository
 @param downloadModel - Need to save at CoreDB or Some Places
 */
- (void)_updateMediaItemStatusIntoRepository:(SlikeDownloadModel *)downloadModel {
}

/**
 Has downloaded complete for the given Url. This will check into repository only.
 Need to ask from the download manager.
 This method is called from download manager also
 @param fileUrl - File URL
 @return - TRUE|FALSE
 */
- (BOOL)_hasMediaItemCompletedDownloadOfURL:(NSURL *)fileUrl {
    return YES;
}

#pragma mark - Utilty Method for getting the File name
NSString * _encodedFileNameForURL(NSURL *sourceURL , NSString *userId) {
    
    NSString *pathExtension = [sourceURL pathExtension];
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@",userId,[sourceURL absoluteString]];
    NSString *md5Filename = [SlikeDownloadManager md5HashForString:uniqueFileName];
    NSString *encodedFileName = [NSString stringWithFormat:@"%@.%@",md5Filename, pathExtension];
    return encodedFileName;
}

#pragma mark - Cancel Contents
- (void)cancelDownloadForAsset:(SlikeMediaItem *)asset cacheRemove:(BOOL)removeFromCache {
    [self cancelDownloadOfURL:asset.coreAsset.downloadURL cacheRemove:removeFromCache];
}

- (void)cancelDownloadOfURL:(NSURL *)URL cacheRemove:(BOOL)removeFromCache {
    
    if (!URL) {
        return;
    }
    SlikeDownloadModel* downloadModel = _downloadService.activeDownloads[URL];
    if (!downloadModel) {
        return;
    }
    
    downloadModel.asset.coreAsset.downloadingState = SLDownloadStateCanceled;
    downloadModel.asset.coreAsset.progress = 0.0;
    
    //Download has been canceled. Now need to remove it from the Database
    if (removeFromCache) {
        [self _removeMediaItemFromCache:downloadModel.asset.coreAsset.downloadURL];
    }
    
    //Need to send the post the notification
    [self _postNotificationForListeners:downloadModel.asset];
    
    if (downloadModel.stateBlock) {
        downloadModel.stateBlock(SLDownloadStateCanceled);
    }
    [_downloadService cancelDownload:downloadModel];
}
- (void)cancelActiveDownloadsAlsoCacheRemove:(BOOL)removeFromCache {
    if (_downloadService.activeDownloads.count == 0) {
        return;
    }
    [_downloadService.activeDownloads enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, SlikeDownloadModel * _Nonnull downloadModel, BOOL * _Nonnull stop) {
        [self cancelDownloadOfURL:downloadModel.asset.coreAsset.downloadURL cacheRemove:removeFromCache];
    }];
    
}

/**
 Cancel Active downloads
 */
- (void)_cancelActiveDownloads {
    if (_downloadService.activeDownloads.count == 0) {
        return;
    }
    
    [_downloadService.activeDownloads enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, SlikeDownloadModel * _Nonnull obj, BOOL * _Nonnull stop) {
        [self cancelDownloadOfURL:obj.asset.coreAsset.downloadURL cacheRemove:YES];
    }];
}

#pragma mark -  Delete All Contents from DISK and DATABASE
- (void)deleteFileOfURL:(NSURL *)URL {
    if (!URL) {
        return;
    }
    [self cancelDownloadOfURL:URL cacheRemove:NO];
    [self _removeMediaItemFromCache:URL];
}

- (void)deleteFileForAsset:(SlikeMediaItem *)asset {
    [self deleteFileOfURL:asset.coreAsset.downloadURL];
}


/**
 Delete the Files from repository, Cancel Active downloads, delete from the disk
 */
- (void)deleteAllCachedFilesAlsoFromDisk {
    
    [_downloadService.activeDownloads enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, SlikeDownloadModel * _Nonnull obj, BOOL * _Nonnull stop) {
         [self cancelDownloadOfURL:obj.asset.coreAsset.downloadURL cacheRemove:NO];
    }];
    
    //Delete from the Disk/Repository
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:SLDownloadDirectory error:nil];
    for (NSString *fileName in fileNames) {
        NSString *filePath = [SLDownloadDirectory stringByAppendingPathComponent:fileName];
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
}

- (void)deleteAllCachedFilesForCurrentUser {
    [_downloadService.activeDownloads enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, SlikeDownloadModel * _Nonnull obj, BOOL * _Nonnull stop) {
          [self cancelDownloadOfURL:obj.asset.coreAsset.downloadURL cacheRemove:NO];
    }];

}

- (void)appWillTerminate:(NSNotification *)notification {
    
    if (_downloadSession) {
        [_downloadService.activeDownloads enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, SlikeDownloadModel * _Nonnull obj, BOOL * _Nonnull stop) {
            [self cancelDownloadOfURL:obj.asset.coreAsset.downloadURL cacheRemove:NO];
        }];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [_downloadSession.configuration.URLCache removeAllCachedResponses];
    }
}

- (float)calculateActiveDownloadingItemsSize {
    
   __block float sizeForDiskInKb = 0;
    [_downloadService.activeDownloads enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, SlikeDownloadModel * _Nonnull downloadModel, BOOL * _Nonnull stop) {
       
        float bitrate = downloadModel.asset.coreAsset.bitrate;
        float durationInSeconds = downloadModel.asset.durationInMillSec/1000;
        sizeForDiskInKb += durationInSeconds *(bitrate/8);
    }];
    return sizeForDiskInKb;
}


+ (NSString *)md5HashForString:(NSString *)string {
    
    const char *cStr = [string UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end


