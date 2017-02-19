//
//  LNKeyFrameAnimationController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/**
 CAKeyframeAnimation 关键帧动画
 可以让我们在更细的粒度上控制动画的行为
 关键帧动画需要指定几个关键的点，从而让动画沿着这些点运动，这几个点就称之为 **关键帧**
 |CAKeyframeAnimation属性    |     描述      |
 |:-:|:-:|
 | values | 指定关键点的值 |
 | path | 可以设置一个CGPathRef / CGMutablePathRef，让层跟着路径移动。path只对CALayer的anchorPoint和position起作用。如果你设置了path，那么values将被忽略. |
 | keyTimes | 是走到某一个关键点花费的时间百分比(0～1)，keyTimes中的每一个时间值都对应values中的每一帧(两个数组的个数必须一致)，当keyTimes没有设置的时候,各个关键帧的时间是平分的。 |
 | 关键帧动画创建有2种方式 |  |
 | 通过 设置不同的属性值values 动画 |  |
 | 通过 绘制路径path 动画 |  |
 
 */

#import "LNKeyFrameAnimationController.h"

// 角度转弧度
#define angleToRadian(angle) ((angle) / 180.0 * M_PI)
@interface LNKeyFrameAnimationController ()

@property (nonatomic, strong) UIImageView *iconImage;

@end

@implementation LNKeyFrameAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];

    _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 50, kScreenHeight/2 - 50, 100, 100)];
    _iconImage.image = [UIImage imageNamed:@"iconImage"];
    [self.view addSubview:_iconImage];

}

-(NSString *)controllerTitle{
    return @"关键帧动画";
}

-(NSArray *)operateTitleArray{
    return [NSArray arrayWithObjects:@"values抖动",@"path路径", nil];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self valuesAnimation];
            break;
        case 1:
            [self pathAnimation];
            break;
        default:
            break;
    }
}

// 角度转弧度
#define angleToRadian(angle) ((angle) / 180.0 * M_PI)
#pragma mark 关键帧动画values
- (void)valuesAnimation {
    // 1.创建动画对象
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    
    // 2.设置动画属性值
    //NSValue *value1 = [NSValue valueWithCGPoint:<#(CGPoint)#>];
    animation.values = @[@(angleToRadian(-5)),@(angleToRadian(5)),@(angleToRadian(-5))];
    animation.duration = 1;
    animation.repeatCount = MAXFLOAT;
    //animation.keyTimes = @[@(0.0),@(1),@(0.1)];
    
    // 如果不用反转,也可以在values里面写
    //animation.autoreverses = YES;
    
    // 动画结束时的状态（不设置回到原始位置）
    //anim.removedOnCompletion = NO;
    //anim.fillMode = kCAFillModeForwards;
    
    // 3.给图层添加动画
    [self.iconImage.layer addAnimation:animation forKey:@"valuesAnimation"];
}

#pragma mark 关键帧动画path
- (void)pathAnimation {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(kScreenWidth/2-100, kScreenHeight/2-100, 200, 200)];

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.duration = 1;
 
    [self.iconImage.layer addAnimation:animation forKey:@"pathAnimation"];
}

@end















