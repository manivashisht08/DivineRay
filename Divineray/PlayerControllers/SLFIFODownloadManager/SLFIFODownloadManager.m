
#import "SLFIFODownloadManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#define SRDownloadDirectory self.cacheFilesDirectory ?: [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject \
stringByAppendingPathComponent:@"SlikeDownloadManager"]

//#define SRFileName(URL) [URL lastPathComponent] // use URL's last path component as the file's name

#define SRFilePath(URL) [SRDownloadDirectory stringByAppendingPathComponent:SRFileName(URL)]

#define SRFilesTotalLengthPlistPath [SRDownloadDirectory stringByAppendingPathComponent:@"SRFilesTotalLength.plist"]

@interface SLFIFODownloadManager() <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *downloadSession;

@property (nonatomic, strong) NSMutableDictionary *downloadModels; // a dictionary contains downloading and waiting models

@property (nonatomic, strong) NSMutableArray *downloadingModels; // a array contains models which are downloading now

@property (nonatomic, strong) NSMutableArray *waitingModels; // a array contains models which are waiting for download

@property (nonatomic, strong) NSMutableDictionary *filesTotalLengthPlist;
@property (nonatomic, strong) NSString *userIDString;
@end

@implementation SLFIFODownloadManager

#pragma mark - Lazy Load

- (NSURLSession *)downloadSession {
    if (!_downloadSession) {
        _downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                         delegate:self
                                                    delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _downloadSession;
}

- (NSMutableDictionary *)downloadModels {
    if (!_downloadModels) {
        _downloadModels = [NSMutableDictionary dictionary];
    }
    return _downloadModels;
}

- (NSMutableArray *)downloadingModels {
    if (!_downloadingModels) {
        _downloadingModels = [NSMutableArray array];
    }
    return _downloadingModels;
}

- (NSMutableArray *)waitingModels {
    if (!_waitingModels) {
        _waitingModels = [NSMutableArray array];
    }
    return _waitingModels;
}

- (NSMutableDictionary *)filesTotalLengthPlist {
    if (!_filesTotalLengthPlist) {
        _filesTotalLengthPlist = [NSMutableDictionary dictionaryWithContentsOfFile:SRFilesTotalLengthPlistPath];
        if (!_filesTotalLengthPlist) {
            _filesTotalLengthPlist = [NSMutableDictionary dictionary];
        }
    }
    return _filesTotalLengthPlist;
}

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

+ (instancetype)sharedManager {
    static SLFIFODownloadManager *downloadManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[self alloc] initManager];
    });
    return downloadManager;
}

