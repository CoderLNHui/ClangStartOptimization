//
//  LNBageValueBtn.m
//  iOS常用动画
//
//  Created by LN on 16/6/15.
//  Copyright © 2017年 Learning point. All rights reserved.
/**
 新知识点
 CAShapeLayer:形状图层
 */

#import "LNBageValueBtn.h"

@interface LNBageValueBtn ()
/** 小圆 */
@property (nonatomic, weak) UIView *smallCircle;

@property (nonatomic, weak) CAShapeLayer *shapL;
@end

@implementation LNBageValueBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
        // 添加手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

//- (void)shapLayer{
//    _shapL = [CAShapeLayer layer];
//    [self.layer insertSublayer:_shapL atIndex:0];
//    _shapL.fillColor = [UIColor yellowColor].CGColor;
//}

// 懒加载
// 形状图层
- (CAShapeLayer *)shapL{
    if (!_shapL) {
        CAShapeLayer *shapL = [CAShapeLayer layer];
        [self.superview.layer insertSublayer:shapL atIndex:0];
        shapL.fillColor = [UIColor redColor].CGColor;
        _shapL = shapL;
    }
    return _shapL;
}

- (void)awakeFromNib{
    // 初始化
    [self setUp];
    // 添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:pan];
}

- (void)setUp{
    // 圆角
    self.layer.cornerRadius = self.bounds.size.width *0.5;
    // 设置背景颜色
    [self setBackgroundColor:[UIColor redColor]];
    [self setTitle:@"11" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    
    // 添加小圆
    UIView *smallCircle = [[UIView alloc] initWithFrame:self.frame];
    self.smallCircle = smallCircle;
    smallCircle.layer.cornerRadius = self.layer.cornerRadius;
    smallCircle.backgroundColor = [UIColor redColor];
    // 小圆添加到?
    [self.superview addSubview:smallCircle];
    
    // 把一个UIView添加到指定的位置(belowSubview:下面)
    [self.superview insertSubview:smallCircle belowSubview:self];
    
}

// 取消Btn的高亮状态
- (void)setHighlighted:(BOOL)highlighted{
    
}

- (void)panGesture:(UIPanGestureRecognizer *)pan{
    // 偏移量
    CGPoint transP = [pan translationInView:self];
    
    /**
     transform并没有修改cneter,它修改的是frame
     下面求两个圆之间的距离用的是center,在这里就不能用transform
     */
    //self.transform = CGAffineTransformTranslate(self.transform, transP.x, transP.y);
    
    CGPoint center = self.center;
    center.x += transP.x;
    center.y += transP.y;
    self.center = center;
    
    // 复位
    [pan setTranslation:CGPointZero inView:self];
    
    // 两个圆之间的距离
    CGFloat distance = [self distanceWithSmallCircle:self.smallCircle BigCircle:self];
    
    /**
     让小圆半径根据距离的增大,半径减小
     smallR都是相对原始半径(小圆半径和Btn的frame一样,就可以写self.)
     */
    CGFloat smallR = self.bounds.size.width *0.5;
    smallR -=distance / 10.0;
    self.smallCircle.bounds = CGRectMake(0, 0, smallR *2, smallR *2);
    self.smallCircle.layer.cornerRadius = smallR;
    
    //NSLog(@"%f",distance);
    
    UIBezierPath *path = [self pathWithSmallCircle:self.smallCircle BigCircle:self];
    // 形状图层*+
    if (self.smallCircle.hidden == NO) {
        self.shapL.path = path.CGPath;
    }
    // 判断两个圆之间的距离
    if (distance > 60) {
        // 让小圆隐藏,让路径隐藏
        self.smallCircle.hidden = YES;
        //self.shapL.hidden = YES;// 非根层会有阴式动画
        [self.shapL removeFromSuperlayer];
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        // 判断结束时,距离是否大于60
        if (distance > 60) {// 大于60让按钮消失
            /*
             // 播放一个动画消失(粒子效果)
             UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
             NSMutableArray *imageArray = [NSMutableArray array];
             for (int i = 0; i < 8; i++) {
             UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i+1]];
             [imageArray addObject:image];
             }
             imageView.animationImages = imageArray;
             imageView.animationDuration = 1;
             [imageView startAnimating];
             
             [self addSubview:imageView];
             
             */
            // 延迟执行*+
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        } else {// 小于60复位
            
            //[UIView animateWithDuration:0.1 animations:^{
            [self.shapL removeFromSuperlayer];
            self.center = self.smallCircle.center;
            self.smallCircle.hidden = NO;
            //}];
        }
    }
}


/**
 方法封装
 求两个圆之间的距离
 */
- (CGFloat)distanceWithSmallCircle:(UIView *)smallCircle BigCircle:(UIView *)bigCircle{
    // x轴方法的偏移量
    CGFloat offsetX = bigCircle.center.x - smallCircle.center.x;
    // y轴方法的偏移量
    CGFloat offsetY = bigCircle.center.y - smallCircle.center.y;
    return sqrt(offsetX * offsetX + offsetY * offsetY);;
}

/**
 给定两个圆,描述一个不规则的路径
 */
- (UIBezierPath *)pathWithSmallCircle:(UIView *)smallCircle BigCircle:(UIView *)bigCircle{
    
    CGFloat x1 = smallCircle.center.x;
    CGFloat y1 = smallCircle.center.y;
    
    CGFloat x2 = bigCircle.center.x;
    CGFloat y2 = bigCircle.center.y;
    
    CGFloat d = [self distanceWithSmallCircle:smallCircle BigCircle:bigCircle];
    if (d <= 0) {
        return nil;
    }
    
    CGFloat cos0 = (y2 - y1) / d;
    CGFloat sin0 = (x2 - x1) / d;
    
    CGFloat r1 = smallCircle.bounds.size.width * 0.5;
    CGFloat r2 = bigCircle.bounds.size.width * 0.5;
    
    CGPoint pointA = CGPointMake(x1 - r1 *cos0, y1 + r1 *sin0);
    CGPoint pointB = CGPointMake(x1 + r1 *cos0, y1 - r1 *sin0);
    CGPoint pointC = CGPointMake(x2 + r2 *cos0, y2 - r2 *sin0);
    CGPoint pointD = CGPointMake(x2 - r2 *cos0, y2 + r2 *sin0);
    CGPoint pointO = CGPointMake(pointA.x + d *0.5 *sin0,pointA.y + d *0.5 *cos0);
    CGPoint pointP = CGPointMake(pointB.x + d *0.5 *sin0,pointB.y + d *0.5 *cos0);
    
    /**
     描述点
     AB BC CD DA
     */
    UIBezierPath *path = [UIBezierPath bezierPath];
    // AB
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    // BC(曲线)
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // CD
    [path addLineToPoint:pointD];
    // DA(曲线)
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}


@end
