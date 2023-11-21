//
//  SLPlayerMacro.h
//  SLPlayer
//
//  Created by Single on 16/6/29.
//  Copyright © 2016年 single. All rights reserved.
//

#ifndef SLPlayerMacro_h
#define SLPlayerMacro_h

#import <Foundation/Foundation.h>

// weak self
#define SLWeakSelf __weak typeof(self) weakSelf = self;
#define SLStrongSelf __strong typeof(weakSelf) strongSelf = weakSelf;

// log level
#ifdef DEBUG
#define SLPlayerLog(...) NSLog(__VA_ARGS__)
#else
#define SLPlayerLog(...)
#endif


#endif
