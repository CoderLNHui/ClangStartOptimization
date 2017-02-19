//
//  LNBaseViewController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
//

#import "LNBaseViewController.h"
#import "SWRevealViewController.h"


@interface LNBaseViewController ()

/** 按钮操作区的数组元素 */
@property (nonatomic, strong) NSArray *operateTitleArray;


@end

@implementation LNBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initView];
    [self initData];

}

- (void)initData {
    _operateTitleArray = [self operateTitleArray];
}


- (void)initView {
    UIView *navBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    navBarView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:navBarView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = [self controllerTitle];
    titleLabel.font = [UIFont systemFontOfSize:16.f];
    [navBarView addSubview:titleLabel];
    
    
    if (self.operateTitleArray && self.operateTitleArray.count > 0) {
        // 行数
        NSUInteger row = self.operateTitleArray.count%4 == 0 ? self.operateTitleArray.count/4 : self.operateTitleArray.count/4 +1;
        // 按钮区背景的大小
        UIView *operateView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - (row *50 +20), kScreenWidth, row *50 +20)];
        operateView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:operateView];
        
        for (int i= 0; i < self.operateTitleArray.count; i++) {
            LNOperateBtn *btn = [[LNOperateBtn alloc] initWithFrame:[LNOperateBtn rectForBtnAtIndex:i] withBtnTitle:[self.operateTitleArray objectAtIndex:i]];
            btn.tag = i;
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
            [operateView addSubview:btn];
        }
    }
    
    SWRevealViewController *revealVC = self.revealViewController;
    // 添加Pan手势,可以执行滑动切换
    [self.view addGestureRecognizer:revealVC.panGestureRecognizer];

}

- (NSArray *)operateTitleArray {
    return [NSArray arrayWithObjects:@"暂无数据", nil];
}

- (void)btnClick:(UIButton *)btn {
    
}

-(NSString *)controllerTitle{
    return @"默认标题";
}

@end





















