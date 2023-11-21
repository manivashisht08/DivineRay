//
//  SLFilterData.m
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 08/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import "SLFilterData.h"
#import "GPUImageSaturationFilter.h"
#import "GPUImageWaveFilter.h"

@interface SLFilterData ()
@end

@implementation SLFilterData

+ (GPUImageOutput<GPUImageInput>*)selectedModelFilter:(SLFilterData *)filterModel {
    
    NSString* _filtClassName =  filterModel.fillterName;
    float saturationValue = 0.0;
    
     if ([filterModel.fillterName isEqualToString:@"GPUImageSaturationFilter"]) {
        GPUImageSaturationFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.saturation = [filterModel.value floatValue];
          saturationValue = [filterModel.value floatValue];
         return xxxxfilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImageWaveFilter"]) {
        GPUImageWaveFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.normalizedPhase = [filterModel.value floatValue];
        return xxxxfilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImageGammaFilter"]) {
        GPUImageGammaFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.gamma = [filterModel.value floatValue];
         return xxxxfilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImagePosterizeFilter"]) {
        GPUImagePosterizeFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.colorLevels = [filterModel.value floatValue];
         return xxxxfilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImageLuminanceRangeFilter"]) {
        GPUImageLuminanceRangeFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.rangeReductionFactor = [filterModel.value floatValue];
         return xxxxfilter;
        
    } else if ([filterModel.fillterName isEqualToString:@"GPUImageExposureFilter"]) {
        GPUImageExposureFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.exposure = [filterModel.value floatValue];
         return xxxxfilter;
    }
    else {
        return [[NSClassFromString(_filtClassName) alloc] init];
    }
}

@end
