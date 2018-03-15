//
//  ViewController.m
//  PayManagerDemo
//
//  Created by TCM on 2018/3/14.
//  Copyright © 2018年 TCM. All rights reserved.
//

#import "ViewController.h"
#import "PayManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = self.view.frame.size.width;
    
    UIButton *weChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    weChatBtn.frame = CGRectMake((width - 100) / 2.f, 200, 100, 40);
    [weChatBtn setTitle:@"微信支付" forState:UIControlStateNormal];
    [weChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    weChatBtn.backgroundColor = [UIColor blackColor];
    weChatBtn.tag = WECHATBUTTONTAG;
    [weChatBtn addTarget:self action:@selector(payEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:weChatBtn];
    
    UIButton *aliBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aliBtn.frame = CGRectMake((width - 100)/2.f, 260, 100, 40);
    [aliBtn setTitle:@"支付宝支付" forState:UIControlStateNormal];
    [aliBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    aliBtn.backgroundColor = [UIColor blackColor];
    aliBtn.tag = ALIPAYBUTTONTAG;
    [aliBtn addTarget:self action:@selector(payEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aliBtn];
}

- (void)payEvent:(UIButton *)sender{
    
    switch (sender.tag) {
        case WECHATBUTTONTAG: //微信支付
            {
                PayReq* req = [[PayReq alloc] init];
                
                req.partnerId = @"10000100";
                req.prepayId= @"1101000000140415649af9fc314aa427";
                req.package = @"Sign=WXPay";
                req.nonceStr= @"a462b76e7436e98e0ed6e13c64b4fd1c";
                req.timeStamp= @"1397527777".intValue;
                req.sign= @"582282D72DD2B03AD892830965F428CB16E7A256";
                
                [[PayManager shareManager] manager_payOrderMessage:req callBack:^(PayStateCode code, NSString *stateMsg) {
                    
                    NSLog(@"stateCode = %zd,stateMsg = %@",code,stateMsg);
                }];
            }
            break;
        case ALIPAYBUTTONTAG:   //支付宝支付
            {
                //支付宝文档数据.
                NSString *orderMessage = @"app_id=2015052600090779&biz_content=%7B%22timeout_express%22%3A%2230m%22%2C%22seller_id%22%3A%22%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22total_amount%22%3A%220.02%22%2C%22subject%22%3A%221%22%2C%22body%22%3A%22%E6%88%91%E6%98%AF%E6%B5%8B%E8%AF%95%E6%95%B0%E6%8D%AE%22%2C%22out_trade_no%22%3A%22314VYGIAGG7ZOYY%22%7D&charset=utf-8&method=alipay.trade.app.pay&sign_type=RSA&timestamp=2016-08-15%2012%3A12%3A15&version=1.0&sign=MsbylYkCzlfYLy9PeRwUUIg9nZPeN9SfXPNavUCroGKR5Kqvx0nEnd3eRmKxJuthNUx4ERCXe552EV9PfwexqW%2B1wbKOdYtDIb4%2B7PL3Pc94RZL0zKaWcaY3tSL89%2FuAVUsQuFqEJdhIukuKygrXucvejOUgTCfoUdwTi7z%2BZzQ%3D";
                
                [[PayManager shareManager] manager_payOrderMessage:orderMessage callBack:^(PayStateCode code, NSString *stateMsg) {
                   
                    NSLog(@"stateCode = %zd,stateMsg = %@",code,stateMsg);
                }];
            }
            break;
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
