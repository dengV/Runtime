//
//  SHViewController.m
//  SHMsgSend
//
//  Created by yaoqi on 04/14/2016.
//  Copyright (c) 2016 yaoqi. All rights reserved.
//

#import "SHMsgSend.h"
#import "SHViewController.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface SHViewController ()

@end

@implementation SHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self useObjc_msgSend];
}

//***************************************************************************************************//
// objc_msgSend的使用
- (void)useObjc_msgSend {
    // 1.创建对象
    SHMsgSend *msg = ((SHMsgSend * (*) (id, SEL, SEL)) objc_msgSend)((id)[SHMsgSend class], @selector(alloc), @selector(init));

    // 2.初始化对象
//    msg = ((SHMsgSend * (*) (id, SEL)) objc_msgSend)((id) msg, @selector(init));

    // 2.调用无参数无返回值方法
    ((void (*)(id, SEL)) objc_msgSend)((id) msg, @selector(noArgumentsAndNoReturnValue));

    // 3.调用带一个参数但无返回值的方法
    ((void (*)(id, SEL, NSString *)) objc_msgSend)((id) msg, @selector(hasArguments:), @"调用带一个参数但无返回值的方法");

    // 4.调用带返回值，但是不带参数
    NSString *retValue = ((NSString * (*) (id, SEL)) objc_msgSend)((id) msg, @selector(noArgumentsButReturnValue));
    NSLog(@"4. 返回值为：%@", retValue);

    // 5.带参数带返回值的消息
    int returnValue = ((int (*)(id, SEL, NSString *, int)) objc_msgSend)((id) msg, @selector(hasArguments:andReturnValue:), @"参数1", 2016);
    NSLog(@"5. return value is %d", returnValue);

    // 6.动态添加方法再调用
    class_addMethod(msg.class, NSSelectorFromString(@"cStyleFunc"), (IMP) cStyleFunc, "i@:r^vr^v");
    returnValue = ((int (*)(id, SEL, const void *, const void *)) objc_msgSend)((id) msg, NSSelectorFromString(@"cStyleFunc"), "参数1", "参数2");

    // 7.带浮点返回值的消息
    float retFloatValue = ((float (*)(id, SEL)) objc_msgSend_fpret)((id) msg, @selector(returnFloatType));
    NSLog(@"%f", retFloatValue);

    retFloatValue = ((float (*)(id, SEL)) objc_msgSend)((id) msg, @selector(returnFloatType));
    NSLog(@"%f", retFloatValue);

    // 8.带结构体返回值的消息
    CGRect frame = ((CGRect (*)(id, SEL)) objc_msgSend_stret)((id) msg, @selector(returnTypeIsStruct));
    NSLog(@"8. return value is %@", NSStringFromCGRect(frame));
}

// C函数
int cStyleFunc(id receiver, SEL sel, const void *arg1, const void *arg2) {
    NSLog(@"%s was called, arg1 is %@, and arg2 is %@", __FUNCTION__,
          [NSString stringWithUTF8String:arg1],
          [NSString stringWithUTF8String:arg1]);
    return 1;
}
//***************************************************************************************************//

@end
