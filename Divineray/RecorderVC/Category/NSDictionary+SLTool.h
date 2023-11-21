//
//  NSDictionary+SLTool.h
//  Vivek Dharmai
//
//  Created by Vivek Dharmai Rathor on 20/11/18.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SLTool)
- (id)objectOrNilForKey:(id)key;
- (NSString *)stringForKey:(id)key;
- (NSString *)stringOrEmptyStringForKey:(id)key;
- (NSString *)stringForKey:(id)key defaultValue:(NSString *)defaultValue;
- (NSDictionary *)dictionaryForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSNumber *)numberForKey:(id)key;
- (NSURL *)urlForKey:(id)key;
- (BOOL)boolForKey:(id)key;
@end

