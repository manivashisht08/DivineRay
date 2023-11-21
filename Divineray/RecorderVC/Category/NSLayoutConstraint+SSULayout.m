//
//  NSLayoutConstraint+SSULayout.m
//  NSLayoutConstraint+SSULayout
//
//  Created by suruihai on 2017/1/23.
//  Copyright © 2017年 ruihai. All rights reserved.
//

#import "NSLayoutConstraint+SSULayout.h"
#import <objc/runtime.h>

@implementation SSULayoutAttribute

- (void)setConstant:(CGFloat)constant {
    
    if (self.attribute != NSLayoutAttributeWidth && self.attribute != NSLayoutAttributeHeight) {
        NSAssert(NO, @"only height/width attributes could set constant directly!");
        return;
    }
    
    NSLayoutConstraint *cons = [self.view constraintAccordingToAttribute:self];
    
    if (cons) {
        cons.constant = constant;
    } else {
        [self equalTo:nil constant:constant];
    }
}

- (CGFloat)constant {
    if (self.attribute != NSLayoutAttributeWidth && self.attribute != NSLayoutAttributeHeight) {
        NSAssert(NO, @"only height/width attributes could get constant directly!");
        return 0;
    }
    
    NSLayoutConstraint *cons = [self.view constraintAccordingToAttribute:self];
    return cons.constant;
}

- (NSLayoutConstraint *)lesserThan:(SSULayoutAttribute *)attr {
    return [self constraintTo:attr constant:0 priority:UILayoutPriorityRequired relation:NSLayoutRelationLessThanOrEqual multiplier:1.0];
}

- (NSLayoutConstraint *)lesserThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant {
    return [self constraintTo:attr constant:constant priority:UILayoutPriorityRequired relation:NSLayoutRelationLessThanOrEqual multiplier:1.0];
}

- (NSLayoutConstraint *)lesserThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant priority:(UILayoutPriority)priority {
    return [self constraintTo:attr constant:constant priority:priority relation:NSLayoutRelationLessThanOrEqual multiplier:1.0];
}

- (NSLayoutConstraint *)lesserThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant multiplier:(CGFloat)multiplier priority:(UILayoutPriority)priority {
    return [self constraintTo:attr constant:constant priority:priority relation:NSLayoutRelationLessThanOrEqual multiplier:multiplier];
}

- (NSLayoutConstraint *)greaterThan:(SSULayoutAttribute *)attr {
    return [self constraintTo:attr constant:0 priority:UILayoutPriorityRequired relation:NSLayoutRelationGreaterThanOrEqual multiplier:1.0];
}

- (NSLayoutConstraint *)greaterThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant {
    return [self constraintTo:attr constant:constant priority:UILayoutPriorityRequired relation:NSLayoutRelationGreaterThanOrEqual multiplier:1.0];
}

- (NSLayoutConstraint *)greaterThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant priority:(UILayoutPriority)priority {
    return [self constraintTo:attr constant:constant priority:priority relation:NSLayoutRelationGreaterThanOrEqual multiplier:1.0];
}

- (NSLayoutConstraint *)greaterThan:(SSULayoutAttribute *)attr constant:(CGFloat)constant multiplier:(CGFloat)multiplier priority:(UILayoutPriority)priority {
    return [self constraintTo:attr constant:constant priority:priority relation:NSLayoutRelationGreaterThanOrEqual multiplier:multiplier];
}

- (NSLayoutConstraint *)equalTo:(SSULayoutAttribute *)attr {
    return [self constraintTo:attr constant:0 priority:UILayoutPriorityRequired relation:NSLayoutRelationEqual multiplier:1.0];
}

- (NSLayoutConstraint *)equalTo:(SSULayoutAttribute *)attr constant:(CGFloat)constant {
    return [self constraintTo:attr constant:constant priority:UILayoutPriorityRequired relation:NSLayoutRelationEqual multiplier:1.0];
}

- (NSLayoutConstraint *)equalTo:(SSULayoutAttribute *)attr constant:(CGFloat)constant priority:(UILayoutPriority)priority {
    return [self constraintTo:attr constant:constant priority:priority relation:NSLayoutRelationEqual multiplier:1.0];
}

- (NSLayoutConstraint *)equalTo:(SSULayoutAttribute *)attr constant:(CGFloat)constant multiplier:(CGFloat)multiplier priority:(UILayoutPriority)priority {
    return [self constraintTo:attr constant:constant priority:priority relation:NSLayoutRelationEqual multiplier:multiplier];
}

/**
 *  THE VERY BASE METHOD!
 */
- (NSLayoutConstraint *)constraintTo:(SSULayoutAttribute *)attr constant:(CGFloat)constant priority:(UILayoutPriority)priority relation:(NSLayoutRelation)relation multiplier:(CGFloat)multiplier {
    if (attr) {
        return [NSLayoutConstraint constraintWithItem:self.view attribute:self.attribute relatedBy:relation toItem:attr.view attribute:attr.attribute multiplier:multiplier constant:constant ss_priority:priority];
    } else {
        return [NSLayoutConstraint constraintWithItem:self.view attribute:self.attribute relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:multiplier constant:constant ss_priority:priority];
    }
}
@end

