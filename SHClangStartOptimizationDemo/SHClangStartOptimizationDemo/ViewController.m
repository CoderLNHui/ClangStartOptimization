//
//  ViewController.m
//  SHClangStartOptimizationDemo
//
//   
//

/**
 启动优化：
 思路：clang静态插桩达到二进制重排优化启动时间
 利用编译期`clang 静态插桩`的方式来 hook 获取启动时期需要加载的所有函数/方法 , `block` , `swift 方法`以及 `c++构造方法`的符号 .
 通过 `order file 机制`实现二进制重排 .
 二进制重排利用符号顺序 , 重新排列整个代码在文件的偏移地址 ,
   将启动需要加载的方法地址放到前面内存页中 , 以此达到减少 page fault 的次数从而实现时间上的优化。
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


@end

