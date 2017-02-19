//
//  LNRightViewController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/**
 tableView设置缩进级别
 */

#import "LNRightViewController.h"
#import "SWRevealViewController.h"
#import "LNUIViewAnimationController.h"
#import "LNBaseAnimationController.h"
#import "LNKeyFrameAnimationController.h"
#import "LNGroupAnimationController.h"
#import "LNTransitionAnimationController.h"
#import "LNAffineTransformController.h"
#import "LNIntegratedCaseController.h"

#define CellID @"cellID"
@interface LNRightViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation LNRightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    [self createTableView];
    
    // cell注册
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
    
}

//- (void)promptLabel{
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-100, 100, 200, 100)];
//    label.text = @"我是右侧菜单";
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont systemFontOfSize:14.f];
//    
//    [self.view addSubview:label];
//}

- (void)initData {
    _dataArray = [NSArray arrayWithObjects:@"iOS常用动画--活学活用",@"综合案例", nil];
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
            viewController = [[LNIntegratedCaseController alloc] init];
            break;
        case 1:
            viewController = [[LNIntegratedCaseController alloc] init];
            break;

        default:
            break;
    }
    // 调用pushFrontViewController进行页面切换
    [revealVC pushFrontViewController:viewController animated:YES];
}

#pragma mark - tableView设置缩进级别
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row ==0) {
//        return 10;
//    }
    return 7;
}


@end













