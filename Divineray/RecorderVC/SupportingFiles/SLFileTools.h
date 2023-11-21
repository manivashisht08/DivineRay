
#import <Foundation/Foundation.h>

@interface SLFileTools : NSObject

+ (NSString *)documentsPath;
+ (NSString *)libraryPath;
+ (NSString *)productPath:(NSString*)filename;
+ (NSString *)fullpathOfFilename:(NSString *)filename;
+ (BOOL) fileIsExists:(NSString*) checkFile;
+ (int)moveFile:(NSString*)srcPath toPath:(NSString *)targetPath;
+ (NSString *)fullLibraryPathOfFilename:(NSString *)filename;
+ (int)createFileAtPAth:(NSString*) path;
+ (BOOL)deleteFileAtPath:(NSString*) path;
+ (NSString*)createDirectoryInLibrarys:(NSString* )directoryName;

//This Will Create the Directory where all the recorded video will be stored
+ (NSArray*)getFileListIndirectory:(NSString*)dirPath;

+ (BOOL)createDirectoryInDocuments:(NSString* )directoryName;

+ (NSString *)getVideoMergeFilePathString;
+ (NSString *)getVideoSegmentFilePath:(NSInteger)sengment;
+ (NSString *)getMp4FilePath;
+ (NSString *)getDraftFilePathString;
+ (NSString *)getDrafPlistPathString;
+ (NSString *)uniquePath;
+ (NSString *)getDrafImageFolderPathString;
+ (void)deleteRecordedVideo;
+ (void)deleteCachedData;
@end
