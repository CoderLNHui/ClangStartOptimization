//
//  LNIntegratedCaseVC.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
//

#import "LNIntegratedCaseController.h"
#import "DCPathButton.h"
#import "DWBubbleMenuButton.h"
#import "MCFireworksButton.h"

@interface LNIntegratedCaseController ()<DCPathButtonDelegate>

@property (nonatomic, strong) DCPathButton *pathAnimationView;

@property (nonatomic , strong) DWBubbleMenuButton *dingdingAnimationMenu;

@property (nonatomic , strong) MCFireworksButton *goodBtn;

@property (nonatomic , assign) BOOL selected;

@end

@implementation LNIntegratedCaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self pathAnimation];
}

- (NSString *)controllerTitle {
    return @"综合案例";
}

-(NSArray *)operateTitleArray {
    return [NSArray arrayWithObjects:@"Path",@"钉钉",@"点赞", nil];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self pathAnimation];
            break;
        case 1:
            [self dingdingAnimation];
            break;
        case 2:
            [self clickGoodAnimation];
            break;
        default:
            break;
    }
}

/**
 *  仿Path 菜单动画
 *  不要忘记导入音效文件
 */
-(void)pathAnimation {
    if (_dingdingAnimationMenu) {
        _dingdingAnimationMenu.hidden = YES;
    }
    if (_goodBtn) {
        _goodBtn.hidden = YES;
    }
    if (!_pathAnimationView) {
        [self ConfigureDCPathButton];
    }else{
        _pathAnimationView.hidden = NO;
    }
}

- (void)ConfigureDCPathButton {
    // 1.设置中间按钮
    DCPathButton *dcPathBtn = [[DCPathButton alloc] initWithCenterImage:[UIImage imageNamed:@"chooser-button-tab"] hilightedImage:[UIImage imageNamed:@"chooser-button-tab-highlighted"]];
    _pathAnimationView = dcPathBtn;
    dcPathBtn.delegate = self;

    // 2.设置每个items按钮
    DCPathItemButton *itemBtn1 = [[DCPathItemButton alloc] initWithImage:[UIImage imageNamed:@"chooser-moment-icon-music"] highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-music-highlighted"] backgroundImage:[UIImage imageNamed:@"chooser-moment-button"] backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    DCPathItemButton *itemBtn2 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-place"]
                                                           highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-place-highlighted"]
                                                            backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    DCPathItemButton *itemBtn3 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-camera"]
                                                           highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-camera-highlighted"]
                                                            backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    DCPathItemButton *itemBtn4 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-thought"]
                                                           highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-thought-highlighted"]
                                                            backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    DCPathItemButton *itemBtn5 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-sleep"]
                                                           highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-sleep-highlighted"]
                                                            backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];

    [dcPathBtn addPathItems:@[itemBtn1,itemBtn2,itemBtn3,itemBtn4,itemBtn5]];
    [self.view addSubview:dcPathBtn];
}

#pragma mark - DCPathButton Delegate
- (void)itemButtonTappedAtIndex:(NSUInteger)index {
    NSLog(@"你点击按钮的下标是 : %ld", index);
}


//------------------------------------我是分割线----------------------------------//
/**
 *  仿钉钉 菜单动画
 */
-(void)dingdingAnimation{
    if (_pathAnimationView) {
        _pathAnimationView.hidden = YES;
    }
    if (_goodBtn) {
        _goodBtn.hidden = YES;
    }
    if (!_dingdingAnimationMenu) {
        [self ConfigureDWBubbleMenuButton];
    }else{
        _dingdingAnimationMenu.hidden = NO;
    }
}

#pragma mark - 配置MenuBtn
- (void)ConfigureDWBubbleMenuButton {
    UILabel *homeLabel = [self createHomeButtonView];
    // btns background
    DWBubbleMenuButton *upMenuView = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - homeLabel.frame.size.width - 20.f,self.view.frame.size.height - homeLabel.frame.size.height - 20.f,homeLabel.frame.size.width,homeLabel.frame.size.height) expansionDirection:DirectionUp];
    upMenuView.homeButtonView = homeLabel;
    //upMenuView.backgroundColor = [UIColor redColor];
    [upMenuView addButtons:[self createDemoButtonArray]];
    
    _dingdingAnimationMenu = upMenuView;
    
    [self.view addSubview:upMenuView];
}

// Tap点击按钮
- (UILabel *)createHomeButtonView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    
    label.text = @"Tap";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = label.frame.size.height / 2.f;
    label.backgroundColor =[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    label.clipsToBounds = YES;
    
    return label;
}

// 子点击按钮
- (NSArray *)createDemoButtonArray {
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (NSString *title in @[@"A", @"B", @"C", @"D", @"E", @"F"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        
        button.frame = CGRectMake(0.f, 0.f, 30.f, 30.f);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        button.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
        button.clipsToBounds = YES;
        button.tag = i++;
        
        [button addTarget:self action:@selector(dwBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonsMutable addObject:button];
    }
    
    return [buttonsMutable copy];
}

- (void)dwBtnClick:(UIButton *)btn {
    NSLog(@"你点击按钮的下标是 : %ld", btn.tag);
}

//------------------------------------我是分割线----------------------------------//
/**
 *  仿facebook 点赞动画
 */
-(void)clickGoodAnimation{
    if (_pathAnimationView) {
        _pathAnimationView.hidden = YES;
    }
    if (_dingdingAnimationMenu) {
        _dingdingAnimationMenu.hidden = YES;
    }
    if (!_goodBtn) {
        [self ConfigureMCFireworksButton];
    }else{
        _goodBtn.hidden = NO;
    }
}

#pragma mark - 配置点赞Btn
- (void)ConfigureMCFireworksButton {
    _goodBtn = [[MCFireworksButton alloc] initWithFrame:CGRectMake(kScreenWidth/2-25, kScreenHeight/2-25, 50, 50)];
    _goodBtn.particleImage = [UIImage imageNamed:@"Sparkle"];
    _goodBtn.particleScale = 0.05;
    _goodBtn.particleScaleRange = 0.02;
    [_goodBtn setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
    
    [_goodBtn addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_goodBtn];
    
}

- (void)handleButtonPress:(id)btn {
    _selected = !_selected;
    if(_selected) {
        [_goodBtn popOutsideWithDuration:0.5];
        [_goodBtn setImage:[UIImage imageNamed:@"Like-Blue"] forState:UIControlStateNormal];
        [_goodBtn animate];
        NSLog(@"点赞");
    }else {
        [_goodBtn popInsideWithDuration:0.4];
        [_goodBtn setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
        NSLog(@"取消赞");
    }
}






@end








