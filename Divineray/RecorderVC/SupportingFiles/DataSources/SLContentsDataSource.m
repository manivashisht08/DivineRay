//
//  SLContentsDataSource.m
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 08/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import "SLContentsDataSource.h"
#import "SLFilterData.h"
#import "SLGlobalShared.h"

@interface SLContentsDataSource()

@property (strong, nonatomic) NSMutableArray *audioArray;
@end


@implementation SLContentsDataSource

- (instancetype)init {
    self = [super init];
    _audioArray = [[NSMutableArray alloc]init];
    return self;
}

+ (instancetype)sharedContentsManager {
    
    static SLContentsDataSource *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//All the Filters
- (NSArray*)getAllFiltersCollection {
    
    
    SLFilterData* filter0 = [[SLFilterData alloc] init];
    filter0.name = @"No Filter";
    filter0.filterImage = [UIImage imageNamed:@"no_filter.png"];
    filter0.fillterName = @"LFGPUImageEmptyFilter";
    filter0.isSelected = YES;
    
    SLFilterData* filter1 = [[SLFilterData alloc] init];
    filter1.name = @"Beautify";
    filter1.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2"];
    filter1.fillterName = @"GPUImageBeautifyFilter";
    
    
    SLFilterData* filter2 = [self createWithName:@"Amatorka" andFlieName:@"GPUImageAmatorkaFilter" andValue:nil];
    
    SLFilterData* filter3 = [self createWithName:@"MissEtikate" andFlieName:@"GPUImageMissEtikateFilter" andValue:nil];
    
    SLFilterData* filter4 = [self createWithName:@"Sepia" andFlieName:@"GPUImageSepiaFilter" andValue:nil];
    
    SLFilterData* filter5 = [self createWithName:@"Sketch" andFlieName:@"GPUImageSketchFilter" andValue:nil];
    
    SLFilterData* filter6 = [self createWithName:@"SoftElegance" andFlieName:@"GPUImageSoftEleganceFilter" andValue:nil];
    
    SLFilterData* filter7 = [self createWithName:@"Toon" andFlieName:@"GPUImageToonFilter" andValue:nil];
    
    SLFilterData* filter8 = [[SLFilterData alloc] init];
    filter8.name = @"Saturation0";
    filter8.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter0"];
    filter8.fillterName = @"GPUImageSaturationFilter";
    filter8.value = @"0";
    
    SLFilterData* filter9 = [[SLFilterData alloc] init];
    filter9.name = @"Saturation2";
    filter9.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2"];
    filter9.fillterName = @"GPUImageSaturationFilter";
    filter9.value = @"2";
    
    //Adding the New Filters  only  for the R&D purpose
    SLFilterData* filter10 = [[SLFilterData alloc] init];
    filter10.name = @"Wave";
    filter10.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2"];
    filter10.fillterName = @"GPUImageWaveFilter";
    filter10.value = @"4";
    
    
    SLFilterData* filter11 = [[SLFilterData alloc] init];
    filter11.name = @"Blur";
    filter11.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter11.fillterName = @"GPUImageBoxBlurFilter";
    
    SLFilterData* filter12 = [[SLFilterData alloc] init];
    filter12.name = @"Space";
    filter12.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter12.fillterName = @"GPUImageCGAColorspaceFilter";
    
    SLFilterData* filter13 = [[SLFilterData alloc] init];
    filter13.name = @"Invert";
    filter13.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter13.fillterName = @"GPUImageColorInvertFilter";
    
    SLFilterData* filter14 = [[SLFilterData alloc] init];
    filter14.name = @"EdgeDetection";
    filter14.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter14.fillterName = @"GPUImageDirectionalSobelEdgeDetectionFilter";
    
    
    SLFilterData* filter15 = [[SLFilterData alloc] init];
    filter15.name = @"Emboss";
    filter15.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter15.fillterName = @"GPUImageEmbossFilter";
    
    SLFilterData* filter17 = [[SLFilterData alloc] init];
    filter17.name = @"Laplacian";
    filter17.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter17.fillterName = @"GPUImageLaplacianFilter";
    
    SLFilterData* filter18 = [[SLFilterData alloc] init];
    filter18.name = @"Detection";
    filter18.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter18.fillterName = @"GPUImagePrewittEdgeDetectionFilter";
    
    SLFilterData* filter19 = [[SLFilterData alloc] init];
    filter19.name = @"Gamma";
    filter19.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter19.fillterName = @"GPUImageGammaFilter";
    filter19.value = @"2.5f";
    
    SLFilterData* filter20 = [[SLFilterData alloc] init];
    filter20.name = @"Posterize";
    filter20.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter20.fillterName = @"GPUImagePosterizeFilter";
    filter20.value = @"4.0f";
    
    
    SLFilterData* filter21 = [[SLFilterData alloc] init];
    filter21.name = @"Luminance";
    filter21.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter21.fillterName = @"GPUImageLuminanceRangeFilter";
    filter21.value = @"5.0f";
    
    SLFilterData* filter22 = [[SLFilterData alloc] init];
    filter22.name = @"Exposure";
    filter22.filterImage = [UIImage imageNamed:@"GPUImageSaturationFilter2.png"];
    filter22.fillterName = @"GPUImageExposureFilter";
    filter22.value = @"1.5f";
    
    return [NSArray arrayWithObjects:filter0,filter1,filter2,filter3,filter4,filter5,filter6,filter7,filter8,filter9, filter10, filter11, filter12, filter13, filter14, filter15,filter17,filter18, filter19, filter20, filter21, filter22, nil];
    
}

- (SLFilterData*)createWithName:(NSString* )name andFlieName:(NSString*)fileName andValue:(NSString*)value {
    SLFilterData* filter = [[SLFilterData alloc] init];
    filter.name = name;
    filter.filterImage = [UIImage imageNamed:fileName];
    filter.fillterName = fileName;
    if (value) {
        filter.value = value;
    }
    return filter;
}



- (void)resetMusic {
    [_audioArray removeAllObjects];
}


@end
