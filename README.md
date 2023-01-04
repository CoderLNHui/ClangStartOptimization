# 启动优化-clang静态插桩实现二进制重排优化启动时间

## 总结
本篇文章通过以实际探索过程为基准 , 一步一步实现clang静态插桩达到二进制重排优化启动时间的完整流程 .

## 原理

- 利用编译期`clang 静态插桩`的方式来 hook 获取启动时期需要加载的所有函数/方法 , `block` , `swift 方法`以及 `c++构造方法`的符号 .
- 通过 `order file 机制`实现二进制重排 .
- 二进制重排利用符号顺序 , 重新排列整个代码在文件的偏移地址 , 
  将启动需要加载的方法地址放到前面内存页中 , 以此达到减少 page fault 的次数从而实现时间上的优化。
 
### 虚拟内存和物理内存的原理

> 利用虚拟内存的分页、懒加载、覆盖机制以及ASLR技术，解决内存浪费和效率以及安全问题。

- 引入虚拟内存后 , cpu 在通过虚拟内存地址访问数据时，
    首先通过虚拟内存地址 , 找到对应进程的映射表， 然后通过映射表找到其对应的真实物理地址 , 进而找到数据。
    这个过程被称为 地址翻译 。
- 利用内存分页和覆盖机制解决内存浪费和效率问题。
    应用是懒加载到内存中的，并不会将整个应用加载到内存中 . 只会放用到的那一部分 。
    当应用访问到某个并没有被加载到物理内存中地址，(映射表中为 0)系统就会立刻阻塞整个进程，触发缺页中断 - Page Fault，
    操作系统会从磁盘中重新读取这页数据到物理内存上 , 然后将映射表中虚拟内存指向对应。
    若当前内存已满 , 操作系统会通过置换页算法，找一页数据进行覆盖。
- 利用ASLR技术，每次 虚拟地址在映射真实地址之前 , 增加一个随机偏移值。

### 二进制重排原理

> 二进制重排利用符号顺序 , 重新排列整个代码在文件的偏移地址 , 将启动需要加载的方法地址放到前面内存页中 , 以此达到减少 page fault 的次数从而实现时间上的优化。

- 查看缺页中断（ page fault）
通过 `Instruments` , 选择 System Trace(系统跟踪) 可以查看缺页中断（ page fault）

- 配置Order File的文件路径
通过配置Xcode的链接器ld的Order File的文件路径，在Order File中，将需要的符号按顺序写在里面，
当工程 build 的时候 , Xcode 会读取这个文件 , 打的二进制包就会按照这个文件中的符号顺序进行生成对应的 mach-O。

- 查看工程的符号顺序
通过 `Link Map`查看工程的符号顺序。
Link Map 是编译期间产生的产物，记录了二进制文件的布局，通过设置 Write Link Map File 来设置输出与否。

- 获取启动加载所有函数的符号
通过编译期clang 静态插桩的方式来 hook 获取所有的函数符号。

### Clang 静态插桩原理

> 在编译期就在每一个函数内部二进制源数据添加 hook 代码 ( 我们添加的 __sanitizer_cov_trace_pc_guard 函数 ) 来实现全局的方法 hook 的效果 

- 编译设置
在 `Other C Flags`中添加`-fsanitize-coverage=trace-pc-guard` （trace-pc-guard：跟踪pc保护）
- 添加 hook 代码
```Swift
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                                    uint32_t *stop) {
  static uint64_t N;  // Counter for the guards.
  if (start == stop || *start) return;  // Initialize only once.
  printf("INIT: %p %p\n", start, stop);
  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;  // Guards should start from 1.
}
/**
在 __sanitizer_cov_trace_pc_guard 这个函数中 ,通过 __builtin_return_address 函数
拿到原函数调用 __sanitizer_cov_trace_pc_guard 这句汇编代码的下一条指令的地址 
*/
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
  if (!*guard) return;  // Duplicate the guard check.

  void *PC = __builtin_return_address(0); // 作用：读取 x30 中所存储的要返回时下一条指令的地址 
      Dl_info info;
  dladdr(PC, &info); //这个函数能通过函数内部地址找到函数符号
  printf("fname所在文件=%s \nfbase文件地址=%p \nsname符号名称=%s\nsaddr函数起始地址=%p \n",info.dli_fname,info.dli_fbase,info.dli_sname,info.dli_saddr);

  char PcDescr[1024];
  //__sanitizer_symbolize_pc(PC, "%p %F %L", PcDescr, sizeof(PcDescr));
  printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
}
```


## 前言

了解二进制重排之前 , 我们需要了解一些前导知识 , 以及二进制重排是为了解决什么问题 .

