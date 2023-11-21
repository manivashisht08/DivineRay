//
//  DivinerayVideoMerger.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 04/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DivinerayVideoMerger : NSObject

+ (void)mergeRecordedVideosWithFileURLs:(NSArray *)videoFileURLs videoStoredPath:(NSString *)storedPath completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;


+ (void)mergeVideosWithFileURLs:(NSArray *)videoFileURLs videoStoredPath:(NSString *)storedPath
                     completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;
+ (void)gridMergeVideosWithFileURLs:(NSArray *)videoFileURLs
                 andVideoResolution:(CGSize)resolution
                         completion:(void(^)(NSURL *mergedVideoURL, NSError *error))completion;


/**
 *  Save it to your local photo library based on the video url address
 */
+ (void)writeSLVideoToPhotoLibrary:(nonnull NSURL *)url completion:(void(^)(BOOL status))completion;




@end


