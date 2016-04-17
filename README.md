# SHMsgSend

[![CI Status](http://img.shields.io/travis/yaoqi/SHMsgSend.svg?style=flat)](https://travis-ci.org/yaoqi/SHMsgSend)
[![Version](https://img.shields.io/cocoapods/v/SHMsgSend.svg?style=flat)](http://cocoapods.org/pods/SHMsgSend)
[![License](https://img.shields.io/cocoapods/l/SHMsgSend.svg?style=flat)](http://cocoapods.org/pods/SHMsgSend)
[![Platform](https://img.shields.io/cocoapods/p/SHMsgSend.svg?style=flat)](http://cocoapods.org/pods/SHMsgSend)

======================

# runtime objc_msgSend使用

======================

##	前言

要使用runtime发送消息就必须要知道objc_msgSend，知道它具体是怎么发送消息的？如何使用？其实我们在OC里面调用方法最终都是转换成objc_msgSend发送消息。

我们可以创建一个工程，使用``clang -rewrite-objc /path/main.m``命令后会在根目录生成一个``main.cpp``的文件，查看文件

	int main(int argc, const char * argv[]) {
    	/* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

        NSLog((NSString *)&__NSConstantStringImpl__var_folders_q8_lrxmf0h50l7byh7j6tcq5w2m0000gn_T_main_08e561_mi_0);

        HKPerson *person = ((HKPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((HKPerson *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("HKPerson"), sel_registerName("alloc")), sel_registerName("init"));
    	}
    	return 0;
	}

 ``HKPerson *person = ((HKPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((HKPerson *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("HKPerson"), sel_registerName("alloc")), sel_registerName("init"));``这里其实是有oc代码``HKPerson *person = [[HKPerson alloc] init];``编译生成的底层代码。
 
##	objc_msgSend
我们先来看看官方函数objc_msgSend的声明：

	/* Basic Messaging Primitives
	*
	* On some architectures, use objc_msgSend_stret for some struct return types.
	* On some architectures, use objc_msgSend_fpret for some float return types.
	* On some architectures, use objc_msgSend_fp2ret for some float return types.
	*	
	* These functions must be cast to an appropriate function pointer type 
	* before being called. 
	*/
	
	#if !OBJC_OLD_DISPATCH_PROTOTYPES
	OBJC_EXPORT void objc_msgSend(void /* id self, SEL op, ... */ )

从这个函数的注释可以看出来了，这是个最基本的用于发送消息的函数。另外，这个函数并不能发送所有类型的消息，只能发送基本的消息。比如，在一些处理器上，我们必须使用objc_msgSend_stret来发送返回值类型为结构体的消息，使用objc_msgSend_fpret来发送返回值类型为浮点类型的消息，而又在一些处理器上，还得使用objc_msgSend_fp2ret来发送返回值类型为浮点类型的消息。

最关键的一点：无论何时，要调用objc_msgSend函数，必须要将函数强制转换成合适的函数指针类型才能调用。

从objc_msgSend函数的声明来看，它应该是不带返回值的，但是我们在使用中却可以强制转换类型，以便接收返回值。另外，它的参数列表是可以任意多个的，前提也是要强制函数指针类型。

##	学习使用

我们建立一个类，就专门学习如何运用objc_msgSend函数来发送消息。我们建立了一个SHMsgSend类来学习。

##	1、创建并初始化对象

我们在OC里面一般都是实用[[SHMsgSend alloc] init];这样去创建并初始化对象，其实经过编译，这一行会转成如下的代码：

	// 1.创建对象
    SHMsgSend *msg = ((SHMsgSend * (*) (id, SEL)) objc_msgSend)((id)[SHMsgSend class], @selector(alloc));

	// 2.初始化对象
	msg = ((SHMsgSend * (*) (id, SEL)) objc_msgSend)((id) msg, @selector(init));
	
``SHMsgSend *``代表返回类型

``(*)``代表函数指针，相当于block的(^)

``(id, SEL)``是参数列表，一般id是本身的类，SEL是需要调用的方法选择器，这里的参数列表可以传多个，上述的创建对象和初始化对象其实可以合成一句话`` SHMsgSend *msg = ((SHMsgSend * (*) (id, SEL, SEL)) objc_msgSend)((id)[SHMsgSend class], @selector(alloc), @selector(init));``

搞懂了这些是不是觉得有点明白了，下面我们来给对象放送消息并传参数

##	2、调用无参数无返回值方法

在SHMsgSend类中定义一个无参数无返回值方法：

	//无参数无返回值
	- (void)noArgumentsAndNoReturnValue {
		NSLog(@"%s was called, and it has no arguments and return value", __FUNCTION__);
	}

在SHViewController控制器中调用：

	// 2.调用无参数无返回值方法
	((void *(*)(id, SEL))msg_send)((id)msg, @selector(noArgumentsAndNoReturnValue));

运行出来了，说明已经调用到了``noArgumentsAndNoReturnValue``方法：

	2016-04-17 20:17:22.062 SHMsgSend_Example[2031:164877] -[SHMsgSend noArgumentsAndNoReturnValue] was called, and it has no arguments and return value
	
##	3、调用带一个参数但无返回值的方法

在SHMsgSend类中定义一个有参数无返回值的方法：

	//有参数无返回值
	- (void)hasArguments:(NSString *)arg {
    	NSLog(@"%s was called, and argument is %@", __FUNCTION__, arg);
	}
	
在SHViewController控制器中调用：	

	// 3.调用带一个参数但无返回值的方法
	((void (*)(id, SEL, NSString *)) objc_msgSend)((id) msg, @selector(hasArguments:), @"调用带一个参数但无返回值的方法");
	
其中的``NSString *``就是要传过去的参数。

运行出来了，说明已经调用到了``hasArguments:``方法：

	2016-04-17 20:17:22.062 SHMsgSend_Example[2031:164877] -[SHMsgSend hasArguments:] was called, and argument is 调用带一个参数但无返回值的方法

##	4、调用带返回值，但是不带参数

在SHMsgSend类中定义一个调用带返回值，但是不带参数的方法：

	//带返回值不带参数消息
	- (NSString *)noArgumentsButReturnValue {
		NSLog(@"%s was called, and return value is %@", __FUNCTION__, @"不带参数，但是带有返回值");
		return @"不带参数，但是带有返回值";
	}

在SHViewController控制器中调用：

	// 4.调用带返回值，但是不带参数
	NSString *retValue = ((NSString * (*) (id, SEL)) objc_msgSend)((id) msg,@selector(noArgumentsButReturnValue));
	NSLog(@"4. 返回值为：%@", retValue);

其中的``NSString *``就是要返回的返回值。

运行出来了，说明已经调用到了``noArgumentsButReturnValue``方法：

	2016-04-17 20:17:22.062 SHMsgSend_Example[2031:164877] -[SHMsgSend noArgumentsButReturnValue] was called, and return value is 不带参数，但是带有返回值
	2016-04-17 20:17:22.062 SHMsgSend_Example[2031:164877] 4. 返回值为：不带参数，但是带有返回值

##	5、带参数带返回值的消息

在SHMsgSend类中定义一个带参数带返回值的消息的方法：

	//带参数带返回值的消息
	- (int)hasArguments:(NSString *)arg andReturnValue:(int)arg1 {
    	NSLog(@"%s was called, and argument is %@, return value is %d", __FUNCTION__, arg, arg1);
    	return arg1;
	}

在SHViewController控制器中调用：

	// 5.带参数带返回值的消息
	int returnValue = ((int (*)(id, SEL, NSString *, int)) objc_msgSend)((id) msg, @selector(hasArguments:andReturnValue:), @"参数1", 2016);
    NSLog(@"5. return value is %d", returnValue);

第一个``int``就是要返回的返回值。

``NSString *``是第一个参数

最后一个 ``int``是第二个参数

运行出来了，说明已经调用到了``hasArguments:andReturnValue:``方法：

	2016-04-17 20:17:22.062 SHMsgSend_Example[2031:164877] -[SHMsgSend hasArguments:andReturnValue:] was called, and argument is 参数1, return value is 2016
	2016-04-17 20:17:22.063 SHMsgSend_Example[2031:164877] 5. return value is 2016
	
##	6、动态添加方法再调用

我们要添加SHMsgSend中没有的方法，现在我们写一个C函数方法，供我们添加

	// C函数
	int cStyleFunc(id receiver, SEL sel, const void *arg1, const void *arg2) {
		NSLog(@"%s was called, arg1 is %@, and arg2 is %@", __FUNCTION__,
          [NSString stringWithUTF8String:arg1],
          [NSString stringWithUTF8String:arg1]);
		return 1;
	}
	


在SHViewController控制器中调用：

	// 6.动态添加方法再调用
	class_addMethod(msg.class, NSSelectorFromString(@"cStyleFunc"), (IMP) cStyleFunc, "i@:r^vr^v");
    returnValue = ((int (*)(id, SEL, const void *, const void *)) objc_msgSend)((id) msg, NSSelectorFromString(@"cStyleFunc"), "参数1", "参数2");

提示：i@:r^vr^v，其中i代表返回类型int，@代表参数接收者，:代表SEL，rv是const void *

运行出来了，说明已经调用到了``int cStyleFunc(id receiver, SEL sel, const void *arg1, const void *arg2)``方法：

	2016-04-17 20:17:22.063 SHMsgSend_Example[2031:164877] cStyleFunc was called, arg1 is 参数1, and arg2 is 参数1

##	7、带浮点返回值的消息

在SHMsgSend类中定义一个带浮点返回值的消息的方法：

	//带浮点返回值的消息
	- (float)returnFloatType {
		NSLog(@"%s was called", __FUNCTION__);
		return 1.4;
	}

在SHViewController控制器中调用：

	// 7.带浮点返回值的消息
    float retFloatValue = ((float (*)(id, SEL)) objc_msgSend_fpret)((id) msg, @selector(returnFloatType));
    NSLog(@"%f", retFloatValue);

    retFloatValue = ((float (*)(id, SEL)) objc_msgSend)((id) msg, @selector(returnFloatType));
    NSLog(@"%f", retFloatValue);
   
注意：发送浮点型消息必须使用``objc_msgSend_fpret``函数。

运行出来了，说明已经调用到了``returnFloatType``方法：

	2016-04-17 20:17:22.063 SHMsgSend_Example[2031:164877] -[SHMsgSend returnFloatType] was called
	2016-04-17 20:17:22.063 SHMsgSend_Example[2031:164877] 1.400000
	2016-04-17 20:17:22.063 SHMsgSend_Example[2031:164877] -[SHMsgSend returnFloatType] was called
	2016-04-17 20:17:22.068 SHMsgSend_Example[2031:164877] 1.400000


##	8、带结构体返回值的消息

在SHMsgSend类中定义一个带结构体返回值的消息方法：

	//带结构体返回值的消息
	- (CGRect)returnTypeIsStruct {
    	NSLog(@"%s was called", __FUNCTION__);
    	return CGRectMake(1, 2, 3, 4);
	}
	
在SHViewController控制器中调用：

	// 8.带结构体返回值的消息
    CGRect frame = ((CGRect (*)(id, SEL)) objc_msgSend_stret)((id) msg, @selector(returnTypeIsStruct));
    NSLog(@"8. return value is %@", NSStringFromCGRect(frame));

运行出来了，说明已经调用到了``returnTypeIsStruct``方法：

	2016-04-17 20:17:22.068 SHMsgSend_Example[2031:164877] -[SHMsgSend returnTypeIsStruct] was called
	2016-04-17 20:17:22.068 SHMsgSend_Example[2031:164877] 8. return value is {{1, 2}, {3, 4}}

##	源代码

大家可以到Github下载源代码：https://github.com/yaoqi-github/Runtime

## Author

yaoqi, 1159991642@qq.com

## License

SHMsgSend is available under the MIT license. See the LICENSE file for more info.
