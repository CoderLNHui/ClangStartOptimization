//
//  UIImage+image.h
//
//  Created LN on 16/6/15.
//  Copyright © 2016年 Learning Point. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (image)

/** 返回一张没有经过渲染的图片 */ 
+ (UIImage *)imageWithOriginalImageName:(NSString *)imageName;

/** 返回一张受保护的图片(被拉伸的) */
+ (instancetype)imageWithTensileImageName:(NSString *)ImageName;


@end
