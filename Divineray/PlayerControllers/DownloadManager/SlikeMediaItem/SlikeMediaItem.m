//
//  SlikeMediaItem.m
//  SlikePlayer
//
//  Created by ""  on 28/12/18.
//

#import "SlikeMediaItem.h"
#import "SlikeCoreMediaAsset.h"

@interface SlikeMediaItem ()
@property (strong, nonatomic) NSString *uniqueItemId;
@end

@implementation SlikeMediaItem

- (instancetype)init {
    
    self = [super init];
    _slikeId = @"";
    _title = @"";
    _subTitle = @"";
    _playlistTitle = @"";
    _durationInMillSec = 0;
    _imageURLString = @"";
    _publishDate = @"";
    _downloadAccess = YES;
    _artist =  @"";
    _coreAsset = [[SlikeCoreMediaAsset alloc]init];
    return self;
}


@end
