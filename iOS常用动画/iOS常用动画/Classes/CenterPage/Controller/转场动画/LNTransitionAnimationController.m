//
//  LNTransitionAnimationController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/**
 CATransition 转场动画
 |属性    |     描述      |
 |:-:|:-:|
 | type | 过渡的类型 |
 | subType | 过渡的方向 |
 | startProgress | 动画起点(在整体动画的百分比) |
 | endProgress | 动画终点(在整体动画的百分比) |
 | addAnimation: forKey: | 把转场动画添加到layer上 |
 创建步骤
 1.创建动画对象
 2.设置转场类型
 3.给图层添加动画
 */

#import "LNTransitionAnimationController.h"

@interface LNTransitionAnimationController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic , strong) UILabel *titleLabel;

@end

@implementation LNTransitionAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2-90, kScreenHeight/2-200,180,260)];
    _imageView.image = [UIImage imageNamed:@"1"];
    [self.view addSubview:_imageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_imageView.frame)/2-10, CGRectGetHeight(_imageView.frame)/2-20, 20, 40)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:40];
    _titleLabel.text = @"1";
    [_imageView addSubview:_titleLabel];

}

-(NSString *)controllerTitle {
    return @"转场动画";
}

-(NSArray *)operateTitleArray {
    return [NSArray arrayWithObjects:@"fade",@"moveIn",@"push",@"reveal",@"cube",@"suck",@"oglFlip",@"ripple",@"Curl",@"UnCurl",@"caOpen",@"caClose", nil];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self fadeAnimation];
            break;
        case 1:
            [self moveInAnimation];
            break;
        case 2:
            [self pushAnimation];
            break;
        case 3:
            [self revealAnimation];
            break;
        case 4:
            [self cubeAnimation];
            break;
        case 5:
            [self suckEffectAnimation];
            break;
        case 6:
            [self oglFlipAnimation];
            break;
        case 7:
            [self rippleEffectAnimation];
            break;
        case 8:
            [self pageCurlAnimation];
            break;
        case 9:
            [self pageUnCurlAnimation];
            break;
        case 10:
            [self cameraIrisHollowOpenAnimation];
            break;
        case 11:
            [self cameraIrisHollowCloseAnimation];
            break;
        default:
            break;
    }
}

//-----------------------------public api------------------------------------
/*
 type:
 kCATransitionFade;
 kCATransitionMoveIn;
 kCATransitionPush;
 kCATransitionReveal;
 */
/*
 subType:
 kCATransitionFromRight;
 kCATransitionFromLeft;
 kCATransitionFromTop;
 kCATransitionFromBottom;
 */

/**
 *  交叉淡化过渡
 */
-(void)fadeAnimation{
    [self changeShowContens];
    // 1.创建动画对象
    CATransition *anima = [CATransition animation];
    // 2.设置转场类型
    anima.type = kCATransitionFade;// 设置动画的类型
    //anima.type = @"cube";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    //anima.startProgress = 0.3;// 设置动画起点
    //anima.endProgress = 0.8;// 设置动画终点
    anima.duration = 1.0f;// 设置动画执行时长
    // 3.给图层添加动画
    [_imageView.layer addAnimation:anima forKey:@"fadeAnimation"];
}

-(void)moveInAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionMoveIn;// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"moveInAnimation"];
}

-(void)pushAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionPush;// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;

    
    [_imageView.layer addAnimation:anima forKey:@"pushAnimation"];
}

-(void)revealAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionReveal;// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"revealAnimation"];
}

//-----------------------------private api------------------------------------
/*
	Don't be surprised if Apple rejects your app for including those effects,
	and especially don't be surprised if your app starts behaving strangely after an OS update.
 */
/*
`CATransition转场动画过渡类型`
|类型字符串    |     效果说明      | 
|:-:|:-:|
| fade |          交叉淡化过渡 |
| push |          新视图把旧视图推出去 |
| moveIn |        新视图移到旧视图上面 |
| reveal |        将旧视图移开,显示下面的新视图 |  
| cube |          立方体翻滚效果 |
| oglFlip |       上下左右翻滚效果 |
| suckEffect |    收缩效果,如一块布被抽走 |
| rippleEffect |  水滴效果 |
| pageCurl |      向上翻页效果 |
| pageUnCurl |    向下翻页效果 |
| cameraIrisHollowOpen | 相机镜头打开效果 |
| cameraIrisHollowClose | 相机镜头关闭效果 |
*/


/**
 *  立体翻滚效果
 */
-(void)cubeAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = @"cube";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"revealAnimation"];
}


-(void)suckEffectAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = @"suckEffect";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"suckEffectAnimation"];
}

-(void)oglFlipAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = @"oglFlip";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"oglFlipAnimation"];
}

-(void)rippleEffectAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = @"rippleEffect";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"rippleEffectAnimation"];
}

-(void)pageCurlAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = @"pageCurl";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"pageCurlAnimation"];
}

-(void)pageUnCurlAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = @"pageUnCurl";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"pageUnCurlAnimation"];
}

-(void)cameraIrisHollowOpenAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = @"cameraIrisHollowOpen";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;
    
    [_imageView.layer addAnimation:anima forKey:@"cameraIrisHollowOpenAnimation"];
}

-(void)cameraIrisHollowCloseAnimation{
    [self changeShowContens];
    CATransition *anima = [CATransition animation];
    anima.type = @"cameraIrisHollowClose";// 设置动画的类型
    anima.subtype = kCATransitionFromRight; // 设置动画的方向
    anima.duration = 1.0f;

    [_imageView.layer addAnimation:anima forKey:@"cameraIrisHollowCloseAnimation"];
}


/**
 * 设置imageView和titleLabel的值
 */
-(void)changeShowContens {
    // 转场代码跟转场动画必须得要在同一个方法当中
    static NSInteger _i = 1;
    _i++;
    if (_i == 4) {
        _i = 1;
    }
    NSString *imageName = [NSString stringWithFormat:@"%ld",_i];
    _imageView.image = [UIImage imageNamed:imageName];
    NSArray *titles = [NSArray arrayWithObjects:@"1",@"2",@"3", nil];
    _titleLabel.text = [titles objectAtIndex:_i - 1];
}




@end











