//
//  SLMusicData.h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, SLAudioState) {
    SLAudioStateLoading = 0,
    SLAudioStatePlaying,
    SLAudioStatePaused
};


@interface SLMusicData : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* muisicId;
@property (nonatomic, strong) NSString* musicPath;
@property (nonatomic, strong) NSString* iconPath;
@property (nonatomic, strong) NSString* soundUrlString;
@property (nonatomic, strong) NSString* duration;
@property (nonatomic, strong) NSString* category;
@property (nonatomic, assign) SLAudioState playerState;
@property (nonatomic,assign) BOOL isSelected;

@end

