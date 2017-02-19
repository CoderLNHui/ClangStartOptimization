
//
//  LNUIViewAnimationController.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/**
 1.CALayer的常用属性
 | 属性 | 描述 |
 |:-:|:-:|
 | bounds    | 图层大小 |
 | position  | 用来设置CALayer在父层中的位置，以父层的左上角为原点(0, 0)，相当于UIView的center |
 | anchorPoint  | 称为“锚点”，决定着CALayer身上的哪个点会在position属性所指的位置,以自己的左上角为原点(0, 0)，x、y取值范围都是0~1，默认值为（0.5, 0.5） |
 | contents  | 内容：image添加到layer的contents，（使用如：`.CGImage` 或 `.CGColor）` |
 | opacity   | 透明度，相当于UIView的alpha |
 | contentsRect | 设置图片显示的尺寸，取值0~1(x0, y0, W1, H1)，如 CGRectMake(0, 0, 1, 0.5);只将图像的上半部分显示在整个layer中； |
 | CATransform3D    | 形变属性(设置平移、缩放和旋转时的 3D效果) |
 | cornerRadius / masksToBounds   | 圆角半径，属性为YES才显示圆角效果 |
 */

#import "LNUIViewAnimationController.h"

@interface LNUIViewAnimationController ()

@property (nonatomic, strong) CALayer *layer;

@property (nonatomic, strong) UIView *redView;

@end

@implementation LNUIViewAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createlayer];
//    _layer = [CALayer layer];
//    _layer.frame = CGRectMake(kScreenWidth/2 - 50, kScreenHeight/2 - 50, 100, 100);
//    _layer.backgroundColor = [UIColor redColor].CGColor;
//    [self.view.layer addSublayer:_layer];
}

- (NSString *)controllerTitle {
    return @"UIView和Layer";
}

-(NSArray *)operateTitleArray {
    return [NSArray arrayWithObjects:@"Layer使用",@"平移",@"缩放",@"旋转", nil];
}

#pragma mark 创建图层layer
- (void)createlayer{
    CALayer *layer = [CALayer layer];
    self.layer = layer;
    layer.bounds = CGRectMake(0, 0, 100, 100);
    layer.position = self.view.center;
    layer.anchorPoint = CGPointMake(0.5, 1);
    layer.backgroundColor = [UIColor redColor].CGColor;

    layer.contents = (id)[UIImage imageNamed:@"阿狸头像"].CGImage;
    // NSLog(@"%@",layer.contents);<CGImage 0x7fe161c25470>
    
    // 设置圆角半径
    layer.cornerRadius = 50;
    // 设置边框的宽度(注意:是往里面走的) 和 颜色
    layer.borderWidth = 2;
    layer.borderColor = [UIColor grayColor].CGColor;
    // 把超过根层以外的东西剪切掉(UIView自带的层,我们称为是根层)
    layer.masksToBounds = YES;
    
    //self.imageView.clipsToBounds = YES;
    //裁剪：masksToBounds 是 CALayer 的属性；clipsToBounds 是 UIView 的属性；
    
    // ************* 其他属性 ************
    // 默认是自带阴影的效果, 只不过是透明的.
    layer.shadowOpacity = 1;
    // 设置阴影的颜色
    layer.shadowColor = [UIColor blackColor].CGColor;
    // 设置阴影的偏移量((x,y) 例:右下)*+
    layer.shadowOffset = CGSizeMake(10, 10);
    // 设置阴影的模糊程度
    layer.shadowRadius = 10;
    [self.view.layer addSublayer:layer];
    // 设置图层的代理
    //layer.delegate = self;
}


- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
       
        case 1:
            [self positionAnimation];
            break;
        case 2:
            [self scaleAnimation];
            break;
        case 3:
            [self rotateAnimation];
            break;
        default:
            break;
    }
}

/**
 位移动画演示
 */
- (void)positionAnimation {
    self.layer.transform = CATransform3DIdentity;
    [UIView animateWithDuration:1 animations:^{
        // 方式一：CATransform3D普通设置
        // 平移 (CGFloat sx, CGFloat sy, CGFloat sz)
        self.layer.transform = CATransform3DMakeTranslation(0, 100, 0);
        //CATransform3DTranslate(self.layer.transform, 0, 100, 0);
        
        // 方式二：CATransform3D KVC快速设置
        // 把结构体转成对象
        //NSValue *value = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1)];
        //[self.imageView.layer setValue:value forKeyPath:@"transform"];
        
        // 平移
        //[self.layer setValue:@(200) forKeyPath:@"transform.translation.y"];
    }];
}

/**
 缩放动画演示
 */
- (void)scaleAnimation {
    self.layer.transform = CATransform3DIdentity;
    [UIView animateWithDuration:1 animations:^{
        // 缩放
        self.layer.transform = CATransform3DMakeScale(1.2, 1.2, 0);
        
        //[self.layer setValue:@(0.5) forKeyPath:@"scale"];
    }];
}

/**
 旋转动画演示
 */
- (void)rotateAnimation {
    self.layer.transform = CATransform3DIdentity;
    [UIView animateWithDuration:1 animations:^{
        // 旋转
        //self.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        
        [self.layer setValue:@(M_PI) forKeyPath:@"transform.rotation.x"];
    }];
}



#pragma mark - UIView动画
- (void)uiViewAnimation {
    // 使用UIView Animation 代码块调用
//    _redView.frame = CGRectMake(0, kScreenHeight/2-50, 50, 50);
//    [UIView animateWithDuration:1.0f animations:^{
//        _redView.frame = CGRectMake(kScreenWidth, kScreenHeight/2-50, 50, 50);
//    } completion:^(BOOL finished) {
//        _redView.frame = CGRectMake(kScreenWidth/2-25, kScreenHeight/2-50, 50, 50);
//    }];
    
    
    
    // 使用UIView [begin,commit]模式
    // 可以嵌套但是必须成对出现
    UIViewAnimationTransition type = UIViewAnimationTransitionNone;
    [UIView beginAnimations:nil context:nil];
   
    // 动画的持续时间
    [UIView setAnimationDuration:1];
    // 动画类型
    [UIView setAnimationTransition:type forView:_redView cache:YES];
    // 动画代理
    //[UIView setAnimationDelegate:self];
    //[UIView setAnimationWillStartSelector:@selector(annimationStart)];
    //[UIView setAnimationDidStopSelector:@selector(annimationStop)];
    
    [UIView commitAnimations];
}

- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"%s, line = %d",__FUNCTION__,__LINE__);
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"%s, line = %d",__FUNCTION__,__LINE__);
}
/*
 type = UIViewAnimationTransitionFlipFromLeft;
 type = UIViewAnimationTransitionFlipFromRight;
 type = UIViewAnimationTransitionCurlUp;
 type = UIViewAnimationTransitionCurlDown;
 
 */
@end



























