//
//  LNVibrationViewController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/*
 音量震动条
 1.CAReplicatorLayer复制层
   1.创建振动条CALayer
   2.添加动画CABasicAnimation
   3.创建复制层CAReplicatorLayer
 倒影
 1.复制层,CAReplicatorLayer
 repL.instanceRedOffset(RGB Alpha)
 */

#import "LNVibrationViewController.h"

@interface LNVibrationViewController ()

@property (nonatomic, strong) UIView *redView;

@end

@implementation LNVibrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _redView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 150, kScreenHeight/2 - 150, 300, 300)];
    _redView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_redView];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 50, CGRectGetMaxY(_redView.frame) + 10, 100, 30)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"音量震动条" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnChange) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self createCrossBtn];
}

- (void)btnChange {
    [self replicatorLayer];
}


// 音量震动:复制层
- (void)replicatorLayer {
    // 1.创建振动条
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.frame = CGRectMake(0, self.redView.frame.size.height - 150, 30, 150);
    layer.anchorPoint = CGPointMake(0, 1);
    layer.position = CGPointMake(0, self.redView.bounds.size.height);
    [self.redView.layer addSublayer:layer];
    
    // 2.添加动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    // 动画属性值
    anim.toValue = @0;
    anim.repeatCount = MAXFLOAT;
    anim.duration = 1;
    anim.autoreverses = YES;// 自动反转
    [layer addAnimation:anim forKey:nil];

    
    // 3.创建复制层
    CAReplicatorLayer *repL = [CAReplicatorLayer layer];
    repL.frame = self.redView.bounds;
    // 设置复制个数(复制个数包括自身)
    repL.instanceCount = 6;
    // 设置复制后的形变(相对上一个的形变)
    repL.instanceTransform = CATransform3DMakeTranslation(45, 0, 0);
    // 设置复制后的延迟s
    repL.instanceDelay = 1;
    
    // 4.将图层添加到复制层
    [self.redView.layer addSublayer:repL];
    [repL addSublayer:layer];
    [layer addAnimation:anim forKey:nil];
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
