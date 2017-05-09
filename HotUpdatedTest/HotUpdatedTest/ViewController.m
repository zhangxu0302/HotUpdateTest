//
//  ViewController.m
//  HotUpdatedTest
//
//  Created by 张旭 on 17/5/9.
//  Copyright © 2017年 ZX. All rights reserved.
//

#import "ViewController.h"
#import "TWHotUpdateConfig.h"
#import "TWUpdateSDK.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求后台接口，是否有更新，并下载 js 包
    [self upDataWeexJS];
}

- (void)upDataWeexJS {
    TWHotUpdateConfig *config = [[TWHotUpdateConfig alloc] init];
    config.updateInterval = 30*60;
    config.updateInfoUrl = @"";  // 请求接口
    config.jsVersonPath = @"TEST";
    [[TWUpdateSDK instance] initializeWithConfig:config];
}




@end
