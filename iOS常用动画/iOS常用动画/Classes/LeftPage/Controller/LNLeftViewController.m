//
//  LNLeftViewController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
//

#import "LNLeftViewController.h"
#import "SWRevealViewController.h"
#import "LNUIViewAnimationController.h"
#import "LNBaseAnimationController.h"
#import "LNKeyFrameAnimationController.h"
#import "LNGroupAnimationController.h"
#import "LNTransitionAnimationController.h"
#import "LNAffineTransformController.h"
#import "LNIntegratedCaseController.h"
#import "LNPracticeAnimationVC.h"


#define CellID @"cellID"
@interface LNLeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation LNLeftViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    [self createTableView];
    
    // cell注册
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
}

- (void)initData {
    _dataArray = [NSArray arrayWithObjects:@"iOS常用动画--夯实基础",@"UIView和CALayer",@"基础动画",@"关键帧动画",@"动画组",@"转场动画",@"仿射变换",@"动画练习", nil];
}

- (void)createTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

#pragma mark - 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SWRevealViewController *revealVC = self.revealViewController;
    UIViewController *viewController;
    switch (indexPath.row) {
        case 0:
            viewController = [[LNUIViewAnimationController alloc] init];
            break;
        case 1:
            viewController = [[LNUIViewAnimationController alloc] init];
            break;
        case 2:
            viewController = [[LNBaseAnimationController alloc] init];
            break;
        case 3:
            viewController = [[LNKeyFrameAnimationController alloc] init];
            break;
        case 4:
            viewController = [[LNGroupAnimationController alloc] init];
            break;
        case 5:
            viewController = [[LNTransitionAnimationController alloc] init];
            break;
        case 6:
            viewController = [[LNAffineTransformController alloc] init];
            break;
        case 7:
            viewController = [[LNPracticeAnimationVC alloc] init];
            break;

        default:
            break;
    }
    // 调用pushFrontViewController进行页面切换
    [revealVC pushFrontViewController:viewController animated:YES];
}

@end


















