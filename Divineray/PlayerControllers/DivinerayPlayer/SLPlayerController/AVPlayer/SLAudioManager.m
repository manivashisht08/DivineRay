//
//  SLAudioManager.m
//  SLPlayer
//
//  Created by Single on 09/01/2017.
//  Copyright © 2017 single. All rights reserved.
//

#import "SLAudioManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import "SLPlayerMacro.h"


static int const max_frame_size = 4096;
static int const max_chan = 2;

typedef struct
{
    AUNode node;
    AudioUnit audioUnit;
}
SLAudioNodeContext;

typedef struct
{
    AUGraph graph;
    SLAudioNodeContext converterNodeContext;
    SLAudioNodeContext mixerNodeContext;
    SLAudioNodeContext outputNodeContext;
    AudioStreamBasicDescription commonFormat;
}
SLAudioOutputContext;

@interface SLAudioManager ()

{
    float * _outData;
}

@property (nonatomic, assign) SLAudioOutputContext * outputContext;

@property (nonatomic, weak) id handlerTarget;
@property (nonatomic, copy) SLAudioManagerInterruptionHandler interruptionHandler;
@property (nonatomic, copy) SLAudioManagerRouteChangeHandler routeChangeHandler;

@property (nonatomic, assign) BOOL registered;
@property (nonatomic, strong) AVAudioSession * audioSession;
@property (nonatomic, strong) NSError * error;
@property (nonatomic, strong) NSError * warning;

@end

@implementation SLAudioManager

+ (instancetype)manager
{
    static SLAudioManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self->_outData = (float *)calloc(max_frame_size * max_chan, sizeof(float));
        self.audioSession = [AVAudioSession sharedInstance];
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(audioSessionInterruptionHandler:) name:AVAudioSessionInterruptionNotification object:nil];
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(audioSessionRouteChangeHandler:) name:AVAudioSessionRouteChangeNotification object:nil];
    }
    return self;
}

- (void)setHandlerTarget:(id)handlerTarget
            interruption:(SLAudioManagerInterruptionHandler)interruptionHandler
             routeChange:(SLAudioManagerRouteChangeHandler)routeChangeHandler
{
    self.handlerTarget = handlerTarget;
    self.interruptionHandler = interruptionHandler;
    self.routeChangeHandler = routeChangeHandler;
}

- (void)removeHandlerTarget:(id)handlerTarget
{
    if (self.handlerTarget == handlerTarget || !self.handlerTarget) {
        self.handlerTarget = nil;
        self.interruptionHandler = nil;
        self.routeChangeHandler = nil;
    }
}

