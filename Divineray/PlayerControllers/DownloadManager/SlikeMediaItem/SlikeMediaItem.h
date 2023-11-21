//
//  SlikeMediaItem.h
//  SlikePlayer
//
//  Created by ""  on 28/12/18.
//

#import <Foundation/Foundation.h>

@class SlikeCoreMediaAsset;

@interface SlikeMediaItem : NSObject

/**
 Slike Id
 */
@property (strong, nonatomic) NSString *slikeId;

/**
 Title of Track
 */
@property (strong, nonatomic) NSString *title;

/**
 SubTitle of Track
 */
@property (strong, nonatomic) NSString *subTitle;

/**
 Title of the Playlist
 */
@property (strong, nonatomic) NSString *playlistTitle;

/**
 Media Section
 */
@property (nonatomic, strong) NSString *section;
/**
 artist
 */
@property (nonatomic, strong) NSString *artist;

/**
 Track duration in Milleconds
 */
@property (assign, nonatomic) NSInteger durationInMillSec;

/**
 Thumnail url String
 */
@property (strong, nonatomic) NSString *imageURLString;

/**
 Publish date of track
 */
@property (strong, nonatomic) NSString *publishDate;

/**
 Whether user is alowed for download or not
 //By Default : TRUE
 */
@property (assign, nonatomic) BOOL downloadAccess;

/**
 This Property is for intarnal Use Only. No need to modify the instance
 */

@property (strong, nonatomic, readonly) NSString *uniqueItemId;

@property (strong, nonatomic)SlikeCoreMediaAsset *coreAsset;


@end
