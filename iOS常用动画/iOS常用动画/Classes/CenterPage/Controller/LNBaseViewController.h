//
//  LNBaseViewController.h
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
//  基类

#import <UIKit/UIKit.h>
#import "LNOperateBtn.h"

@interface LNBaseViewController : UIViewController


/**
 当前Controller的标题
 */
-(NSString *)controllerTitle;


/**
 初始化View
 */
-(void)initView;


/**
 按钮操作区的数组元素
 */
-(NSArray *)operateTitleArray;


/**
 每个按钮的点击事件
 */
-(void)btnClick : (UIButton *)btn;

@end
