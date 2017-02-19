//
//  LNBaseAnimationController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/**
 CABasicAnimation 基础动画
 重要属性
 | fromValue | keyPath对应的初始值 |
 | toValue | keyPath对应的结束值 |
 基础动画创建步骤
 1、初始化动画并设置动画属性
 2、设置动画属性初始值（可以省略）、结束值以及其他动画属性
 3、给图层添加动画
 */

#import "LNBaseAnimationController.h"

@interface LNBaseAnimationController ()

@property (nonatomic, strong) UIView *redView;

@end

@implementation LNBaseAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _redView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 50, kScreenHeight/2 - 50, 100, 100)];
    _redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_redView];
}

- (NSString *)controllerTitle {
    return @"基础动画";
}

-(NSArray *)operateTitleArray {
    return [NSArray arrayWithObjects:@"位移",@"透明度",@"缩放",@"旋转",@"背景色",@"弹簧动画",nil];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self positionAnimation];
            break;
        case 1:
            [self opacityAniamtion];
            break;
        case 2:
            [self scaleAnimation];
            break;
        case 3:
            [self rotateAnimation];
            break;
        case 4:
            [self backgroundAnimation];
            break;
        case 5:
            [self springAnimation];
            break;
            
        default:
            break;
    }
}


/**
 位移动画演示
 */
#pragma mark - 位移动画
- (void)positionAnimation {

    // 1.创建动画对象并设置动画属性
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];

    // 2.设置动画 初始值(可以省略) 和 结束值
    // 把CGPoint转换成id类型,使用NSValue
    basicAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(50, kScreenHeight/2)];
    basicAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(kScreenWidth- 50, kScreenHeight/2)];
    
    // 设置动画的其他属性值
    // 动画执行时长2秒（默认0.2s)
    basicAnimation.duration = 1.0f;
    // 设置重复次数,HUGE_VALF可看做无穷大
    //basicAnimation.repeatCount = HUGE_VALF;
    // 设置重复时间（重复时间 / 执行时长 = 重复次数)
    //basicAnimation.repeatDuration = 4;
    // 设置延迟执行2秒
    //basicAnimation.beginTime = CACurrentMediaTime() + 2;
    // 动画时间曲线 kCAMediaTimingFunctionLinear 线性变换 平缓
    //basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    // 自动反转(怎么去就怎么回来)
    //basicAnimation.autoreverses = YES;
    // 设置动画代理
    //basicAnimation.delegate = self;

    /**
     如果fillMode=kCAFillModeForwards和removedOnComletion=NO，那么在动画执行完毕后，图层会保持显示动画执行后的状态。但在实质上，图层的属性值还是动画执行前的初始值，并没有真正被改变。(不设置这两个属性值默认回到原始位置)
     2016-06-15 13:15:24.350 iOS常用动画[14625:325800] 动画前X = 137.500000
     2016-06-15 13:15:24.350 iOS常用动画[14625:325800] 动画后X = 137.500000
     */
    //basicAnimation.removedOnCompletion = NO;// 动画完成时,会自动删除动画
    //basicAnimation.fillMode = kCAFillModeForwards;// 设置让动画效果最后执行状态
    
   
    // 3.给图层添加动画（注意key相当于给动画进行命名，以后获得该动画时可以使用此名称获取）
    [self.redView.layer addAnimation:basicAnimation forKey:@"positionAnimation"];
    
    // 移除动画
    //[self.redView.layer removeAnimationForKey:@"positionAnimation"];
    //[self.redView.layer removeAllAnimations];
}

/**
 透明度动画演示
 */
- (void)opacityAniamtion {
    // 1.创建动画对象并设置动画属性
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    // 2.设置动画属性值
    basicAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    basicAnimation.toValue = [NSNumber numberWithFloat:0.2f];
    basicAnimation.duration = 1.0f;
    
    // 3.给图层添加动画
    [self.redView.layer addAnimation:basicAnimation forKey:@"positionAnimation"];
}

/**
 缩放动画演示
 */
- (void)scaleAnimation {
    // 1.创建动画对象并设置动画属性
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    // 2.设置动画属性值
    basicAnimation.toValue = @0.5;
    basicAnimation.duration = 1.0f;
    
    // 3.给图层添加动画
    [self.redView.layer addAnimation:basicAnimation forKey:@"scaleAnimation"];
}

/**
 旋转动画演示
 */
- (void)rotateAnimation {

    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    basicAnimation.toValue = [NSNumber numberWithFloat:M_PI_4];
    basicAnimation.duration = 1.0f;
    basicAnimation.repeatDuration = 2;
    
    [self.redView.layer addAnimation:basicAnimation forKey:@"rotationAnimation"];
}

/**
 背景色动画演示
 */
- (void)backgroundAnimation {
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    
    basicAnimation.toValue = (id)[UIColor blackColor].CGColor;
    basicAnimation.duration = 2;
    
    [self.redView.layer addAnimation:basicAnimation forKey:@"backgroundColorAnimation"];
}


//-----------------------------private api------------------------------------
/** Subclass for mass-spring animations. */

/*
`CASpringAnimation弹簧动画`
| 属性    |     描述      |
|:-:|:-:|:-:|:-:|
| mass | 质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大 |
| stiffnes | 刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快 |
| damping | 阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快 |
| initivelocity | 初始速率，动画视图的初始速度大小;速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反 |
| settingDuration | 结算时间(根据动画相关参数估算弹簧开始运动到停止的时间，动画设置的时间最好根据此时间来设置) |
 
 CASpringAnimation和UIView的SpringAnimation对比:
 CASpringAnimation 可以设置更多弹簧动画效果的属性，可以实现更复杂的弹簧效果，可以和其他动画组合
 UIView的SpringAnimation实际上就是通过CASpringAnimation来实现的。
*/




/**
 弹簧动画演示
 */
- (void)springAnimation {
    CASpringAnimation * springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
    // 质量,越大弹簧幅度越大
    springAnimation.mass = 10.0;
    // 弹性系数,越大运动越快
    springAnimation.stiffness = 500;
    // 阻尼系数,越大停止越快
    springAnimation.damping = 100.0;
    // 初始速率,正方向相同、负方向相反
    springAnimation.initialVelocity = 30.f;
    
    springAnimation.duration = springAnimation.settlingDuration;
    springAnimation.toValue = [NSNumber numberWithFloat:1.5];
//    springAnimation.removedOnCompletion = NO;
//    springAnimation.fillMode = kCAFillModeForwards;
    springAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.redView.layer addAnimation:springAnimation forKey:@"boundsAni"];
}




#pragma mark - 动画代理方法
#pragma mark 动画开始
-(void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"%s, line = %d",__FUNCTION__,__LINE__);
}

#pragma mark 动画结束
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        NSLog(@"%s, line = %d",__FUNCTION__,__LINE__);
    }
}

@end















