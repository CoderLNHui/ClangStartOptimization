//
//  LNGroupAnimationController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/**
 CAAnimationGroup 动画组
 就是多个动画的组合
 |CAAnimationGroup属性    |     描述      |
 |:-:|:-:|
 | animations | 用来保存一组动画对象的NSArray |
 | CFTimeInterval | 时间间隔 |
 */

#import "LNGroupAnimationController.h"

@interface LNGroupAnimationController ()

@property (nonatomic, strong) UIView *redView;

@end

@implementation LNGroupAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];

    _redView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2-25, kScreenHeight/2-50,50,50)];
    _redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_redView];
}

- (NSString *)controllerTitle {
    return @"动画组";
}

-(NSArray *)operateTitleArray {
    return [NSArray arrayWithObjects:@"同时",@"连续", nil];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self groupAnimation1];
            break;
        case 1:
            [self groupAnimation2];
            break;
        default:
            break;
            break;
    }
}

#pragma mark 动画组(同时)
- (void)groupAnimation1 {
    // 位移动画
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    NSValue *value0 = [NSValue valueWithCGPoint:CGPointMake(0, kScreenHeight/2-50)];
    NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(kScreenWidth/3, kScreenHeight/2-50)];
    NSValue *value2 = [NSValue valueWithCGPoint:CGPointMake(kScreenWidth/3, kScreenHeight/2+50)];
    NSValue *value3 = [NSValue valueWithCGPoint:CGPointMake(kScreenWidth*2/3, kScreenHeight/2+50)];
    NSValue *value4 = [NSValue valueWithCGPoint:CGPointMake(kScreenWidth*2/3, kScreenHeight/2-50)];
    NSValue *value5 = [NSValue valueWithCGPoint:CGPointMake(kScreenWidth, kScreenHeight/2-50)];
    animation1.values = @[value0,value1,value2,value3,value4,value5];

    // 缩放动画
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation2.fromValue = [NSNumber numberWithFloat:0.8f];
    animation2.toValue = [NSNumber numberWithFloat:2.0f];
    
    // 旋转动画
    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation3.toValue = [NSNumber numberWithFloat:M_PI *4];
    
    // 创建动画组
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[animation1,animation2,animation3];
    groupAnimation.duration = 4;
    [self.redView.layer addAnimation:groupAnimation forKey:@"groupAnimation"];
}

#pragma mark 动画组(连续)
- (void)groupAnimation2 {
    CFTimeInterval currentTime = CACurrentMediaTime();
    // 位移动画
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
    animation1.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, kScreenHeight/2-75)];
    animation1.toValue = [NSValue valueWithCGPoint:CGPointMake(kScreenWidth/2, kScreenHeight/2-75)];
    
    animation1.beginTime = currentTime;
    animation1.duration = 1;
    animation1.removedOnCompletion = NO;
    animation1.fillMode = kCAFillModeForwards;
    [_redView.layer addAnimation:animation1 forKey:@"animation1"];
    
    
    // 缩放动画
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation2.fromValue = [NSNumber numberWithFloat:0.8f];
    animation2.toValue = [NSNumber numberWithFloat:2.0f];
    animation2.beginTime = currentTime+1.0f;
    animation2.duration = 1.0f;
    animation2.removedOnCompletion = NO;
    animation2.fillMode = kCAFillModeForwards;
    [_redView.layer addAnimation:animation2 forKey:@"animation2"];
    
    
    // 旋转动画
    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation3.toValue = [NSNumber numberWithFloat:M_PI*4];
    animation3.beginTime = currentTime+2.0f;
    animation3.duration = 1.0f;
    animation3.removedOnCompletion = NO;
    animation3.fillMode = kCAFillModeForwards;
    [_redView.layer addAnimation:animation3 forKey:@"animation3"];
}


@end































