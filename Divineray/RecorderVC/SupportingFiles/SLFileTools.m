//
//  SLFileTools.m
//  Created by "".
//

#import "SLFileTools.h"
#import "SLGlobalShared.h"

@implementation SLFileTools

+(NSString *)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+(NSString *)libraryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+(NSString *) productPath:(NSString*)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@""];
    return  path;
}

+(NSString *)fullpathOfFilename:(NSString *)filename {
    NSString *documentsPath = [self documentsPath];
    return [documentsPath stringByAppendingPathComponent:filename];
    
}

+ (NSString *)fullLibraryPathOfFilename:(NSString *)filename {
    NSString *librarypath = [self libraryPath];
    return [librarypath stringByAppendingPathComponent:filename];
}

+ (BOOL)fileIsExists:(NSString*) checkFile {
    if([[NSFileManager defaultManager]fileExistsAtPath:checkFile]){
        return true;
    }
    return  false;
}

+(int)createFileAtPAth:(NSString*) path {
    if([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        return 0;
    }
    if ([[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
        return 1;
    }
    return  -1;
}

+(BOOL) deleteFileAtPath:(NSString*) path {
    
    if(![[NSFileManager defaultManager]fileExistsAtPath:path]){
        return true;
    }
    return  [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+(int) CopyFileToDocument:(NSString*)FileName{
    NSString *appFileName =[self fullpathOfFilename:FileName];

    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isExist = [fm fileExistsAtPath:appFileName];
    if (!isExist) {
        NSString *backupDbPath = [[NSBundle mainBundle]
                                  pathForResource:FileName
                                  ofType:@""];
        
        BOOL cp = [fm copyItemAtPath:backupDbPath toPath:appFileName error:nil];

        return cp;
        
    } else {
        return  -1;
    }
}


+(int) moveFile:(NSString*) srcPath toPath:(NSString *)targetPath {
    if(![self fileIsExists:srcPath]){
        return -1;
    }
    if ([self fileIsExists:targetPath]) {
        return -2;
    }
    return [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:targetPath error:nil];
}



+(NSString*)createDirectoryInLibrarys:(NSString* )directoryName {
    
    NSString *documets = [self libraryPath];
    NSString *targetpath = [documets stringByAppendingPathComponent:directoryName];
    if ([[NSFileManager defaultManager] createDirectoryAtPath:targetpath withIntermediateDirectories:YES attributes:nil error:nil]) {
        return targetpath;
        
    } else {
        return nil;
    }
}

+ (NSArray*)getFileListIndirectory:(NSString*) dirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:dirPath] error:&error];
    return fileList;
}

+ (BOOL)createDirectoryInDocuments:(NSString* )directoryName {
    
    NSString *documets = [self documentsPath];
    NSString *targetpath = [documets stringByAppendingPathComponent:directoryName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:targetpath isDirectory:&isDir];
    BOOL bCreateDir = NO;
    if(!(isDirExist && isDir)) {
        bCreateDir = [fileManager createDirectoryAtPath:targetpath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"Unable to create the path");
        }
    }
    return bCreateDir;
}

+ (NSString *)getVideoMergeFilePathString {
    NSString *tempPath = [self documentsPath];
    NSString* path = [tempPath stringByAppendingPathComponent:KLUG_VIDEO_FOLDER];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mov"];
    return fileName;
}

+ (NSString *)getVideoSegmentFilePath:(NSInteger)sengment {
  return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/Movie%lu.mov",(unsigned long)sengment]];
}

+ (NSString *)getMp4FilePath {
    
    NSString *tempPath = [self documentsPath];
    NSString *path  = [tempPath stringByAppendingPathComponent:KLUG_VIDEO_FOLDER];
    NSString *outputURL = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-slklug.mp4", [[NSUUID UUID] UUIDString]]];
        NSFileManager *manager=[NSFileManager defaultManager];
    [manager removeItemAtPath:outputURL error:nil];
    return outputURL;

}

+ (NSString *)getDraftFilePathString {
    NSString *tempPath = [self documentsPath];
    NSString* path = [tempPath stringByAppendingPathComponent:KLUG_DRAFT_FOLDER];
    
    NSString *nowTimeStr  = [SLFileTools uniquePath];
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"draft.mov"];
    return fileName;
}

+ (NSString *)getDrafPlistPathString {
    NSString *tempPath = [self documentsPath];
    NSString* path = [tempPath stringByAppendingPathComponent:KLUG_DRAFT_FOLDER];
    return [path stringByAppendingPathComponent:@"SRDrafts.plist"];
}

+(NSString *)uniquePath {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    return nowTimeStr;
}

+ (NSString *)getDrafImageFolderPathString {
    NSString *tempPath = [self documentsPath];
    NSString* path = [tempPath stringByAppendingPathComponent:KLUG_DRAFT_FOLDER];
    return path;
}

+ (void)deleteRecordedVideo {
    NSString *tempPath = [self documentsPath];
    NSString* path = [tempPath stringByAppendingPathComponent:KLUG_VIDEO_FOLDER];
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
}

+ (void)deleteShootVideo {
    NSString *tempPath = [self documentsPath];
    NSString* path = [tempPath stringByAppendingPathComponent:@"shootVideoTempDoc"];
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
}

+ (void)deleteCachedData {
    [SLFileTools deleteRecordedVideo];
    [SLFileTools deleteShootVideo];
    
}



@end
