//
//  PayManager.m
//  PayManagerDemo
//
//  Created by TCM on 2018/3/14.
//  Copyright © 2018年 TCM. All rights reserved.
//

#import "PayManager.h"

@interface PayManager()<WXApiDelegate>

@property (nonatomic, copy) PayCompletaCallBack callBack;

@property (nonatomic, strong) NSMutableDictionary *appSchemeDict;

@end


@implementation PayManager

static PayManager *shareManager = nil;

//初始化单例
+ (instancetype)shareManager{
  
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[PayManager alloc] init];
    });
    
    return shareManager;
}

- (void)WX_registerApp{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *urlTypes = dict[@"CFBundleURLTypes"];
    for (NSDictionary *urlTypeDict in urlTypes) {
        
        NSString *urlName = urlTypeDict[@"CFBundleURLName"];
        NSArray *urlSchemes = urlTypeDict[@"CFBundleURLSchemes"];
        
        //一般对应只有一个
        NSString *urlScheme = urlSchemes.lastObject;
        
        if ([urlName isEqualToString:WECHATPAYURLNAME]) {
            [self.appSchemeDict setValue:urlName forKey:WECHATPAYURLNAME];
            [WXApi registerApp:urlScheme];
        }
        else if([urlName isEqualToString:ALIPAYURLNAME]){
            //保存支付宝scheme，以便发起支付使用
            [self.appSchemeDict setValue:urlScheme forKey:ALIPAYURLNAME];
        }
        else{
            
        }
    }
}

- (BOOL)manager_handlerUrl:(NSURL *)handleUrl{

    if ([handleUrl.host isEqualToString:@"pay"]) {
        return [WXApi handleOpenURL:handleUrl delegate:self];
    }
    else if([handleUrl.host isEqualToString:@"safepay"]){
        // 支付跳转支付宝钱包进行支付，处理支付结果(在app被杀模式下，通过这个方法获取支付结果）
        [[AlipaySDK defaultService] processOrderWithPaymentResult:handleUrl standbyCallback:^(NSDictionary *resultDic) {
            
            NSString *resultStatus = resultDic[@"resultStatus"];
            NSString *errStr = resultDic[@"memo"];
            
            PayStateCode errorCode = StateCodeSuccess;
            
            switch (resultStatus.integerValue) {
                case 9000://成功
                    errorCode = StateCodeSuccess;
                    break;
                case 6001://取消
                    errorCode = StateCodeCancel;
                    break;
                default:    //错误
                    errorCode = StateCodeError;
                    break;
            }
            if ([PayManager shareManager].callBack) {
                [PayManager shareManager].callBack(errorCode, errStr);
            }
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:handleUrl standbyCallback:^(NSDictionary *resultDic) {
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        return YES;
    }
    else{
        return NO;
    }
}

- (void)manager_payOrderMessage:(id)orderMessage callBack:(PayCompletaCallBack)callBack{
    //缓存block
    self.callBack = callBack;
    //发起支付
    if ([orderMessage isKindOfClass:[PayReq class]]) {
        //微信
        [WXApi sendReq:(PayReq *)orderMessage];
    }
    else if([orderMessage isKindOfClass:[NSString class]]){
        //支付订单
        NSString *orderStr = [NSString stringWithFormat:@"%@",orderMessage];
        
        //支付宝
        [[AlipaySDK defaultService] payOrder:orderStr fromScheme:self.appSchemeDict[ALIPAYURLNAME] callback:^(NSDictionary *resultDic) {
            NSString *resultStatus = resultDic[@"resultStatus"];
            NSString *errStr = resultDic[@"memo"];
            PayStateCode errorCode = StateCodeSuccess;
            
            switch (resultStatus.integerValue) {
                case 9000:
                    errorCode = StateCodeSuccess;
                    break;
                case 6001:
                    errorCode = StateCodeCancel;
                    break;
                default:
                    errorCode = StateCodeError;
                    break;
            }
            
            if ([PayManager shareManager].callBack) {
                [PayManager shareManager].callBack(errorCode, errStr);
            }
        }];
    }
}

#pragma mark -懒加载，初始化字典
- (NSMutableDictionary *)appSchemeDict{
    if (!_appSchemeDict) {
        _appSchemeDict = [NSMutableDictionary dictionary];
    }
    return _appSchemeDict;
}

@end
