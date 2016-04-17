//
//  SHMsgSend.h
//  SHMsgSend
//
//  Created by yaoqi on 16/4/14.
//  Copyright © 2016年 yaoqi. All rights reserved.
//

/**
 *  objc_msgSend的使用
 *
 *  @return <#return value description#>
 */

#import <Foundation/Foundation.h>

@interface SHMsgSend : NSObject

//无参数无返回值
- (void)noArgumentsAndNoReturnValue;

//有参数无返回值
- (void)hasArguments:(NSString *)arg;

//带返回值不带参数消息
- (NSString *)noArgumentsButReturnValue;

//带参数带返回值的消息
- (int)hasArguments:(NSString *)arg andReturnValue:(int)arg1;

//带浮点返回值的消息
- (float)returnFloatType;

//带结构体返回值的消息
- (CGRect)returnTypeIsStruct;

@end
