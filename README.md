# iOS-Animation

## 夯实基础-CALayer
### CALayer的介绍
- 个人理解，CALayer 是定义在 QuartzCore 框架中，从下图可以看出 UIView内部定义了一个CALayer对象，它是用来在屏幕上显示内容展示的矩形区域；
- CALayer是个与UIView很类似的概念，同样有backgroundColor、frame等相似的属性，我们可以将UIView看做一种特殊的CALayer。但实际上UIView是对CALayer封装，在CALayer的基础上再添加交互功能。UIView的显示必须依赖于CALayer。我们同样可以跟新建view一样新建一个layer，然后添加到某个已有的layer上，同样可以对layer调整大小、位置、透明度等。**layer可以有两种用途**：一是对view相关属性的设置，包括圆角、阴影、边框等参数；二是实现对view的动画操控。因此对一个view进行动画，本质上是对该view的.layer进行动画操作；

### UIView和CALayer的区别和选择
- **UIView和CALayer区别**
 - 在创建UIView对象时，UIView内部会自动创建一个图层(即`CALayer对象`)，CALayer 在背后提供内容的绘制和显示；两者都有树状层级结构，`layer 内部有 SubLayers，View 内部有 SubViews.但是 Layer 比 View 多了个AnchorPoint(锚点)`。

 - 当UIView需要显示到屏幕上时（`UIView 做为 Layer 的 CALayerDelegate，View 显示内容由CALayer 的 display`），会调用drawRect:方法进行绘图，并且会将所有内容绘制在自己的图层上，绘图完毕后，系统会将图层拷贝到屏幕上，于是就完成了UIView的显示。
换句话说，`UIView本身不具备显示的功能，是因为它内部的图层（CALayer）才有显示功能`

 - Layer 的 frame 是由它的 bounds、position、anchorPoint 和 transform 共同决定的；View 的 frame 只是简单的返回 Layer的 frame，同样 View 的 bounds 和 center 也是返回 Layer 的一些属性。

 - UIView 多了一个事件处理的功能,也就是说 UIView 可以处理用户的触摸事件,而 CALayer 不可以。

- UIView和CALayer选择
 - 通过CALayer，也能做出和 UIImageView 一样的效果，相比较UIView多了一个事件处理的功能；
所以，如果显示出来的东西需要跟用户进行交互的话，用UIView；如果不需要进行交互，用UIView和CALayer都可以；

 - 当然，CALayer 的性能会高一些，因为它少了事件处理的功能，更轻量级(实际开发中还是建议使用UIView,可扩展性强)；


### CALayer的基本使用
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


## 活学活用-Core Animation
 Core Animation是iOS和macOS平台上负责图形渲染与动画的基础框架。Core Animation可以作用与动画视图或者其他可视元素，为你完成了动画所需的大部分绘帧工作。你只需要配置少量的动画参数（如开始点的位置和结束点的位置）即可使用Core Animation的动画效果。Core Animation将大部分实际的绘图任务交给了图形硬件来处理，图形硬件会加速图形渲染的速度。这种自动化的图形加速技术让动画拥有更高的帧率并且显示效果更加平滑，不会加重CPU的负担而影响程序的运行速度。

### Core Animation 框架
- `CATransition 转场动画`
- `CABasicAnimation 基础动画`
- `CASpringAnimation 弹簧动画`
- `CAKeyframeAnimation 关键帧动画`
- `CAAnimationGroup 动画组`


### 其它
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