- (instancetype)initManager {
    if (self = [super init]) {
        _maxConcurrentCount = -1;
        self.userIDString = @"com.klug.offline";
        _waitingQueueMode = SRWaitingQueueModeFIFO;
        
        NSString *downloadDirectory = SRDownloadDirectory;
        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExists = [fileManager fileExistsAtPath:downloadDirectory isDirectory:&isDirectory];
        if (!isExists || !isDirectory) {
            [fileManager createDirectoryAtPath:downloadDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)download:(NSURL *)URL
        destPath:(NSString *)destPath
           state:(void (^)(SLDownloadState state))state
        progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progress
      completion:(void (^)(BOOL success, NSString *filePath, NSError *error))completion
{
    if(!URL) return;
    //NSAssert(URL != nil, @"URL can not be nil, please pass the resource's URL which you want to download");
    if ([self isDownloadCompletedOfURL:URL]) { // if this URL has been downloaded
        if (state) {
            state(SLDownloadStateCompleted);
        }
        if (completion) {
            completion(YES, [self fileFullPathOfURL:URL], nil);
        }
        return;
    }
    
    
    SLFIFODownloadModel *downloadModel = self.downloadModels[_encodedFileForURL(URL,_userIDString)];
    if (downloadModel) { // if the download model of this URL has been added in downloadModels
        return;
    }
    
    // Range:
    // bytes=x-y ==  x byte ~ y byte
    // bytes=x-  ==  x byte ~ end
    // bytes=-y  ==  head ~ y byte
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:URL];
    [requestM setValue:[NSString stringWithFormat:@"bytes=%ld-", (long)[self hasDownloadedLength:URL]] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *dataTask = [self.downloadSession dataTaskWithRequest:requestM];
    dataTask.taskDescription = _encodedFileForURL(URL,_userIDString);
    
    // init a SLFIFODownloadModel object
    downloadModel = [[SLFIFODownloadModel alloc] init];
    downloadModel.dataTask = dataTask;
    downloadModel.outputStream = [NSOutputStream outputStreamToFileAtPath:[self fileFullPathOfURL:URL] append:YES];
    downloadModel.URL = URL;
    downloadModel.destPath = destPath;
    downloadModel.state = state;
    downloadModel.progress = progress;
    downloadModel.completion = completion;
    self.downloadModels[dataTask.taskDescription] = downloadModel;
    
    SLDownloadState downloadState;
    if ([self canResumeDownload]) {
        [self.downloadingModels addObject:downloadModel];
        [dataTask resume];
        downloadState = SLDownloadStateDownloading;
    } else {
        [self.waitingModels addObject:downloadModel];
        downloadState = SLDownloadStateWaiting;
    }
    if (downloadModel.state) {
        downloadModel.state(downloadState);
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    SLFIFODownloadModel *downloadModel = self.downloadModels[dataTask.taskDescription];
    if (!downloadModel) {
        return;
    }
    [downloadModel openOutputStream];
    
    NSInteger totalLength = response.expectedContentLength + [self hasDownloadedLength:downloadModel.URL];
    downloadModel.totalLength = totalLength;
    self.filesTotalLengthPlist[_encodedFileForURL(downloadModel.URL,_userIDString)] = @(totalLength);
    [self.filesTotalLengthPlist writeToFile:SRFilesTotalLengthPlistPath atomically:YES];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    SLFIFODownloadModel *downloadModel = self.downloadModels[dataTask.taskDescription];
    if (!downloadModel) {
        return;
    }
    [downloadModel.outputStream write:data.bytes maxLength:data.length];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.progress) {
            NSUInteger receivedSize = [self hasDownloadedLength:downloadModel.URL];
            NSUInteger expectedSize = downloadModel.totalLength;
            if (expectedSize != 0) {
                downloadModel.progress(receivedSize, expectedSize, 1.0 * receivedSize / expectedSize);
            }
        }
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && error.code == -999) { // cancel task will call this delegate method and the error's code is -999
        return;
    }
    SLFIFODownloadModel *downloadModel = self.downloadModels[task.taskDescription];
    if (!downloadModel) {
        return;
    }
    [downloadModel closeOutputStream];
    [self.downloadModels removeObjectForKey:task.taskDescription];
    [self.downloadingModels removeObject:downloadModel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            if (downloadModel.state) {
                downloadModel.state(SLDownloadStateFailed);
            }
            if (downloadModel.completion) {
                downloadModel.completion(NO, nil, error);
            }
        } else {
            if ([self isDownloadCompletedOfURL:downloadModel.URL]) {
                NSString *fullPath = [self fileFullPathOfURL:downloadModel.URL];
                NSString *destPath = downloadModel.destPath;
                if (destPath) {
                    [[NSFileManager defaultManager] moveItemAtPath:fullPath toPath:destPath error:nil];
                }
                if (downloadModel.state) {
                    downloadModel.state(SLDownloadStateCompleted);
                }
                if (downloadModel.completion) {
                    downloadModel.completion(YES, destPath ?: fullPath, nil);
                }
            } else {
                NSError *error = [NSError errorWithDomain:@"file download incomplete" code:0 userInfo:nil];
                if (downloadModel.state) {
                    downloadModel.state(SLDownloadStateFailed);
                }
                if (downloadModel.completion) {
                    downloadModel.completion(NO, nil, error);
                }
            }
        }
        [self resumeNextDowloadModel];
    });
}

#pragma mark - Assist Methods

