//
//  LNFoldingViewController.m
//  iOS常用动画
//
//  Created by LN on 17/1/17.
//  Copyright © 2017年 Learning point. All rights reserved.
/*
 图片折叠(反弹动画)
 1.layer.contentsRect:让图片只显示一部分
 2.修改anchorPoint(锚点)
 3.变化值
 4.CAGradientLayer渐变层(颜色渐变)
 */
#import "LNFoldingViewController.h"

@interface LNFoldingViewController ()
// 两张同样的图片
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIImageView *bottomImageView;

@property (nonatomic, strong) UIView *clearnView;

/** 渐变层 */
@property (nonatomic, weak) CAGradientLayer *gradientL;

@end

@implementation LNFoldingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    
    [self createCrossBtn];
    [self createImageContens];
    [self gradientLayer];
}

#pragma mark - 设置图片内容
- (void)createImageContens {
    
    _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 75, kScreenHeight/2 - 60, 150, 120)];
    _topImageView.image = [UIImage imageNamed:@"小黄人"];
    [self.view addSubview:_topImageView];
    
    _bottomImageView = [[UIImageView alloc] initWithFrame:_topImageView.frame];
    _bottomImageView.image = [UIImage imageNamed:@"小黄人"];
    [self.view addSubview:_bottomImageView];
    
    _clearnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _topImageView.frame.size.width, _topImageView.frame.size.height * 2)];
    _clearnView.center = _topImageView.center;
    _clearnView.backgroundColor = [UIColor clearColor];
    NSLog(@"%f %f",_clearnView.frame.size.width,_clearnView.frame.size.height);
    [self.view addSubview:_clearnView];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_clearnView addGestureRecognizer:pan];
    
    // 注释:(x0, y0, W1, H1)
    // 1.让上部图片只显示上部部分
    _topImageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.5);
    // 2.让下部图片只显示下部部分
    _bottomImageView.layer.contentsRect = CGRectMake(0, 0.5, 1, 0.5);
    
    // 修改anchorPoint(上部图片向上走,下部图片向下走)
    _topImageView.layer.anchorPoint = CGPointMake(0.5, 1);
    _bottomImageView.layer.anchorPoint = CGPointMake(0.5, 0);
    
}

#pragma mark - 渐变层(颜色渐变)
- (void)gradientLayer{
    // 渐变层(颜色渐变)
    CAGradientLayer *gradientL = [CAGradientLayer layer];
    self.gradientL = gradientL;
    gradientL.frame = _bottomImageView.bounds;
    // 设置渐变的颜色
    gradientL.colors = @[(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor];
    // 设置渐变透明
    gradientL.opacity = 0;
    
    [self.bottomImageView.layer addSublayer:gradientL];

}

// 拖动手势
- (void)pan:(UIPanGestureRecognizer *)pan {
    
    // 获取移动的偏移量
    CGPoint transP = [pan translationInView:pan.view];
    /**
     变化的,都找最大值
     让上部图片开始旋转(偏移量 * 旋转角度变化最大值 / 偏移量最大值)
     */
    CGFloat angle = transP.y * M_PI / 240;
    
    // 透视效果(近大远小)
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1 / 300.0;
    
    // 渐变颜色
    self.gradientL.opacity = transP.y * 1 / 240;
    
    self.topImageView.layer.transform = CATransform3DRotate(transform, -angle, 1, 0, 0);
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        self.gradientL.opacity = 0;
        /**
         Damping:弹性系数(越小弹性越大)
         */
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
            // 上部图片复位
            self.topImageView.layer.transform = CATransform3DIdentity;
            
        } completion:nil];
    }
    
}


- (void)createCrossBtn {
    UIButton *crossBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 32, 32)];
    [crossBtn setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [crossBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:crossBtn];
}
- (void)btnClick:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
