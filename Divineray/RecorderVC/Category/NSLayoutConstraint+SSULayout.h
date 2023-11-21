//
//  NSLayoutConstraint+SSULayout.h
//  NSLayoutConstraint+SSULayout
//
//  Created by suruihai on 2017/1/23.
//  Copyright © 2017年 ruihai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSULayoutAttribute : NSObject

@property (assign, nonatomic) NSLayoutAttribute attribute;

/*
 *  use weak reference since view carries a pointer pointing the attribute
 */
@property (weak, nonatomic) UIView* view;

/*
 *  only use in NSLayoutAttributeWidth | NSLayoutAttributeHeight, for convenience use, example: self.view.height_attr.constant = 50;
 */
@property (assign, nonatomic) CGFloat constant;

/**
 *  example: [self.view.top_attr lesserThan:[[UIApplication sharedApplication].delegate window].top_attr]
 */
- (NSLayoutConstraint *)lesserThan:(SSULayoutAttribute *)attr;
- (NSLayoutConstraint *)lesserThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant;
- (NSLayoutConstraint *)lesserThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)lesserThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant multiplier:(CGFloat)multiplier priority:(UILayoutPriority)priority;

/**
 *  example: [self.view.top_attr greaterThan:[[UIApplication sharedApplication].delegate window].top_attr]
 */
- (NSLayoutConstraint *)greaterThan:(SSULayoutAttribute *)attr;
- (NSLayoutConstraint *)greaterThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant;
- (NSLayoutConstraint *)greaterThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)greaterThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant multiplier:(CGFloat)multiplier priority:(UILayoutPriority)priority;

/**
 *  example: [self.view.top_attr equalTo:[[UIApplication sharedApplication].delegate window].top_attr]
 */
- (NSLayoutConstraint *)equalTo:(SSULayoutAttribute *)attr;
- (NSLayoutConstraint *)equalTo:(SSULayoutAttribute *)attr constant:(CGFloat)constant;
- (NSLayoutConstraint *)equalTo:(SSULayoutAttribute *)attr constant:(CGFloat)constant priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)equalTo:(SSULayoutAttribute *)attr constant:(CGFloat)constant multiplier:(CGFloat)multiplier priority:(UILayoutPriority)priority;
@end

/**
 * SSULayoutAttribute construction function
 */
static inline SSULayoutAttribute *SSULayoutAttributeMake(id view, NSLayoutAttribute attribute) {
    SSULayoutAttribute *attr = [[SSULayoutAttribute alloc] init];
    attr.view = view;
    attr.attribute = attribute;
    return attr;
}

@interface NSLayoutConstraint (SSULayout)

/**
 *  expanded the original method with priority
 */
+ (instancetype)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)constant ss_priority:(UILayoutPriority)priority;

@end

@interface UIView(SSULayout)
@property (strong, nonatomic) SSULayoutAttribute *left_attr;
@property (strong, nonatomic) SSULayoutAttribute *right_attr;
@property (strong, nonatomic) SSULayoutAttribute *top_attr;
@property (strong, nonatomic) SSULayoutAttribute *bottom_attr;
@property (strong, nonatomic) SSULayoutAttribute *leading_attr;
@property (strong, nonatomic) SSULayoutAttribute *trailing_attr;
@property (strong, nonatomic) SSULayoutAttribute *width_attr;
@property (strong, nonatomic) SSULayoutAttribute *height_attr;
@property (strong, nonatomic) SSULayoutAttribute *centerX_attr;
@property (strong, nonatomic) SSULayoutAttribute *centerY_attr;
@property (strong, nonatomic) SSULayoutAttribute *lastBaseline_attr;
@property (strong, nonatomic) SSULayoutAttribute *firstBaseLine_attr;

// used while making constraint to a reference object, aka safeAreaLayoutGuide, only applicable for iOS11 or newer.
// only getter is implemented, because setting a layoutguide's constraint has no point.
@property (strong, nonatomic) SSULayoutAttribute *left_attr_safe;
@property (strong, nonatomic) SSULayoutAttribute *right_attr_safe;
@property (strong, nonatomic) SSULayoutAttribute *top_attr_safe;
@property (strong, nonatomic) SSULayoutAttribute *bottom_attr_safe;
@property (strong, nonatomic) SSULayoutAttribute *leading_attr_safe;
@property (strong, nonatomic) SSULayoutAttribute *trailing_attr_safe;
@property (strong, nonatomic) SSULayoutAttribute *centerX_attr_safe;
@property (strong, nonatomic) SSULayoutAttribute *centerY_attr_safe;

/**
 *  activate all constraints written in the block parameter, also store them in a mutablearray for further use. Constraints should be relative to its view, which is the caller of this method
 */
- (void)activateConstraints:(void (^)(void))constraints;

- (void)activateAllConstraints;
/**
 *  activate specific constraint
 */
- (void)activateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute;
- (void)activateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute;
- (void)activateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute relation:(NSLayoutRelation)relation;

- (void)deactivateAllConstraints;
- (void)deactivateAllConstraintsAndAssociatedObjects;
/**
 *  deactivate specific constraint, will destroy the constraint object. If only temporary deactivate, use constraintAccordingToAttribute:andAttribute: to get the constraint object and set its active = NO
 */
- (void)deactivateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute;
- (void)deactivateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute;
- (void)deactivateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute relation:(NSLayoutRelation)relation;

- (NSMutableArray<NSLayoutConstraint *> *)allConstraints;
/**
 *  get specific constraint
 */
- (NSLayoutConstraint *)constraintAccordingToAttribute:(SSULayoutAttribute *)attribute;
- (NSLayoutConstraint *)constraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute;
- (NSLayoutConstraint *)constraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute relation:(NSLayoutRelation)relation;

@end
