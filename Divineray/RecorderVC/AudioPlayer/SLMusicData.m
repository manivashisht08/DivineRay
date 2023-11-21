//
//  SLMusicData.m

#import "SLMusicData.h"

@implementation SLMusicData

- (instancetype)init {
    self = [super init];
    _musicPath = @"";
    _playerState = SLAudioStatePaused;
    return self;
}
@end
