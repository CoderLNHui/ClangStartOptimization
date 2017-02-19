//
//  MCFireworksButton.h
//  MCFireworksButton
//
//  Created by Matthew Cheok on 17/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//  仿facebook 点赞动画

#import <UIKit/UIKit.h>

@interface MCFireworksButton : UIButton

@property (strong, nonatomic) UIImage *particleImage;
@property (assign, nonatomic) CGFloat particleScale;
@property (assign, nonatomic) CGFloat particleScaleRange;

- (void)animate;
- (void)popOutsideWithDuration:(NSTimeInterval)duration;
- (void)popInsideWithDuration:(NSTimeInterval)duration;

@end
