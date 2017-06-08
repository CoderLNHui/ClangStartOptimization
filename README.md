## iOS-Animation

### CALayer
- CALayer的常用属性

| 属性 | 描述 |
|:-:|:-:|  
| bounds    | 图层大小 | 
| position  | 用来设置CALayer在父层中的位置，以父层的左上角为原点(0, 0)，相当于UIView的center |
| anchorPoint  | 称为“锚点”，决定着CALayer身上的哪个点会在position属性所指的位置,以自己的左上角为原点(0, 0)，x、y取值范围都是0~1，默认值为（0.5, 0.5） |
| contents  | 内容：image添加到layer的contents，（使用如：`.CGImage` 或 `.CGColor）` | 
| opacity   | 透明度，相当于UIView的alpha | 
| contentsRect | 设置图片显示的尺寸，取值0~1(x0, y0, W1, H1)，如 CGRectMake(0, 0, 1, 0.5);只将图像的上半部分显示在整个layer中； | 
| CATransform3D | 形变属性(设置平移、缩放和旋转时的 3D效果) |
| cornerRadius / masksToBounds   | 圆角半径 / 属性为YES才显示圆角效果 | 


### Core Animation

**Core Animation 框架**
- `CATransition 转场动画`
- `CABasicAnimation 基础动画`
- `CASpringAnimation 弹簧动画`
- `CAKeyframeAnimation 关键帧动画`
- `CAAnimationGroup 动画组`


**其它动画**
- `系统自带的 animationImages`
- `UIView代码块加Block`
- `UIView [begin commit]模式`
- `物理动效(重力、碰撞、吸附、推力、关联)`
 - `UIGravityBehavior 重力`
 - `UICollisionBehavior 碰撞`
 - `UISnapBehavior 吸附`
 - `UIPushBehavior 推力`
 - `UIAttachmentBehavior 关联`
- `粒子系统`
 - `CAEmitterCell`
 - `CAEmitterLayer`
- `facebook pop动画`
 - `POPDecayAnimation 减速动画`
 - `POPSpringAnimation 弹簧效果`
 - `POPSpringAnimation 飞入效果`
 - `支持自定义动画`

### Transform field value key paths
 
|Field Key Path    |     Description      |
|:-:|:-:|
| translation.x | 设置为一个NSNumber对象的值是沿着x轴平移。 | 
| translation.y | 设置为一个NSNumber对象的值沿y轴平移。 | 
| translation.z | 设置为一个NSNumber对象的值沿z轴平移。 | 
| translation | 设置为一个NSValue对象包含一个NSSize或CGSize数据类型。数据类型表示将在x和y轴。 |
| scale.x | 设置为一个NSNumber对象的值是x轴缩放。 | 
| scale.y | 设置为一个NSNumber对象的值是y轴缩放。 | 
| scale.z | 设置为一个NSNumber对象的值是z轴缩放。 | 
| scale | 设置为一个NSNumber对象的值是所有三个规模因素的平均值。 | 
| rotation.x | 设置为一个NSNumber对象的值是旋转,弧度,x轴。 | 
| rotation.y | 设置为一个NSNumber对象的值是旋转,弧度,y轴。 | 
| rotation.z | 设置为一个NSNumber对象的值是旋转,弧度,z轴。 | 
| rotation | 设置为一个NSNumber对象的值是旋转,弧度,z轴。这个字段是一样设置旋转。z域。 |
 
 
 
### 基础动画效果
![iOS常用动画基础.gif](http://upload-images.jianshu.io/upload_images/2230763-5ec1cb3b7c7eb274.gif?imageMogr2/auto-orient/strip)

### 活用动画效果
![iOS常用动画活用.gif](http://upload-images.jianshu.io/upload_images/2230763-030f2c70525c831a.gif?imageMogr2/auto-orient/strip)