## 虚拟内存与物理内存
在早期的计算机中，并没有虚拟内存的概念，任何应用被从磁盘中加载到运行内存中时，都是完整加载和按序排列的。
![G221123220401_应用加载到内存](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123220401_应用加载到内存.png)

那么因此 , 就会出现两个问题 :
### 使用物理内存时遗留的问题
  - `安全问题` : 由于在内存条中使用的都是真实物理地址 , 而且内存条中各个应用进程都是按顺序依次排列的。
            那么在`进程1`中通过地址偏移就可以访问到 `其他进程` 的内存。
  - `效率问题` : 随着软件的发展 , 一个软件运行时需要占用的内存越来越多 , 但往往用户并不会用到这个应用的所有功能，
            造成很大的内存浪费 , 而后面打开的进程往往需要排队等待。
为了解决上述两个问题 , 虚拟内存应运而生 .
### 虚拟内存工作原理
引用了虚拟内存后 , 在我们进程中认为自己有一大片连续的内存空间实际上是虚拟的 , 也就是说从 0x000000 ~ 0xffffff 我们是都可以访问的 . 
但是实际上这个内存地址只是一个虚拟地址 , 而这个虚拟地址通过一张映射表映射后才可以获取到真实的物理地址 .
什么意思呢 ?
 - 1、实际上我们可以理解为 , 系统对真实物理内存访问做了一层限制 , 只有被写到映射表中的地址才是被认可可以访问的 .
 - 2、例如 , 虚拟地址 0x000000 ~ 0xffffff 这个范围内的任意地址我们都可以访问 , 
    但是这个虚拟地址对应的实际物理地址是计算机来随机分配到内存页上的 .

这里提到了实际物理内存分页的概念 , 下面会详细讲述 .
 >（可能大家也有注意到 , 我们在一个工程中获取的地址 , 同时在另一个工程中去访问 , 并不能访问到数据 , 其原理就是虚拟内存 .）

整个虚拟内存的工作原理这里用一张图来展示 :
![G221123221312_虚拟内存的工作原理](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123221312_虚拟内存的工作原理.png)

### 虚拟内存解决进程间安全问题原理
显然 , 引用虚拟内存后就不存在通过偏移可以访问到其他进程的地址空间的问题了 .
> 因为每个进程的映射表是单独的 , 在你的进程中随便你怎么访问 , 这些地址都是受映射表限制的 , 
其真实物理地址永远在规定范围内 , 也就不存在通过偏移获取到其他进程的内存空间的问题了 .

而且实际上 , 每次应用被加载到内存中 , 实际分配的物理内存并不一定是固定或者连续的 , 
这是因为内存分页以及懒加载以及 ASLR(地址空间布局随机化) 所解决的安全问题 .

### cpu 寻址过程
引入虚拟内存后 , cpu 在通过虚拟内存地址访问数据的过程如下 :
  - 1、通过虚拟内存地址 , 找到对应进程的映射表 .
  - 2、通过映射表找到其对应的真实物理地址 , 进而找到数据 .
       这个过程被称为地址翻译, 这个过程是由操作系统以及 cpu 上集成的一个`硬件单元 MMU`协同来完成的 .

那么安全问题解决了以后 , 效率问题如何解决呢 ?

### 虚拟内存解决效率问题

刚刚提到虚拟内存和物理内存通过映射表进行映射 , 但是这个映射并不可能是一一对应的 , 那样就太过浪费内存了 . 
为了解决效率问题 , 实际上真实物理内存是分页的 . 而映射表同样是以页为单位的 .

换句话说 , 映射表只会映射到一页 , 并不会映射到具体每一个地址 .

在linux系统中 , 一页内存大小为4KB, 在不同平台可能各有不同 .

Mac OS 系统中 , 一页为4KB,
iOS 系统中 , 一页为`16KB.`
我们可以使用pagesize命令直接查看 .


那么为什么说内存分页就可以解决内存浪费的效率问题呢 ?

### 内存分页原理
假设当前有两个进程正在运行 , 其状态就如下图所示 :

![G221123222312_内存分页原理](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123222312_内存分页原理.png)

> ( 上图中我们也看出 , 实际物理内存并不是连续以及某个进程完整的 ) .
映射表左侧的0和1代表当前地址有没有在物理内存中 . 为什么这么说呢 ?

  - 当应用被加载到内存中时 , 并不会将整个应用加载到内存中 . 只会放用到的那一部分 . 也就是懒加载的概念 , 
    换句话说就是应用使用多少 , 实际物理内存就实际存储多少 .
  - 当应用访问到某个地址 , 映射表中为0, 也就是说并没有被加载到物理内存中时 , 
    系统就会立刻阻塞整个进程 , 触发一个我们所熟知的 `缺页中断/中断异常`(Page Fault)
  - 当一个缺页中断被触发 , 操作系统会从磁盘中重新读取这页数据到物理内存上 , 然后将映射表中虚拟内存指向对应 
    > (如果当前内存已满 , 操作系统会通过置换页算法`找一页数据进行覆盖`, 这也是为什么开再多的应用也不会崩掉 , 
    但是之前开的应用再打开时 , 就重新启动了的根本原因 ).

