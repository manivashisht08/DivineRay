//
//  SLPlayerDecoder.h
//  SLPlayer
//
//  Created by Single on 03/01/2017.
//  Copyright © 2017 single. All rights reserved.
//

#import <Foundation/Foundation.h>

// decode type
typedef NS_ENUM(NSUInteger, SLDecoderType) {
    SLDecoderTypeError,
    SLDecoderTypeAVPlayer,
    SLDecoderTypeFFmpeg,
};

// media format
typedef NS_ENUM(NSUInteger, SLMediaFormat) {
    SLMediaFormatError,
    SLMediaFormatUnknown,
    SLMediaFormatMP3,
    SLMediaFormatMPEG4,
    SLMediaFormatMOV,
    SLMediaFormatFLV,
    SLMediaFormatM3U8,
    SLMediaFormatRTMP,
    SLMediaFormatRTSP,
};

@interface SLPlayerDecoder : NSObject

+ (instancetype)decoderByDefault;
+ (instancetype)decoderByAVPlayer;
+ (instancetype)decoderByFFmpeg;

@property (nonatomic, assign) BOOL hardwareAccelerateEnableForFFmpeg;  // default is YES

@property (nonatomic, assign) SLDecoderType decodeTypeForUnknown;      // default is SGDecodeTypeFFmpeg
@property (nonatomic, assign) SLDecoderType decodeTypeForMP3;          // default is SGDecodeTypeAVPlayer
@property (nonatomic, assign) SLDecoderType decodeTypeForMPEG4;        // default is SGDecodeTypeAVPlayer
@property (nonatomic, assign) SLDecoderType decodeTypeForMOV;          // default is SGDecodeTypeAVPlayer
@property (nonatomic, assign) SLDecoderType decodeTypeForFLV;          // default is SGDecodeTypeFFmpeg
@property (nonatomic, assign) SLDecoderType decodeTypeForM3U8;         // default is SGDecodeTypeAVPlayer
@property (nonatomic, assign) SLDecoderType decodeTypeForRTMP;         // default is SGDecodeTypeFFmpeg
@property (nonatomic, assign) SLDecoderType decodeTypeForRTSP;         // default is SGDecodeTypeFFmpeg

- (SLMediaFormat)mediaFormatForContentURL:(NSURL *)contentURL;
- (SLDecoderType)decoderTypeForContentURL:(NSURL *)contentURL;


#pragma mark - FFmpeg optioins

- (NSDictionary *)FFmpegFormatContextOptions;
- (void)setFFmpegFormatContextOptionIntValue:(int64_t)value forKey:(NSString *)key;
- (void)setFFmpegFormatContextOptionStringValue:(NSString *)value forKey:(NSString *)key;
- (void)removeFFmpegFormatContextOptionForKey:(NSString *)key;

- (NSDictionary *)FFmpegCodecContextOptions;
- (void)setFFmpegCodecContextOptionIntValue:(int64_t)value forKey:(NSString *)key;
- (void)setFFmpegCodecContextOptionStringValue:(NSString *)value forKey:(NSString *)key;
- (void)removeFFmpegCodecContextOptionForKey:(NSString *)key;

@end
