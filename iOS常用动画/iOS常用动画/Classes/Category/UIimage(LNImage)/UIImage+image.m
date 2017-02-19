//
//  UIImage+image.m
//
//  Created LN on 16/6/15.
//  Copyright © 2016年 Learning Point. All rights reserved.
//

#import "UIImage+image.h"

@implementation UIImage (image)

/** 返回一张没有经过渲染的图片 */
+ (UIImage *)imageWithOriginalImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    return  [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

/** 返回一张受保护的图片(被拉伸的) */
+ (instancetype)imageWithTensileImageName:(NSString *)ImageName
{
    // 创建图片对象
    UIImage *image     = [UIImage imageNamed:ImageName];
    // 获取图片的尺寸
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeiht = image.size.height;
    
    // 返回一张拉伸且受保护的图片
    return [image stretchableImageWithLeftCapWidth:imageWidth * 0.5 topCapHeight:imageHeiht * 0.5 ];
}

@end