通过这种分页和覆盖机制 , 就完美的解决了内存浪费和效率问题 .
但是此时 , 又出现了一个问题 .
问 : 当应用开发完成以后由于采用了虚拟内存 , 那么其中一个函数无论如何运行 , 运行多少次 , 都会是虚拟内存中的固定地址 .

> 什么意思呢 ?
假设应用有一个函数 , 基于首地址偏移量为0x00a000, 那么虚拟地址从0x000000 ~ 0xffffff, 基于这个 , 
那么这个函数我无论如何只需要通过0x00a000这个虚拟地址就可以拿到其真实实现地址 .
而这种机制就给了很多黑客可操作性的空间 , 他们可以很轻易的提前写好程序获取固定函数的实现进行修改hook操作 .

为了解决这个问题 , `ASLR(地址空间布局随机化)`应运而生 . 
其原理就是 每次 虚拟地址在映射真实地址之前 , 增加一个随机偏移值 , 以此来解决我们刚刚所提到的这个问题 .
至此 , 有关物理内存 , 虚拟内存 , 内存分页的完整流程和原理 , 我们已经讲述完毕了 , 那么接下来来到重点 , 二进制重排 .


## 二进制重排

### 概述

在了解了内存分页会触发中断异常`Page Fault`会阻塞进程后 , 我们就知道了这个问题是会对性能产生影响的 .
实际上在 iOS 系统中 , 对于生产环境的应用 , 当产生缺页中断进行重新加载时 , iOS 系统还会对其做一次签名验证 . 
因此 iOS 生产环境的应用`Page Fault`所产生的耗时要更多 .

当用户使用应用时 , 第一个直接印象就是启动 app 耗时 , 而恰巧由于启动时期有大量的类 , 分类 , 三方 等等需要加载和执行 ,
多个`Page Fault`所产生的的耗时往往是不能小觑的 . 这也是二进制重排进行启动优化的必要性 

### 二进制重排优化原理

假设在启动时期我们需要调用两个函数method1与method4. 
函数编译在mach-o中的位置是根据ld( Xcode 的链接器) 的编译顺序并非调用顺序来的 . 
因此很可能这两个函数分布在不同的内存页上 .

![G221123224033_启动调用方法](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123224033_启动调用方法.png)

那么启动时 , page1与page2则都需要从无到有加载到物理内存中 , 从而触发两次page fault.
而二进制重排的做法就是将method1与method4放到一个内存页中 , 那么启动时则只需要加载page1即可 , 
也就是只触发一次page fault, 达到优化目的 .
**实际项目中的做法是将启动时需要调用的函数放到一起 (比如 `前10页`中 ) 以尽可能减少 page fault , 达到优化目的**  . 
而这个做法就叫做 : **二进制重排** .

讲到这里相信很多同学已经迫不及待的想要看看具体怎么二进制重排了 . 其实操作很简单 , 但是在操作之前我们还需要知道这几点 :
> - 如何检测page fault: 首先我们要想看到优化效果 , 就应该知道如何查看page fault, 以此来帮助我们查看优化前以及优化后的效果
>- 如何重排二进制 .
>- 如何查看自己重排成功了没有 ?
>- 如何检测自己启动时刻需要调用的所有方法 .
    1.`hook objc_MsgSend` ( 只能拿到oc以及swift加上@objc dynamic修饰后的方法 ) .
    2.静态扫描`macho`特定段和节里面所存储的符号以及函数数据 .  (静态扫描 , 主要用来获取`load`方法 , `c++`构造)
    3.`clang插桩` ( 完美版本 , 完全拿到swift,oc,c,block全部函数 )

内容很多 , 我们一项一项来 .

### 如何查看page fault
> 提示 :
如果想查看真实page fault次数 , 应该将应用卸载 , 查看第一次应用安装后的效果 , 或者先打开很多个其他应用 .
因为之前运行过 app , 应用其中一部分已经被加载到物理内存并做好映射表映射 , 这时再启动就会少触发一部分缺页中断 , 并且杀掉应用再打开也是如此 .
其实就是希望将物理内存中之前加载的覆盖/清理掉 , 减少误差 .

- 1、 打开 `Instruments` , 选择 System Trace(系统跟踪) .

![G221123225234_SystemTrace](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123225234_SystemTrace.png)

