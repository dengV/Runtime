//
//  SHMsgSend.m
//  SHMsgSend
//
//  Created by yaoqi on 16/4/14.
//  Copyright © 2016年 yaoqi. All rights reserved.
//

#import "SHMsgSend.h"

@implementation SHMsgSend

- (void)noArgumentsAndNoReturnValue {
    NSLog(@"%s was called, and it has no arguments and return value", __FUNCTION__);
}

- (void)hasArguments:(NSString *)arg {
    NSLog(@"%s was called, and argument is %@", __FUNCTION__, arg);
}

- (NSString *)noArgumentsButReturnValue {
    NSLog(@"%s was called, and return value is %@", __FUNCTION__, @"不带参数，但是带有返回值");
    return @"不带参数，但是带有返回值";
}

- (int)hasArguments:(NSString *)arg andReturnValue:(int)arg1 {
    NSLog(@"%s was called, and argument is %@, return value is %d", __FUNCTION__, arg, arg1);
    return arg1;
}

- (float)returnFloatType {
    NSLog(@"%s was called", __FUNCTION__);
    return 1.4;
}

- (CGRect)returnTypeIsStruct {
    NSLog(@"%s was called", __FUNCTION__);
    return CGRectMake(1, 2, 3, 4);
}

@end
