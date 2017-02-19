[TOC]
# iOS-Core-Animation

## 夯实基础-CALayer
### CALayer的介绍
- 个人理解，CALayer 是定义在 QuartzCore 框架中，从下图可以看出 UIView内部定义了一个CALayer对象，它是用来在屏幕上显示内容展示的矩形区域；
- CALayer是个与UIView很类似的概念，同样有backgroundColor、frame等相似的属性，我们可以将UIView看做一种特殊的CALayer。但实际上UIView是对CALayer封装，在CALayer的基础上再添加交互功能。UIView的显示必须依赖于CALayer。我们同样可以跟新建view一样新建一个layer，然后添加到某个已有的layer上，同样可以对layer调整大小、位置、透明度等。一**layer可以有两种用途**：一是对view相关属性的设置，包括圆角、阴影、边框等参数；二是实现对view的动画操控。因此对一个view进行动画，本质上是对该view的.layer进行动画操作；

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


![iOS常用动画活用.gif](http://upload-images.jianshu.io/upload_images/2230763-030f2c70525c831a.gif?imageMogr2/auto-orient/strip)















