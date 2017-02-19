
//
//  LNBageValueViewController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
//

#import "LNBageValueViewController.h"
//#import "LNBageValueBtn.h"

@interface LNBageValueViewController ()

//@property (nonatomic, strong) LNBageValueBtn *bageValueBtn;

@end

@implementation LNBageValueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self createCrossBtn];

//    _bageValueBtn = [[LNBageValueBtn alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 10, kScreenHeight/2 - 10, 20, 20)];
//    [self.view addSubview:_bageValueBtn];
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
