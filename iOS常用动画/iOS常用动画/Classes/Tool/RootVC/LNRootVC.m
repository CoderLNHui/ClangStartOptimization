//
//  LNRootVC.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
//

#import "LNRootVC.h"
#import "LNLeftViewController.h"
#import "LNUIViewAnimationController.h"
#import "LNRightViewController.h"
#import "SWRevealViewController.h"

@implementation LNRootVC

+ (UIViewController *)chooseWindowRootVC {
    
    // 左侧菜单
    LNLeftViewController *leftVC = [[LNLeftViewController alloc] init];
    // 主菜单
    LNUIViewAnimationController *mainVC = [[LNUIViewAnimationController alloc] init];
    // 右侧菜单
    LNRightViewController *rightVC = [[LNRightViewController alloc] init];
    
    // 设置左侧VC 和 主显示VC，及右侧VC(可选视图)
    SWRevealViewController *revealVC = [[SWRevealViewController alloc] initWithRearViewController:leftVC frontViewController:mainVC];
    revealVC.rightViewController = rightVC;
    
    // 设置浮动层离左边距的宽度
    revealVC.rearViewRevealWidth = 230;
    // 是否让浮动层弹回原位
    //revealVC.bounceBackOnOverdraw = NO;
    
    [revealVC setFrontViewPosition:FrontViewPositionLeft animated:YES];
    
    return revealVC;
}

@end
