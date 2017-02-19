
//
//  LNParticleViewController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
// 粒子效果

#import "LNParticleViewController.h"
#import "LNParticleView.h"

@interface LNParticleViewController ()

@property (nonatomic, strong) LNParticleView *parView;

@end

@implementation LNParticleViewController

- (void)loadView {
    _parView = [[LNParticleView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, kScreenHeight)];
    _parView.backgroundColor = [UIColor lightGrayColor];
    self.view = _parView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createCrossBtn];
    
    UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 30, 60, 30)];
    startBtn.backgroundColor = [UIColor blackColor];
    [startBtn setTitle:@"开始" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton *drawRectBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 100, 30, 60, 30)];
    drawRectBtn.backgroundColor = [UIColor blackColor];
    [drawRectBtn setTitle:@"重绘" forState:UIControlStateNormal];
    [drawRectBtn addTarget:self action:@selector(drawRectClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:drawRectBtn];
}

// 开始动画
- (void)startClick {
    [self.parView start];
}

// 重绘
- (void)drawRectClick {
    [self.parView draw];
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
















