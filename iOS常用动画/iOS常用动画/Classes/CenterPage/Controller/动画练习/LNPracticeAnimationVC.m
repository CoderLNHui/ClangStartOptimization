
//
//  LNPracticeAnimationVC.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
//

#import "LNPracticeAnimationVC.h"
#import "LNFoldingViewController.h"
#import "LNVibrationViewController.h"
#import "LNParticleViewController.h"
#import "LNBageValueViewController.h"

#import "LNParticleView.h"

@interface LNPracticeAnimationVC ()


@property (nonatomic, strong) UIView *redView;

@property (nonatomic, strong) LNParticleView *parView;

@end

@implementation LNPracticeAnimationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

}

- (NSString *)controllerTitle {
    return @"动画练习";
}

-(NSArray *)operateTitleArray {
    return [NSArray arrayWithObjects:@"图片折叠",@"音量震动条",@"粒子",@"QQ消息粘性",nil];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self presentViewController:[[LNFoldingViewController alloc] init] animated:YES completion:nil];
            break;
        case 1:
            [self presentViewController:[[LNVibrationViewController alloc] init] animated:YES completion:nil];
            break;
        case 2:
            [self presentViewController:[[LNParticleViewController alloc] init] animated:YES completion:nil];
            break;
        case 3:
            [self presentViewController:[[LNBageValueViewController alloc] init] animated:YES completion:nil];
            break;
            
        default:
            break;
    }
}



@end














