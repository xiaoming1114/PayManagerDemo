//
//  PayManager.h
//  PayManagerDemo
//
//  Created by TCM on 2018/3/14.
//  Copyright © 2018年 TCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>

#define WECHATPAYURLNAME @"wxPay"
#define ALIPAYURLNAME    @"aliPay"

typedef NS_ENUM(NSInteger ,PayStateCode) {
    
    StateCodeSuccess,       //成功
    StateCodeError,         //失败
    StateCodeCancel
    
};

typedef void(^PayCompletaCallBack)(PayStateCode code,NSString *stateMsg);

@interface PayManager : NSObject

//创建一个单例
+ (instancetype)shareManager;

//注册App，需要在
- (void)WX_registerApp;

//处理跳转url，回调应用，需要在delegate里面实现
- (BOOL)manager_handlerUrl:(NSURL *)handleUrl;

/**
 回调处理

 @param orderMessage  传入订单信息,如果是字符串，则对应是跳转支付宝支付；如果传入PayReq 对象，这跳转微信支付,注意，不能传入空字符串或者nil
 @param callBack 回调，有返回状态信息
 */
- (void)manager_payOrderMessage:(id)orderMessage callBack:(PayCompletaCallBack)callBack;


@end
