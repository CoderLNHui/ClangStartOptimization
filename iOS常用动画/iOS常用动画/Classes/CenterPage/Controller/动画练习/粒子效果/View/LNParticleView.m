//
//  LNParticleView.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
//  粒子效果自定义View

#import "LNParticleView.h"

@interface LNParticleView ()
/** 记录路径 */
@property (nonatomic, strong) UIBezierPath *path;
/** 粒子 */
@property (nonatomic, strong) CALayer *dotLayer;
@end

@implementation LNParticleView

/** 返回当前UIView内容layer类型 */
+ (Class)layerClass{
    return [CAReplicatorLayer class];
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor lightGrayColor];
        // 添加手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:pan];
        
        // 添加粒子
        CALayer *dotLayer = [CALayer layer];
        dotLayer.frame = CGRectMake(40, 60, 10, 10);
        dotLayer.backgroundColor = [UIColor redColor].CGColor;
        dotLayer.cornerRadius = 5;
        dotLayer.masksToBounds = YES;
        self.dotLayer = dotLayer;
        [self.layer addSublayer:dotLayer];
        
        // 添加复制层
        CAReplicatorLayer *repL = (CAReplicatorLayer *)self.layer;
        repL.instanceCount = 20;// 复制个数
        repL.instanceDelay = 0.5;// 复制后延迟s
        
        /**
         创建路径,设置起点
         应该程序已启动就创建路径,下面只是改变它的起点
         */
        UIBezierPath *path = [UIBezierPath bezierPath];
        [[UIColor redColor] set];
        self.path = path;
        
        //NSLog(@"%@",self.layer);
    }
    return self;
}

- (void)panGesture:(UIPanGestureRecognizer *)pan{
    
    // 获取当前点
    CGPoint curP = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        [self.path moveToPoint:curP];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        // 添加一根线到当前点
        [self.path addLineToPoint:curP];
        // 重绘
        [self setNeedsDisplay];
    } else if (pan.state == UIGestureRecognizerStateEnded){
        
    }
    
}
// 开始
- (void)start{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position";
    anim.path = self.path.CGPath;
    anim.repeatCount = MAXFLOAT;
    anim.duration = 8;
    
    [self.dotLayer addAnimation:anim forKey:nil];
}
// 重绘
- (void)draw{
    // 移除动画
    [self.dotLayer removeAllAnimations];
    // 移除路径
    [self.path removeAllPoints];
    
    // 重绘
    [self setNeedsDisplay];    
}

- (void)drawRect:(CGRect)rect{
    // 绘制路径
    [self.path stroke];
}


@end