- 2、`选择真机 , 选择工程 , 点击启动 , 当首个页面加载出来点击停止` . 
>(这里注意 , 最好是将应用杀掉重新安装 , 因为`冷热启动的界定其实由于进程的原因`并不一定后台杀掉应用重新打开就是冷启动 .)

- 3、等待分析完成 , 查看缺页次数


当然 , 你可以通过添加 `DYLD_PRINT_STATISTICS` 来查看 `pre-main` 阶段总耗时来做一个侧面辅证 .

### 二进制重排具体如何操作
说了这么多前导知识 , 终于要开始做二进制重排了 , 其实具体操作很简单 , Xcode 已经提供好这个机制 ,
并且 `libobjc` 实际上也是用了二进制重排进行优化 .

- 首先 , Xcode 是用的链接器叫做ld ,ld有一个参数叫`Order File` , 我们可以通过这个参数配置一个order文件的路径 .
  如：`$(SRCROOT)/lb.order`
- 在这个 order 文件中 , 将你需要的符号按顺序写在里面 .
- 当工程 `build` 的时候 , Xcode 会读取这个文件 , 打的二进制包就会按照这个文件中的符号顺序进行生成对应的 `mach-O` .

![G221123214949_配置order路径](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123214949_配置order路径.png)

### 二进制重排疑问 - 题外话 :
- 1、 `order` 文件里 符号写错了或者这个符号不存在会不会有问题 ?
  - 答 : ld 会忽略这些符号 , 实际上如果提供了 link 选项 `-order_file_statistics`，
        会以 warning 的形式把这些没找到的符号打印在日志里。
- 2、有部分同学可能会考虑这种方式会不会影响上架 ?
  - 答 : 首先 , objc 源码自己也在用这种方式 .
- 二进制重排只是重新排列了所生成的 macho 中函数表与符号表的顺序 .

### 如何查看自己工程的符号顺序
重排前后我们需要查看自己的符号顺序有没有修改成功 , 这时候就用到了 `Link Map` .
`Link Map` 是编译期间产生的产物 ,
 ( ld 的读取二进制文件顺序默认是按照 Compile Sources （编译源代码） - GUI 里的顺序 ) , 
它记录了二进制文件的布局 . 通过设置 Write Link Map File 来设置输出与否 , 默认是 no .

![G221123230641_linkmap](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123230641_linkmap.png)

修改完毕后 `clean` 一下 , 运行工程 , `Products - show in finder`, 找到 `macho` 的上上层目录.
![G221123231350_macho的上上层目录](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123231350_macho的上上层目录.png)


 按下图依次找到最新的一个 .txt 文件并打开.
![G221123231407_txt文件](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123231407_txt文件.png)

 这个文件中就存储了所有符号的顺序 , 在 # Symbols: 部分 
 ![G221123231438_所有符号的顺序](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123231438_所有符号的顺序.png)

 可以看到 , 这个符号顺序明显是按照 `Compile Sources` 的文件顺序来排列的 .
![G221123231458_CompileSources的文件顺序](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123231458_CompileSources的文件顺序.png)

### 提示：
上述文件中最左侧地址就是 **实际代码地址而并非符号地址 , 因此我们二进制重排并非只是修改符号地址 , 而是利用符号顺序 , 重新排列整个代码在文件的偏移地址 , 将启动需要加载的方法地址放到前面内存页中 , 以此达到减少 `page fault` 的次数从而实现时间上的优化**
 , 一定要清楚这一点 .
你可以利用 `MachOView`查看排列前后在 `_text 段 ( 代码段 )` 中的源码顺序来帮助理解 .

### 实战演练
来到工程根目录 , 新建一个文件 `touch lb.order` . 随便挑选几个启动时就需要加载的方法 , 例如我这里选了以下几个 .
```Swfit
-[LBOCTools lbCurrentPresentingVC]
+[LBOCTools lbGetCurrentTimes]
+[RSAEncryptor stripPublicKeyHeader:]
```
写到该文件中 , 保存 , 配置文件路径 .
![G221123214949_配置order路径](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123214949_配置order路径.png)

重新运行 , 查看 .
![G221123232314_order后的方法调用顺序](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123232314_order后的方法调用顺序.png)

可以看到 , 我们所写的这三个方法已经被放到最前面了 , 至此 , 
生成的macho中距离首地址偏移量最小的代码就是我们所写的这三个方法 , 
假设这三个方法原本在不同的三页 , 那么我们就已经优化掉了两个page fault.

### 获取启动加载所有函数的符号

讲到这 , 我们就只差一个问题了 , 那就是如何知道我的项目启动需要调用哪些方法 , 上述篇章中我们也有稍微提到一点 .

