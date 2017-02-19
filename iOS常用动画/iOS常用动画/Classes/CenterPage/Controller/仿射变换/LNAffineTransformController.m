//
//  LNAffineTransformController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/**
 * transform = CGAffineTransform
 */

#import "LNAffineTransformController.h"

@interface LNAffineTransformController ()

@property (nonatomic, strong) UIView *redView;

@end

@implementation LNAffineTransformController

- (void)viewDidLoad {
    [super viewDidLoad];

    _redView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2- 50, kScreenHeight/2- 50, 100, 100)];
    _redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_redView];
}

- (NSString *)controllerTitle {
    return @"仿射变换";
}

-(NSArray *)operateTitleArray {
    return [NSArray arrayWithObjects:@"位移",@"缩放",@"旋转",@"组合",@"反转",nil];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self positionAnimation];
            break;
        case 1:
            [self scaleAnimation];
            break;
        case 2:
            [self rotateAnimation];
            break;
        case 3:
            [self combinationAnimation];
            break;
        case 4:
            [self invertAnimation];
            break;
        default:
            break;
    }
}

#pragma mark - 位移
- (void)positionAnimation {
    _redView.transform = CGAffineTransformIdentity;// 原始位置
    [UIView animateWithDuration:1 animations:^{
        _redView.transform = CGAffineTransformMakeTranslation(100, 0);
    }];
}

#pragma mark - 缩放
-(void)scaleAnimation{
    _redView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:1.0f animations:^{
        _redView.transform = CGAffineTransformMakeScale(2, 2);
    }];
}

#pragma mark - 旋转
-(void)rotateAnimation{
    _redView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:1.0f animations:^{
        _redView.transform = CGAffineTransformMakeRotation(M_PI);
    }];
}

#pragma mark - 组合
-(void)combinationAnimation{
    // 仿射变换的组合使用
    _redView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:1.0f animations:^{
        CGAffineTransform transform1 = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform transform2 = CGAffineTransformScale(transform1, 0.5, 0.5);
        _redView.transform = CGAffineTransformTranslate(transform2, 100, 100);
    }];
}

-(void)invertAnimation{
    _redView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:1.0f animations:^{
        // 矩阵反转
        _redView.transform = CGAffineTransformInvert(CGAffineTransformMakeScale(2, 2));
    }];
}

@end