- (BOOL)canResumeDownload {
    if (self.maxConcurrentCount == -1) {
        return YES;
    }
    if (self.downloadingModels.count < self.maxConcurrentCount) {
        return YES;
    }
    return NO;
}

- (NSInteger)totalLength:(NSURL *)URL {
    if (self.filesTotalLengthPlist.count == 0) {
        return 0;
    }
    if (!self.filesTotalLengthPlist[_encodedFileForURL(URL,_userIDString)]) {
        return 0;
    }
    return [self.filesTotalLengthPlist[_encodedFileForURL(URL,_userIDString)] integerValue];
}

- (NSInteger)hasDownloadedLength:(NSURL *)URL {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self fileFullPathOfURL:URL] error:nil];
    if (!fileAttributes) {
        return 0;
    }
    return [fileAttributes[NSFileSize] integerValue];
}

- (void)resumeNextDowloadModel {
    if (self.maxConcurrentCount == -1) { // no limit so no waiting for download models
        return;
    }
    if (self.waitingModels.count == 0) { // no waiting for download models
        return;
    }
    SLFIFODownloadModel *downloadModel;
    switch (self.waitingQueueMode) {
        case SRWaitingQueueModeFIFO:
            downloadModel = self.waitingModels.firstObject;
            break;
        case SRWaitingQueueModeLIFO:
            downloadModel = self.waitingModels.lastObject;
            break;
    }
    [self.waitingModels removeObject:downloadModel];
    
    SLDownloadState downloadState;
    if ([self canResumeDownload]) {
        [self.downloadingModels addObject:downloadModel];
        [downloadModel.dataTask resume];
        downloadState = SLDownloadStateWaiting;
    } else {
        [self.waitingModels addObject:downloadModel];
        downloadState = SLDownloadStateWaiting;
    }
    if (downloadModel.state) {
        downloadModel.state(downloadState);
    }
}

#pragma mark - Public Methods

- (BOOL)isDownloadCompletedOfURL:(NSURL *)URL {
    NSInteger totalLength = [self totalLength:URL];
    if (totalLength == 0) {
        return NO;
    }
    if ([self hasDownloadedLength:URL] != totalLength) {
        return NO;
    }
    return YES;
}