- `hook objc_MsgSend`( 只能拿到oc以及swift @objc dynamic后的方法 , 并且由于可变参数个数 , 需要用汇编来获取参数 .)
- 静态扫描`macho`特定段和节里面所存储的符号以及函数数据 . (静态扫描 , 主要用来获取`load`方法 , `c++`构造) .
- `clang插桩` ( 完美版本 , 完全拿到swift , oc , c , block全部函数 ) .

前两种这里我们就不在赘述了 . 网上参考资料也较多 , 而且实现效果也并不是完美状态 ,
 本文我们来谈谈如何通过编译期插桩的方式来hook获取所有的函数符号 .

 ## clang 插桩

 关于 `clang` 的插桩覆盖的官方文档如下 :  [clang 自带代码覆盖工具](https://clang.llvm.org/docs/SanitizerCoverage.html) 文档中有详细概述 , 以及简短 Demo 演示 .

### 思考
其实 clang 插桩主要有两个实现思路 , 
一是自己编写 clang 插件 ( 自定义 clang 插件在后续底层篇 llvm 中会带着大家来手写一个自己的插件 ) , 
另外一个就是利用 clang 本身已经提供的一个工具 or 机制来实现我们获取所有符号的需求 . 
本文我们就按照第二种思路来实际演练一下 .

### 原理探索
新建一个工程来测试和使用一下这个静态插桩代码覆盖工具的机制和原理 .
按照文档指示来走
- 首先 , 添加编译设置
直接搜索 `Other C Flags` 来到 `Apple Clang - Custom Compiler Flags` 中 , 添加`-fsanitize-coverage=trace-pc-guard`

![G221123215233_添加Clang的编译设置](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123215233_添加Clang的编译设置.png)

- 添加 hook 代码 
```Swift

#include <stdint.h>
#include <stdio.h>
#include <sanitizer/coverage_interface.h>

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,uint32_t *stop) {
  static uint64_t N;  // Counter for the guards.
  if (start == stop || *start) return;  // Initialize only once.
  printf("INIT: %p %p\n", start, stop);
  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;  // Guards should start from 1.
}
 
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
  if (!*guard) return;  // Duplicate the guard check.
 
  void *PC = __builtin_return_address(0);
  char PcDescr[1024];
  //__sanitizer_symbolize_pc(PC, "%p %F %L", PcDescr, sizeof(PcDescr));
  printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
}


```

笔者这里是写在空工程的`ViewController.m`里的.
运行工程 , 查看打印

![G221123233317_clang打印](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123233317_clang打印.png)

代码命名INIT后面打印的两个指针地址叫start和stop. 那么我们通过lldb来查看下从start到stop这个内存地址里面所存储的到底是啥 .


发现存储的是从 1 到 14 这个序号 . 那么我们来添加一个oc方法 .

```Swift
- (void)testOCFunc{
     
}

```
再次运行查看 .
![G221123233622_clang添加函数](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123233622_clang添加函数.png)
发现从0e变成了0f. 也就是说存储的 1 到 14 这个序号变成了 1 到 15 .
那么我们再添加一个`c函数` , 一个`block`, 和一个`触摸屏幕方法`来看下 .
![G221123233717_clang再添加3个方法](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123233717_clang再添加3个方法.png)

同样发现序号依次增加到了18个 , 那么我们得到一个猜想 , 这个内存区间保存的就是工程所有符号的个数 .

其次 , 我们在触摸屏幕方法调用了c函数 ,c函数中调用了block. 那么我们点击屏幕 , 发现如下 :
![G221123233830_clang点击屏幕方法调用](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123233830_clang点击屏幕方法调用.png)

发现我们实际调用几个方法 , 就会打印几次 `guard :` .（guard：警卫）
实际上就类似我们埋点统计所实现的效果 . 在触摸方法添加一个断点查看汇编 :
![G221123233946_clang查看触摸方法的汇编实现](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123233946_clang查看触摸方法的汇编实现.png)

![G221123234222_clang的汇编](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123234222_clang的汇编.png)

通过汇编我们发现 , 
**在每个函数调用的第一句实际代码 ( 栈平衡与寄存器数据准备除外 ) , 被添加进去了一个 bl 调用到 `__sanitizer_cov_trace_pc_guard`这个函数中来。**
> `bl` 汇编指令，跳转 

而实际上这也是静态插桩的原理和名称由来 .

### 静态插桩总结
**静态插桩实际上是在编译期就在每一个函数内部二进制源数据添加`hook`代码 ( 我们添加的 `__sanitizer_cov_trace_pc_guard` 函数 ) 来实现全局的方法hook的效果 .**


### 疑问
可能有部分同学对我上述表述的原理总结有些疑问 .

究竟是直接修改二进制在每个函数内部都添加了调用 hook 函数这个汇编代码 ,
还是只是类似于编译器在所生成的二进制文件添加了一个标记 , 然后在运行时如果有这个标记就会自动多做一步调用 hook 代码呢 ? 

笔者这里使用 `hopper` 来看下生成的`mach-o`二进制文件 .

![G221123234829_clang通过hopper查看macho二进制文件](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221123234829_clang通过hopper查看macho二进制文件.png)

上述二进制源文件我们就发现 , 的确是函数内部 一开始就添加了`调用额外方法的汇编代码` . 这也是我们为什么称其为$\color{#FF0000}{静态插桩}$  .

讲到这里 , 原理我们大体上了解了 , 那么到底如何才能拿到函数的符号呢 ?

## 获取所有函数符号
### 思路
我们现在知道了 , 所有函数内部第一步都会去调用`__sanitizer_cov_trace_pc_guard`这个函数 .
那么熟悉汇编的同学可能就有这么个想法 :
 > 函数嵌套时 , 在跳转子函数时都会保存下一条指令的地址在 `X30` ( 又叫 lr 寄存器) 里 .

例如 , A 函数中调用了 B 函数 , 在 arm 汇编中即` bl + 0x****` 指令 , 
该指令会首先将下一条汇编指令的地址保存在 x30 寄存器中 ,然后在跳转到 bl 后面传递的指定地址去执行 .  
>( 提示 : bl 能实现跳转到某个地址的汇编指令 , 其原理就是修改 pc 寄存器的值来指向到要跳转的地址 , 
而且实际上 B 函数中也会对 x29 / x30 寄存器的值做保护防止子函数又跳转其他函数会覆盖掉 x30 的值 , 当然 , 叶子函数除外 . ) .

当 B 函数执行 ret 也就是返回指令时 , 就会去读取 x30 寄存器的地址 , 跳转过去 , 因此也就回到了上一层函数的下一步 .

这种思路来实现实际上是可以的 . 我们所写的 `__sanitizer_cov_trace_pc_guard` 函数中的这一句代码 :
```Swift
void *PC = __builtin_return_address(0);
```
它的作用其实就是去读取x30中所存储的要返回时下一条指令的地址 . 所以他名称叫做 __builtin_return_address . 
换句话说 , 这个地址就是我当前这个函数执行完毕后 , 要返回到哪里去 .
其实 , bt 函数调用栈也是这种思路来实现的 .

也就是说 , **我们现在可以在 `__sanitizer_cov_trace_pc_guard` 这个函数中 , 通过 `__builtin_return_address` 函数拿到原函数调用 `__sanitizer_cov_trace_pc_guard` 这句汇编代码的下一条指令的地址**.

可能有点绕 , 画个图来梳理一下流程 .

![G221124000154_clang拿到原函数的下一条指令](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221124000154_clang拿到原函数的下一条指令.png)

### 根据内存地址获取函数名称
拿到了函数内部一行代码的地址 , 如何获取函数名称呢 ? 这里笔者分享一下自己的思路 .

熟悉安全攻防 , 逆向的同学可能会清楚 . 我们为了防止某些特定的方法被别人使用 `fishhook hook` 掉 , 
会利用 `dlopen` 打开动态库 , 拿到一个句柄 , 进而拿到函数的内存地址直接调用 .

是不是跟我们这个流程有点相似 , 只是我们好像是反过来的 . 其实反过来也是可以的 .

与 dlopen 相同 , 在 dlfcn.h 中有一个方法如下 :

```Swift
typedef struct dl_info {
        const char      *dli_fname;     /* 所在文件 */
        void            *dli_fbase;     /* 文件地址 */
        const char      *dli_sname;     /* 符号名称 */
        void            *dli_saddr;     /* 函数起始地址 */
} Dl_info;
 
//这个函数能通过函数内部地址找到函数符号
int dladdr(const void *, Dl_info *);

```

紧接着我们来实验一下 , 先导入头文件`#import <dlfcn.h>`, 然后修改代码如下 :

```Swift
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    if (!*guard) return;  // Duplicate the guard check.
     
    void *PC = __builtin_return_address(0);
    Dl_info info;
    dladdr(PC, &info);
     
    printf("fname=%s \nfbase=%p \nsname=%s\nsaddr=%p \n",info.dli_fname,info.dli_fbase,info.dli_sname,info.dli_saddr);
     
    char PcDescr[1024];
    printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
}
```

 查看打印结果 :

 ![G221124000602_clang查看方法的打印结果](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221124000602_clang查看方法的打印结果.png)

 终于看到我们要找的符号了 .

### 收集符号
看到这里 , 很多同学可能想的是 , 那马上到工程里去拿到我所有的符号 , 写到 order 文件里不就完事了吗 ? 不能
### clang静态插桩 - 坑点1
- 多线程问题
> 这是一个多线程的问题 , 由于你的项目各个方法肯定有可能会在不同的函数执行 , 
因此 `__sanitizer_cov_trace_pc_guard` 这个函数也有可能受多线程影响 , 所以你当然不可能简简单单用一个数组来接收所有的符号就搞定了 .

那方法有很多 , 笔者在这里分享一下自己的做法 :
考虑到这个方法会来特别多次 , 使用锁会影响性能 , 这里使用苹果底层的原子队列 
( 底层实际上是个栈结构 , 利用队列结构 + 原子性来保证顺序 ) 来实现 .

```Swift

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //遍历出队
    while (true) {
        //offsetof 就是针对某个结构体找到某个属性相对这个结构体的偏移量
        SymbolNode * node = OSAtomicDequeue(&symboList, offsetof(SymbolNode, next));
        if (node == NULL) break;
        Dl_info info;
        dladdr(node->pc, &info);
         
        printf("%s \n",info.dli_sname);
    }
}
//原子队列
static OSQueueHead symboList = OS_ATOMIC_QUEUE_INIT;
//定义符号结构体
typedef struct{
    void * pc;
    void * next;
}SymbolNode;
 
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    if (!*guard) return;  // Duplicate the guard check.
    void *PC = __builtin_return_address(0);
    SymbolNode * node = malloc(sizeof(SymbolNode));
    *node = (SymbolNode){PC,NULL};
     
    //入队
    // offsetof 用在这里是为了入队添加下一个节点找到 前一个节点next指针的位置
    OSAtomicEnqueue(&symboList, node, offsetof(SymbolNode, next));
}


```
当你兴致冲冲开始考虑好多线程的解决方法写完之后 , 运行发现 :
死循环了 .

### clang静态插桩 - 坑点2
- **上述这种 clang 插桩的方式 , 会在循环中同样插入 hook 代码**.
当确定了我们队列入队和出队都是没问题的 , 你自己的写法对应的保存和读取也是没问题的 , 
我们发现了这个坑点 , 这个会死循环 , 为什么呢 ?
这里我就不带着大家去分析汇编了 , 直接说结论 :

**通过汇编会查看到 一个带有 while 循环的方法 , 会被静态加入多次 `__sanitizer_cov_trace_pc_guard`调用 , 导致死循环.**

### 解决方案

`Other C Flags` 修改为如下 :
```Swift
-fsanitize-coverage=func,trace-pc-guard
```

代表仅针对func进行hook. 再次运行 .

![G221124001356_clang获取方法进行hook](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221124001356_clang获取方法进行hook.png)

又以为完事了 ? 还没有..

### 坑点3 : load 方法
- **load 方法时 , `__sanitizer_cov_trace_pc_guard` 函数的参数 guard 是 0**.

上述打印并没有发现`load`.

解决 : 屏蔽掉 `__sanitizer_cov_trace_pc_guard` 函数中的

```Swift
if (!*guard) return;
```

![G221124001618_clang成功hook了load方法](https://cdn.jsdelivr.net/gh/SunHui-Candy/Simg@tc/22img/G221124001618_clang成功hook了load方法.png)

load方法就有了 .

> 这里也为我们提供了一点启示:
如果我们希望从某个函数之后/之前开始优化 , 通过一个全局静态变量 , 在特定的时机修改其值 , 在 `__sanitizer_cov_trace_pc_guard` 这个函数中做好对应的处理即可 .

### 剩余细化工作
- 如果你也是使用笔者这种多线程处理方式的话 , 由于用的先进后出原因 , 我们要倒叙一下
- 还需要做去重 .
- order文件格式要求c函数 ,block调用前面还需要加 _下划线 .
- 写入文件即可 .


 笔者demo完整代码如下 :

```Swift
/**
 启动优化：
 思路：clang静态插桩达到二进制重排优化启动时间
 利用编译期`clang 静态插桩`的方式来 hook 获取启动时期需要加载的所有函数/方法 , 包含：`block` , `swift 方法`以及 `c++构造方法`的符号 .
 通过 `order file 机制`实现二进制重排 .
 二进制重排利用符号顺序 , 重新排列整个代码在文件的偏移地址 , 
 将启动需要加载的方法地址放到前面内存页中 , 以此达到减少 page fault （缺页中断）的次数从而实现时间上的优化。
 */
#import "ViewController.h"
#import <dlfcn.h>
#import <libkern/OSAtomic.h>
@interface ViewController ()
@end
 
@implementation ViewController
+ (void)load{
     
}
- (void)viewDidLoad {
    [super viewDidLoad];
    testCFunc();
    [self testOCFunc];
}
- (void)testOCFunc{
    NSLog(@"oc函数");
}
void testCFunc(){
    LBBlock();
}
void(^LBBlock)(void) = ^(void){
    NSLog(@"block");
};
 
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                         uint32_t *stop) {
    static uint64_t N;  // Counter for the guards.
    if (start == stop || *start) return;  // Initialize only once.
    printf("INIT: %p %p\n", start, stop);
    for (uint32_t *x = start; x < stop; x++)
        *x = ++N;  // Guards should start from 1.
}
/**
 考虑到这个方法会来特别多次 , 使用锁会影响性能 , 这里使用苹果底层的原子队列
 (底层实际上是个栈结构 , 利用队列结构 + 原子性来保证顺序) 来实现 .
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSMutableArray<NSString *> * symbolNames = [NSMutableArray array];
    while (true) {
        //offsetof 就是针对某个结构体找到某个属性相对这个结构体的偏移量
        SymbolNode * node = OSAtomicDequeue(&symboList, offsetof(SymbolNode, next));
        if (node == NULL) break;
        Dl_info info;
        dladdr(node->pc, &info); //这个函数能通过函数内部地址找到函数符号
         
        NSString * name = @(info.dli_sname); // 符号名称
         
        // 添加 _
        BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
        // block 调用前面还需要加_下划线
        NSString * symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
         
        //去重
        if (![symbolNames containsObject:symbolName]) {
            [symbolNames addObject:symbolName];
        }
    }
 
    //取反
    NSArray * symbolAry = [[symbolNames reverseObjectEnumerator] allObjects];
    NSLog(@"%@",symbolAry);
    /**
     (
         "+[ViewController load]",
         "_main",
         "-[AppDelegate application:didFinishLaunchingWithOptions:]",
         "-[AppDelegate application:configurationForConnectingSceneSession:options:]",
         "-[SceneDelegate setWindow:]",
         "-[SceneDelegate scene:willConnectToSession:options:]",
         "-[SceneDelegate window]",
         "-[ViewController viewDidLoad]",
         "_testCFunc",
         "_LBBlock_block_invoke",
         "-[ViewController testOCFunc]",
         "-[SceneDelegate sceneWillEnterForeground:]",
         "-[SceneDelegate sceneDidBecomeActive:]",
         "-[ViewController touchesBegan:withEvent:]"
     )
     */
    //将结果写入到文件
    NSString * funcString = [symbolAry componentsJoinedByString:@"\n"];
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"lb.order"];
    NSData * fileContents = [funcString dataUsingEncoding:NSUTF8StringEncoding];
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
    if (result) {
        NSLog(@"%@",filePath);
        // /Users/sunhui/Library/Developer/CoreSimulator/Devices/70CDD9F6-B254-4E29-9DAA-07DB4D9B86F8/data/Containers/Data/Application/FA706818-43A5-4D64-AEAC-97B4235013B1/tmp/lb.order
    }else{
        NSLog(@"文件写入出错");
    }
     
}
//原子队列
static OSQueueHead symboList = OS_ATOMIC_QUEUE_INIT;
//定义符号结构体
typedef struct{
    void * pc;
    void * next;
}SymbolNode;
 
/**
在 __sanitizer_cov_trace_pc_guard 这个函数中 ,通过 __builtin_return_address 函数
拿到原函数调用 __sanitizer_cov_trace_pc_guard 这句汇编代码的下一条指令的地址
*/
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    //if (!*guard) return;  // 注释掉的目的是，为了得到load方法
     
    void *PC = __builtin_return_address(0); // 作用：读取 x30 中所存储的要返回时下一条指令的地址
     
    SymbolNode * node = malloc(sizeof(SymbolNode));
    *node = (SymbolNode){PC,NULL};
     
    //入队
    // offsetof 用在这里是为了入队添加下一个节点找到 前一个节点next指针的位置
    OSAtomicEnqueue(&symboList, node, offsetof(SymbolNode, next));
}

```


搞定 , 小伙伴们就可以立马去优化自己的工程了 .


### cocoapod 工程问题
对于 cocoapod 工程引入的库 , 由于针对不同的 target . 那么我们在主程序中的 target 添加的编译设置 
`Write Link Map File , -fsanitize-coverage=func,trace-pc-guard` 以及 `order file` 等设置肯定是不会生效的 . 
解决方法就是针对需要的 target 去做对应的设置即可  .

对于直接手动导入到工程里的 sdk , 不管是 静态库 .a 还是 动态库 , 默认主工程的设置就可以了 , 是可以拿到符号的 .

最后提示一下 , 手动导入的三方库如果没有导入并且使用的话 , 是不会加载的 . 添加了 load 方法也是如此 .
