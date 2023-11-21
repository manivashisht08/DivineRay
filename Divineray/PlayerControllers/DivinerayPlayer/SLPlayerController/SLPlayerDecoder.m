//
//  SLPlayerDecoder.m
//  SLPlayer
//
//  Created by  on 03/01/2017.
//  Copyright © 2017 single. All rights reserved.
//

#import "SLPlayerDecoder.h"

@interface SLPlayerDecoder ()

@property (nonatomic, strong) NSMutableDictionary * formatContextOptions;
@property (nonatomic, strong) NSMutableDictionary * codecContextOptions;

@end

@implementation SLPlayerDecoder

+ (instancetype)decoderByDefault
{
    SLPlayerDecoder * decoder = [[self alloc] init];
    decoder.decodeTypeForUnknown   = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForMP3       = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForMPEG4     = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForMOV       = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForFLV       = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForM3U8      = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForRTMP      = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForRTSP      = SLDecoderTypeFFmpeg;
    return decoder;
}

+ (instancetype)decoderByAVPlayer
{
    SLPlayerDecoder * decoder = [[self alloc] init];
    decoder.decodeTypeForUnknown   = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForMP3       = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForMPEG4     = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForMOV       = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForFLV       = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForM3U8      = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForRTMP      = SLDecoderTypeAVPlayer;
    decoder.decodeTypeForRTSP      = SLDecoderTypeAVPlayer;
    return decoder;
}

+ (instancetype)decoderByFFmpeg
{
    SLPlayerDecoder * decoder = [[self alloc] init];
    decoder.decodeTypeForUnknown   = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForMP3       = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForMPEG4     = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForMOV       = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForFLV       = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForM3U8      = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForRTMP      = SLDecoderTypeFFmpeg;
    decoder.decodeTypeForRTSP      = SLDecoderTypeFFmpeg;
    return decoder;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.hardwareAccelerateEnableForFFmpeg = YES;
        [self configFFmpegOptions];
    }
    return self;
}

- (SLMediaFormat)mediaFormatForContentURL:(NSURL *)contentURL
{
    if (!contentURL) return SLMediaFormatError;
    
    NSString * path;
    if (contentURL.isFileURL) {
        path = contentURL.path;
    } else {
        path = contentURL.absoluteString;
    }
    path = [path lowercaseString];
    
    if ([path hasPrefix:@"rtmp:"])
    {
        return SLMediaFormatRTMP;
    }
    else if ([path hasPrefix:@"rtsp:"])
    {
        return SLMediaFormatRTSP;
    }
    else if ([path containsString:@".flv"])
    {
        return SLMediaFormatFLV;
    }
    else if ([path containsString:@".mp4"])
    {
        return SLMediaFormatMPEG4;
    }
    else if ([path containsString:@".mp3"])
    {
        return SLMediaFormatMP3;
    }
    else if ([path containsString:@".m3u8"])
    {
        return SLMediaFormatM3U8;
    }
    else if ([path containsString:@".mov"])
    {
        return SLMediaFormatMOV;
    }
    return SLMediaFormatUnknown;
}

- (SLDecoderType)decoderTypeForContentURL:(NSURL *)contentURL
{
    SLMediaFormat mediaFormat = [self mediaFormatForContentURL:contentURL];
    switch (mediaFormat) {
        case SLMediaFormatError:
            return SLDecoderTypeError;
        case SLMediaFormatUnknown:
            return self.decodeTypeForUnknown;
        case SLMediaFormatMP3:
            return self.decodeTypeForMP3;
        case SLMediaFormatMPEG4:
            return self.decodeTypeForMPEG4;
        case SLMediaFormatMOV:
            return self.decodeTypeForMOV;
        case SLMediaFormatFLV:
            return self.decodeTypeForFLV;
        case SLMediaFormatM3U8:
            return self.decodeTypeForM3U8;
        case SLMediaFormatRTMP:
            return self.decodeTypeForRTMP;
        case SLMediaFormatRTSP:
            return self.decodeTypeForRTSP;
    }
}


#pragma mark - ffmpeg opstions

- (void)configFFmpegOptions
{
    self.formatContextOptions = [NSMutableDictionary dictionary];
    self.codecContextOptions = [NSMutableDictionary dictionary];
    
    [self setFFmpegFormatContextOptionStringValue:@"SLPlayer" forKey:@"user-agent"];
    [self setFFmpegFormatContextOptionIntValue:20 * 1000 * 1000 forKey:@"timeout"];
    [self setFFmpegFormatContextOptionIntValue:1 forKey:@"reconnect"];
}

- (NSDictionary *)FFmpegFormatContextOptions
{
    return [self.formatContextOptions copy];
}

- (void)setFFmpegFormatContextOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self.formatContextOptions setValue:@(value) forKey:key];
}

- (void)setFFmpegFormatContextOptionStringValue:(NSString *)value forKey:(NSString *)key
{
    [self.formatContextOptions setValue:value forKey:key];
}

- (void)removeFFmpegFormatContextOptionForKey:(NSString *)key
{
    [self.formatContextOptions removeObjectForKey:key];
}

- (NSDictionary *)FFmpegCodecContextOptions
{
    return [self.codecContextOptions copy];
}

- (void)setFFmpegCodecContextOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self.codecContextOptions setValue:@(value) forKey:key];
}

- (void)setFFmpegCodecContextOptionStringValue:(NSString *)value forKey:(NSString *)key
{
    [self.codecContextOptions setValue:value forKey:key];
}

- (void)removeFFmpegCodecContextOptionForKey:(NSString *)key
{
    [self.codecContextOptions removeObjectForKey:key];
}

@end
