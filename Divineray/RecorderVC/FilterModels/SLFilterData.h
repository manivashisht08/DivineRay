//
//  SLFilterData.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 08/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"


/**
 Model that contains information about the Filters
 */
@interface SLFilterData : NSObject
/**
 Name
 */
@property (nonatomic,strong) NSString* name;
/**
 Filter Value
 */
@property (nonatomic,strong) NSString* value;
/**
 Filter Name
 */
@property (nonatomic,strong) NSString* fillterName;

@property (nonatomic,strong) UIImage* filterImage;
/**
 Is Filter Currently Selected
 */
@property (nonatomic,assign) BOOL isSelected;

+ (GPUImageOutput<GPUImageInput>*)selectedModelFilter:(SLFilterData *)filterModel;

@end