@implementation NSLayoutConstraint (SSULayout)

+ (instancetype)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)constant ss_priority:(UILayoutPriority)priority {
    
    NSLayoutConstraint *cons = [self constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:constant];
    cons.priority = priority;
    
    NSMutableArray *arrayM = objc_getAssociatedObject(view1, "ss_constraintsKey");
    if (arrayM && cons) {
        cons.active = YES;
        [arrayM addObject:cons];
    }
    
    return cons;
}
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-property-implementation"
@implementation UIView (SSULayout)
#pragma clang diagnostic pop

#pragma mark - Activate Methods
- (void)activateConstraints:(void (^)(void))constraints {
    
    if (constraints) {
        
        if (self.translatesAutoresizingMaskIntoConstraints) {
            self.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSMutableArray *arrayM = objc_getAssociatedObject(self, "ss_constraintsKey");
        
        if (!arrayM) {
            arrayM = [NSMutableArray arrayWithCapacity:1];
            objc_setAssociatedObject(self, "ss_constraintsKey", arrayM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        constraints();
    }
}

- (void)activateAllConstraints {
    NSArray *array = [self allConstraints];
    if (array.count > 0) {
        [NSLayoutConstraint activateConstraints:array];
        //        NSLog(@"\n---All Constraints Activated!---\n%@", array);
    }
}

- (void)activateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute {
    [self activateConstraintAccordingToAttribute:attribute andAttribute:nil relation:NSLayoutRelationEqual];
}

- (void)activateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute {
    [self activateConstraintAccordingToAttribute:attribute andAttribute:otherAttribute relation:NSLayoutRelationEqual];
}

- (void)activateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute relation:(NSLayoutRelation)relation {
    NSLayoutConstraint *cons = [self constraintAccordingToAttribute:attribute andAttribute:otherAttribute relation:relation];
    if (cons) {
        [NSLayoutConstraint activateConstraints:@[cons]];
    }
}

#pragma mark - Deactivate Methods

- (void)deactivateAllConstraints {
    NSArray *array = [self allConstraints];
    if (array.count > 0) {
        [NSLayoutConstraint deactivateConstraints:array];
        [self.allConstraints removeAllObjects];
        //        NSLog(@"\n---All Constraints Deactivated!---\n%@", array);
    }
}

- (void)deactivateAllConstraintsAndAssociatedObjects {
    [self deactivateAllConstraints];
    objc_removeAssociatedObjects(self);
}

- (void)deactivateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute {
    [self deactivateConstraintAccordingToAttribute:attribute andAttribute:nil relation:NSLayoutRelationEqual];
}

- (void)deactivateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute {
    [self deactivateConstraintAccordingToAttribute:attribute andAttribute:otherAttribute relation:NSLayoutRelationEqual];
}

- (void)deactivateConstraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute relation:(NSLayoutRelation)relation {
    NSLayoutConstraint *cons = [self constraintAccordingToAttribute:attribute andAttribute:otherAttribute relation:relation];
    if (cons) {
        [NSLayoutConstraint deactivateConstraints:@[cons]];
        if (cons) {
            [self.allConstraints removeObject:cons];
        }
    }
}

#pragma mark - Get Constraints Methods

- (NSMutableArray<NSLayoutConstraint *> *)allConstraints {
    return objc_getAssociatedObject(self, "ss_constraintsKey");
}

- (NSLayoutConstraint *)constraintAccordingToAttribute:(SSULayoutAttribute *)attribute {
    return [self constraintAccordingToAttribute:attribute andAttribute:nil relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)constraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute {
    return [self constraintAccordingToAttribute:attribute andAttribute:otherAttribute relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)constraintAccordingToAttribute:(SSULayoutAttribute *)attribute andAttribute:(SSULayoutAttribute *)otherAttribute relation:(NSLayoutRelation)relation {
    NSMutableArray *arrayM = objc_getAssociatedObject(self, "ss_constraintsKey");
    NSLayoutConstraint *cons = nil;
    if (arrayM.count > 0) {
        for (NSLayoutConstraint *constraint in arrayM) {
            if (constraint.firstItem == attribute.view && constraint.firstAttribute == attribute.attribute) {
                if (!otherAttribute) {
                    if (!constraint.secondItem && constraint.relation == relation) {
                        cons = constraint;
                        break;
                    }
                } else {
                    if (constraint.secondItem == otherAttribute.view && constraint.secondAttribute == otherAttribute.attribute && constraint.relation == relation) {
                        cons = constraint;
                        break;
                    }
                }
            }
        }
    }
    
    return cons;
}

#pragma mark - SSULayoutAttribute Getters

- (SSULayoutAttribute *)left_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeLeft);
}

- (SSULayoutAttribute *)right_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeRight);
}

- (SSULayoutAttribute *)top_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeTop);
}