- (void)audioSessionInterruptionHandler:(NSNotification *)notification
{
    if (self.handlerTarget && self.interruptionHandler) {
        AVAudioSessionInterruptionType avType = [[notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
        SLAudioManagerInterruptionType type = SLAudioManagerInterruptionTypeBegin;
        if (avType == AVAudioSessionInterruptionTypeEnded) {
            type = SLAudioManagerInterruptionTypeEnded;
        }
        SLAudioManagerInterruptionOption option = SLAudioManagerInterruptionOptionNone;
        id avOption = [notification.userInfo objectForKey:AVAudioSessionInterruptionOptionKey];
        if (avOption) {
            AVAudioSessionInterruptionOptions temp = [avOption unsignedIntegerValue];
            if (temp == AVAudioSessionInterruptionOptionShouldResume) {
                option = SLAudioManagerInterruptionOptionShouldResume;
            }
        }
        self.interruptionHandler(self.handlerTarget, self, type, option);
    }
}

- (void)audioSessionRouteChangeHandler:(NSNotification *)notification
{
    if (self.handlerTarget && self.routeChangeHandler) {
        AVAudioSessionRouteChangeReason avReason = [[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
        switch (avReason) {
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            {
                self.routeChangeHandler(self.handlerTarget, self, SLAudioManagerRouteChangeReasonOldDeviceUnavailable);
            }
                break;
            default:
                break;
        }
        
    }
}


- (BOOL)registerAudioSession
{
    if (!self.registered) {
        if ([self setupAudioUnit]) {
            self.registered = YES;
        }
    }
    [self.audioSession setActive:YES error:nil];
    return self.registered;
}

- (void)unregisterAudioSession
{
    if (self.registered) {
        self.registered = NO;
        OSStatus result = AUGraphUninitialize(self.outputContext->graph);
        self.warning = checkError(result, @"graph uninitialize error");
        if (self.warning) {
            [self delegateWarningCallback];
        }
        result = AUGraphClose(self.outputContext->graph);
        self.warning = checkError(result, @"graph close error");
        if (self.warning) {
            [self delegateWarningCallback];
        }
        result = DisposeAUGraph(self.outputContext->graph);
        self.warning = checkError(result, @"graph dispose error");
        if (self.warning) {
            [self delegateWarningCallback];
        }
        if (self.outputContext) {
            free(self.outputContext);
            self.outputContext = NULL;
        }
    }
}

- (BOOL)setupAudioUnit
{
    OSStatus result;
    UInt32 audioStreamBasicDescriptionSize = sizeof(AudioStreamBasicDescription);;
    
    self.outputContext = (SLAudioOutputContext *)malloc(sizeof(SLAudioOutputContext));
    memset(self.outputContext, 0, sizeof(SLAudioOutputContext));
    
    result = NewAUGraph(&self.outputContext->graph);
    self.error = checkError(result, @"create  graph error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    AudioComponentDescription converterDescription;
    converterDescription.componentType = kAudioUnitType_FormatConverter;
    converterDescription.componentSubType = kAudioUnitSubType_AUConverter;
    converterDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    result = AUGraphAddNode(self.outputContext->graph, &converterDescription, &self.outputContext->converterNodeContext.node);
    self.error = checkError(result, @"graph add converter node error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    AudioComponentDescription mixerDescription;
    mixerDescription.componentType = kAudioUnitType_Mixer;
 
    mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    result = AUGraphAddNode(self.outputContext->graph, &mixerDescription, &self.outputContext->mixerNodeContext.node);
    self.error = checkError(result, @"graph add mixer node error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    AudioComponentDescription outputDescription;
    outputDescription.componentType = kAudioUnitType_Output;
    outputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    result = AUGraphAddNode(self.outputContext->graph, &outputDescription, &self.outputContext->outputNodeContext.node);
    self.error = checkError(result, @"graph add output node error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AUGraphOpen(self.outputContext->graph);
    self.error = checkError(result, @"open graph error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AUGraphConnectNodeInput(self.outputContext->graph,
                            self.outputContext->converterNodeContext.node,
                            0,
                            self.outputContext->mixerNodeContext.node,
                            0);
    self.error = checkError(result, @"graph connect converter and mixer error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AUGraphConnectNodeInput(self.outputContext->graph,
                                     self.outputContext->mixerNodeContext.node,
                                     0,
                                     self.outputContext->outputNodeContext.node,
                                     0);
    self.error = checkError(result, @"graph connect converter and mixer error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AUGraphNodeInfo(self.outputContext->graph,
                             self.outputContext->converterNodeContext.node,
                             &converterDescription,
                             &self.outputContext->converterNodeContext.audioUnit);
    self.error = checkError(result, @"graph get converter audio unit error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AUGraphNodeInfo(self.outputContext->graph,
                             self.outputContext->mixerNodeContext.node,
                             &mixerDescription,
                             &self.outputContext->mixerNodeContext.audioUnit);
    self.error = checkError(result, @"graph get minxer audio unit error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AUGraphNodeInfo(self.outputContext->graph,
                             self.outputContext->outputNodeContext.node,
                             &outputDescription,
                             &self.outputContext->outputNodeContext.audioUnit);
    self.error = checkError(result, @"graph get output audio unit error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    AURenderCallbackStruct converterCallback;
    converterCallback.inputProc = renderCallback;
    converterCallback.inputProcRefCon = (__bridge void *)(self);
    result = AUGraphSetNodeInputCallback(self.outputContext->graph,
                                         self.outputContext->converterNodeContext.node,
                                         0,
                                         &converterCallback);
    self.error = checkError(result, @"graph add converter input callback error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AudioUnitGetProperty(self.outputContext->outputNodeContext.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input, 0,
                                  &self.outputContext->commonFormat,
                                  &audioStreamBasicDescriptionSize);
    self.warning = checkError(result, @"get hardware output stream format error");
    if (self.warning) {
        [self delegateWarningCallback];
    } else {
        if (self.audioSession.sampleRate != self.outputContext->commonFormat.mSampleRate) {
            self.outputContext->commonFormat.mSampleRate = self.audioSession.sampleRate;
            result = AudioUnitSetProperty(self.outputContext->outputNodeContext.audioUnit,
                                          kAudioUnitProperty_StreamFormat,
                                          kAudioUnitScope_Input,
                                          0,
                                          &self.outputContext->commonFormat,
                                          audioStreamBasicDescriptionSize);
            self.warning = checkError(result, @"set hardware output stream format error");
            if (self.warning) {
                [self delegateWarningCallback];
            }
        }
    }
    
    result = AudioUnitSetProperty(self.outputContext->converterNodeContext.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &self.outputContext->commonFormat,
                                  audioStreamBasicDescriptionSize);
    self.error = checkError(result, @"graph set converter input format error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AudioUnitSetProperty(self.outputContext->converterNodeContext.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &self.outputContext->commonFormat,
                                  audioStreamBasicDescriptionSize);
    self.error = checkError(result, @"graph set converter output format error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AudioUnitSetProperty(self.outputContext->mixerNodeContext.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &self.outputContext->commonFormat,
                                  audioStreamBasicDescriptionSize);
    self.error = checkError(result, @"graph set converter input format error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AudioUnitSetProperty(self.outputContext->mixerNodeContext.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &self.outputContext->commonFormat,
                                  audioStreamBasicDescriptionSize);
    self.error = checkError(result, @"graph set converter output format error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    result = AudioUnitSetProperty(self.outputContext->mixerNodeContext.audioUnit,
                                  kAudioUnitProperty_MaximumFramesPerSlice,
                                  kAudioUnitScope_Global,
                                  0,
                                  &max_frame_size,
                                  sizeof(max_frame_size));
    self.warning = checkError(result, @"graph set mixer max frames per slice size error");
    if (self.warning) {
        [self delegateWarningCallback];
    }
    
    result = AUGraphInitialize(self.outputContext->graph);
    self.error = checkError(result, @"graph initialize error");
    if (self.error) {
        [self delegateErrorCallback];
        return NO;
    }
    
    return YES;
}

- (OSStatus)renderFrames:(UInt32)numberOfFrames ioData:(AudioBufferList *)ioData
{
    if (!self.registered) {
        return noErr;
    }
    
    for (int iBuffer = 0; iBuffer < ioData->mNumberBuffers; iBuffer++) {
        memset(ioData->mBuffers[iBuffer].mData, 0, ioData->mBuffers[iBuffer].mDataByteSize);
    }
    
    if (self.playing && self.delegate)
    {
        [self.delegate audioManager:self outputData:self->_outData numberOfFrames:numberOfFrames numberOfChannels:self.numberOfChannels];
        
        UInt32 numBytesPerSample = self.outputContext->commonFormat.mBitsPerChannel / 8;
        if (numBytesPerSample == 4) {
            float zero = 0.0;
            for (int iBuffer = 0; iBuffer < ioData->mNumberBuffers; iBuffer++) {
                int thisNumChannels = ioData->mBuffers[iBuffer].mNumberChannels;
                for (int iChannel = 0; iChannel < thisNumChannels; iChannel++) {
                    vDSP_vsadd(self->_outData + iChannel,
                               self.numberOfChannels,
                               &zero,
                               (float *)ioData->mBuffers[iBuffer].mData,
                               thisNumChannels,
                               numberOfFrames);
                }
            }
        }
        else if (numBytesPerSample == 2)
        {
            float scale = (float)INT16_MAX;
            vDSP_vsmul(self->_outData, 1, &scale, self->_outData, 1, numberOfFrames * self.numberOfChannels);
            
            for (int iBuffer = 0; iBuffer < ioData->mNumberBuffers; iBuffer++) {
                int thisNumChannels = ioData->mBuffers[iBuffer].mNumberChannels;
                for (int iChannel = 0; iChannel < thisNumChannels; iChannel++) {
                    vDSP_vfix16(self->_outData + iChannel,
                                self.numberOfChannels,
                                (SInt16 *)ioData->mBuffers[iBuffer].mData + iChannel,
                                thisNumChannels,
                                numberOfFrames);
                }
            }
        }
    }
    
    return noErr;
}

- (void)playWithDelegate:(id<SLAudioManagerDelegate>)delegate
{
    self->_delegate = delegate;
    [self play];
}

- (void)play
{
    if (!self->_playing) {
        if ([self registerAudioSession]) {
            OSStatus result = AUGraphStart(self.outputContext->graph);
            self.error = checkError(result, @"graph start error");
            if (self.error) {
                [self delegateErrorCallback];
            } else {
                self->_playing = YES;
            }
        }
    }
}

- (void)pause
{
    if (self->_playing) {
        OSStatus result = AUGraphStop(self.outputContext->graph);
        self.error = checkError(result, @"graph stop error");
        if (self.error) {
            [self delegateErrorCallback];
        }
        self->_playing = NO;
    }
}

- (float)volume
{
    if (self.registered) {
        AudioUnitParameterID param;
        param = kMultiChannelMixerParam_Volume;
        AudioUnitParameterValue volume;
        OSStatus result = AudioUnitGetParameter(self.outputContext->mixerNodeContext.audioUnit,
                                                param,
                                                kAudioUnitScope_Input,
                                                0,
                                                &volume);
        self.warning = checkError(result, @"graph get mixer volum error");
        if (self.warning) {
            [self delegateWarningCallback];
        } else {
            return volume;
        }
    }
    return 1.f;
}

- (void)setVolume:(float)volume
{
    if (self.registered) {
        AudioUnitParameterID param;
        param = kMultiChannelMixerParam_Volume;
        OSStatus result = AudioUnitSetParameter(self.outputContext->mixerNodeContext.audioUnit,
                                                param,
                                                kAudioUnitScope_Input,
                                                0,
                                                volume,
                                                0);
        self.warning = checkError(result, @"graph set mixer volum error");
        if (self.warning) {
            [self delegateWarningCallback];
        }
    }
}

- (Float64)samplingRate
{
    if (!self.registered) {
        return 0;
    }
    Float64 number = self.outputContext->commonFormat.mSampleRate;
    if (number > 0) {
        return number;
    }
    return (Float64)self.audioSession.sampleRate;
}

- (UInt32)numberOfChannels
{
    if (!self.registered) {
        return 0;
    }
    UInt32 number = self.outputContext->commonFormat.mChannelsPerFrame;
    if (number > 0) {
        return number;
    }
    return (UInt32)self.audioSession.outputNumberOfChannels;
}

- (void)delegateErrorCallback
{
    if (self.error) {
        SLPlayerLog(@"SLAudioManager did error : %@", self.error);
    }
}

- (void)delegateWarningCallback
{
    if (self.warning) {
        SLPlayerLog(@"SLAudioManager did warning : %@", self.warning);
    }
}

- (void)dealloc
{
    [self unregisterAudioSession];
    if (self->_outData) {
        free(self->_outData);
        self->_outData = NULL;
    }
    self->_playing = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SLPlayerLog(@"SLAudioManager release");
}

static NSError * checkError(OSStatus result, NSString * domain)
{
    if (result == noErr) return nil;
    NSError * error = [NSError errorWithDomain:domain code:result userInfo:nil];
    return error;
}

static OSStatus renderCallback(void * inRefCon,
                               AudioUnitRenderActionFlags * ioActionFlags,
                               const AudioTimeStamp * inTimeStamp,
                               UInt32 inOutputBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList * ioData)
{
    SLAudioManager * manager = (__bridge SLAudioManager *)inRefCon;
    return [manager renderFrames:inNumberFrames ioData:ioData];
}

@end
