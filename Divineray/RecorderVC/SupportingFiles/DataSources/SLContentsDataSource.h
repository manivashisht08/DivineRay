//
//  SLContentsDataSource.h
//  DivinerayVideoProcessing
//
//  Created by Vivek Dharmai Rathor on 08/06/20.
//  Copyright © 2020 Vivek Dharmai Rathor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLContentsDataSource : NSObject
+ (instancetype)sharedContentsManager;


/**
 Get All the Filter. Array Containing the 'SLFilterData' instances
 @return - Collection of 'SLFilterData'
 */
- (NSArray*)getAllFiltersCollection;

@end