- (SSULayoutAttribute *)bottom_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeBottom);
}

- (SSULayoutAttribute *)leading_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeLeading);
}

- (SSULayoutAttribute *)trailing_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeTrailing);
}

- (SSULayoutAttribute *)width_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeWidth);
}

- (SSULayoutAttribute *)height_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeHeight);
}

- (SSULayoutAttribute *)centerX_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeCenterX);
}

- (SSULayoutAttribute *)centerY_attr {
    return SSULayoutAttributeMake(self , NSLayoutAttributeCenterY);
}

- (SSULayoutAttribute *)lastBaseline_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeLastBaseline);
}

- (SSULayoutAttribute *)firstBaseLine_attr {
    return SSULayoutAttributeMake(self, NSLayoutAttributeFirstBaseline);
}

- (SSULayoutAttribute *)left_attr_safe {
    if (@available(iOS 11.0, *)) {
        return SSULayoutAttributeMake(self.safeAreaLayoutGuide, NSLayoutAttributeLeft);
    } else {
        return self.left_attr;
    }
}

- (SSULayoutAttribute *)right_attr_safe {
    if (@available(iOS 11.0, *)) {
        return SSULayoutAttributeMake(self.safeAreaLayoutGuide, NSLayoutAttributeRight);
    } else {
        return self.right_attr;
    }
}

- (SSULayoutAttribute *)top_attr_safe {
    if (@available(iOS 11.0, *)) {
        return SSULayoutAttributeMake(self.safeAreaLayoutGuide, NSLayoutAttributeTop);
    } else {
        return self.top_attr;
    }
}

- (SSULayoutAttribute *)bottom_attr_safe {
    if (@available(iOS 11.0, *)) {
        return SSULayoutAttributeMake(self.safeAreaLayoutGuide, NSLayoutAttributeBottom);
    } else {
        return self.bottom_attr;
    }
}

- (SSULayoutAttribute *)leading_attr_safe {
    if (@available(iOS 11.0, *)) {
        return SSULayoutAttributeMake(self.safeAreaLayoutGuide, NSLayoutAttributeLeading);
    } else {
        return self.leading_attr;
    }
}

- (SSULayoutAttribute *)trailing_attr_safe {
    if (@available(iOS 11.0, *)) {
        return SSULayoutAttributeMake(self.safeAreaLayoutGuide, NSLayoutAttributeTrailing);
    } else {
        return self.trailing_attr;
    }
}

- (SSULayoutAttribute *)centerX_attr_safe {
    if (@available(iOS 11.0, *)) {
        return SSULayoutAttributeMake(self.safeAreaLayoutGuide, NSLayoutAttributeCenterX);
    } else {
        return self.centerX_attr;
    }
}

- (SSULayoutAttribute *)centerY_attr_safe {
    if (@available(iOS 11.0, *)) {
        return SSULayoutAttributeMake(self.safeAreaLayoutGuide, NSLayoutAttributeCenterY);
    } else {
        return self.centerY_attr;
    }
}

#pragma mark - SSULayoutAttribute Setters

- (void)setLeft_attr:(SSULayoutAttribute *)left_attr {
    [self.left_attr equalTo:left_attr];
}

- (void)setRight_attr:(SSULayoutAttribute *)right_attr {
    [self.right_attr equalTo:right_attr];
}

- (void)setTop_attr:(SSULayoutAttribute *)top_attr {
    [self.top_attr equalTo:top_attr];
}

- (void)setBottom_attr:(SSULayoutAttribute *)bottom_attr {
    [self.bottom_attr equalTo:bottom_attr];
}

- (void)setLeading_attr:(SSULayoutAttribute *)leading_attr {
    [self.leading_attr equalTo:leading_attr];
}

- (void)setTrailing_attr:(SSULayoutAttribute *)trailing_attr {
    [self.trailing_attr equalTo:trailing_attr];
}

- (void)setWidth_attr:(SSULayoutAttribute *)width_attr {
    [self.width_attr equalTo:width_attr];
}

- (void)setHeight_attr:(SSULayoutAttribute *)height_attr {
    [self.height_attr equalTo:height_attr];
}

- (void)setCenterX_attr:(SSULayoutAttribute *)centerX_attr {
    [self.centerX_attr equalTo:centerX_attr];
}

- (void)setCenterY_attr:(SSULayoutAttribute *)centerY_attr {
    [self.centerY_attr equalTo:centerY_attr];
}

- (void)setLastBaseline_attr:(SSULayoutAttribute *)lastBaseline_attr {
    [self.lastBaseline_attr equalTo:lastBaseline_attr];
}

- (void)setFirstBaseLine_attr:(SSULayoutAttribute *)firstBaseLine_attr {
    [self.firstBaseLine_attr equalTo:firstBaseLine_attr];
}
@end