- (void)setCacheFilesDirectory:(NSString *)cacheFilesDirectory {
    _cacheFilesDirectory = cacheFilesDirectory;
    
    if (!cacheFilesDirectory) {
        return;
    }
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:cacheFilesDirectory isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [fileManager createDirectoryAtPath:cacheFilesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - Downloads

- (void)suspendDownloadOfURL:(NSURL *)URL {
    [self suspendDownloadOfURL:URL resumeNext:YES];
}

- (void)suspendDownloadOfURL:(NSURL *)URL resumeNext:(BOOL)flag {
    SLFIFODownloadModel *downloadModel = self.downloadModels[_encodedFileForURL(URL,_userIDString)];
    if (!downloadModel) {
        return;
    }
    if (downloadModel.state) {
       // downloadModel.state(SRDownloadStateSuspended);
    }
    
    if ([self.waitingModels containsObject:downloadModel]) {
        [self.waitingModels removeObject:downloadModel];
    } else {
        [downloadModel.dataTask suspend];
        [self.downloadingModels removeObject:downloadModel];
    }
    
    if (flag) {
        [self resumeNextDowloadModel];
    }
}

- (void)suspendDownloads {
    if (self.downloadModels.count == 0) {
        return;
    }
    NSArray *downloadModels = self.downloadModels.allValues;
    for (SLFIFODownloadModel *downloadModel in downloadModels) {
        [self suspendDownloadOfURL:downloadModel.URL resumeNext:NO];
    }
}

- (void)resumeDownloadOfURL:(NSURL *)URL {
    SLFIFODownloadModel *downloadModel = self.downloadModels[_encodedFileForURL(URL,_userIDString)];
    if (!downloadModel) {
        return;
    }
    SLDownloadState downloadState;
    if ([self canResumeDownload]) {
        [self.downloadingModels addObject:downloadModel];
        [downloadModel.dataTask resume];
        downloadState = SLDownloadStateDownloading;
    } else {
        [self.waitingModels addObject:downloadModel];
        downloadState = SLDownloadStateWaiting;
    }
    if (downloadModel.state) {
        downloadModel.state(downloadState);
    }
}

- (void)resumeDownloads {
    if (self.downloadModels.count == 0) {
        return;
    }
    NSArray *downloadModels = self.downloadModels.allValues;
    for (SLFIFODownloadModel *downloadModel in downloadModels) {
        [self resumeDownloadOfURL:downloadModel.URL];
    }
}

- (void)cancelDownloadOfURL:(NSURL *)URL {
    [self cancelDownloadOfURL:URL resumeNext:YES];
}

- (void)cancelDownloadOfURL:(NSURL *)URL resumeNext:(BOOL)flag {
    SLFIFODownloadModel *downloadModel = self.downloadModels[_encodedFileForURL(URL,_userIDString)];
    if (!downloadModel) {
        return;
    }
    [downloadModel closeOutputStream];
    [downloadModel.dataTask cancel];
    
    if (downloadModel.state) {
        downloadModel.state(SLDownloadStateCanceled);
    }
    
    if ([self.waitingModels containsObject:downloadModel]) {
        [self.waitingModels removeObject:downloadModel];
    } else {
        [self.downloadingModels removeObject:downloadModel];
    }
    [self.downloadModels removeObjectForKey:_encodedFileForURL(URL,_userIDString)];
    
    if (flag) {
        [self resumeNextDowloadModel];
    }
}
    
- (void)cancelDownloads {
    if (self.downloadModels.count == 0) {
        return;
    }
    NSArray *downloadModels = self.downloadModels.allValues;
    for (SLFIFODownloadModel *downloadModel in downloadModels) {
        [self cancelDownloadOfURL:downloadModel.URL resumeNext:NO];
    }
}

#pragma mark - Files

- (NSString *)fileFullPathOfURL:(NSURL *)URL {
    if (!URL) {
        return @"";
    }
    if ([URL.scheme containsString:@"http"]) {
        NSString *filePath = [SRDownloadDirectory stringByAppendingPathComponent:_encodedFileForURL(URL, _userIDString)];
        return filePath;
    }
    
    NSString *filePath = [SRDownloadDirectory stringByAppendingPathComponent:URL.lastPathComponent];
    return filePath;
}

- (CGFloat)hasDownloadedProgressOfURL:(NSURL *)URL {
    if ([self isDownloadCompletedOfURL:URL]) {
        return 1.0;
    }
    if ([self totalLength:URL] == 0) {
        return 0.0;
    }
    return 1.0 * [self hasDownloadedLength:URL] / [self totalLength:URL];
}

- (void)deleteFileOfURL:(NSURL *)URL {
    [self cancelDownloadOfURL:URL];
    
    [self.filesTotalLengthPlist removeObjectForKey:_encodedFileForURL(URL,_userIDString)];
    [self.filesTotalLengthPlist writeToFile:SRFilesTotalLengthPlistPath atomically:YES];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [SRDownloadDirectory stringByAppendingPathComponent:_encodedFileForURL(URL,_userIDString)];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)deleteFiles {
    [self cancelDownloads];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:SRDownloadDirectory error:nil];
    for (NSString *fileName in fileNames) {
        NSString *filePath = [SRDownloadDirectory stringByAppendingPathComponent:fileName];
        [fileManager removeItemAtPath:filePath error:nil];
    }
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

#pragma mark - Utilty Method for getting the File name
NSString * _encodedFileForURL(NSURL *sourceURL , NSString *userId) {
    
    NSString *pathExtension = [sourceURL pathExtension];
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@",userId,[sourceURL absoluteString]];
    NSString *md5Filename = [SLFIFODownloadManager md5HashForString:uniqueFileName];
    NSString *encodedFileName = [NSString stringWithFormat:@"%@.%@",md5Filename, pathExtension];
    return encodedFileName;
}

@end
