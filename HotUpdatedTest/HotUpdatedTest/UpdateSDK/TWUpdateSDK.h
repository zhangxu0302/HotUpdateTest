//
//  TWUpdateSDK.h
//  MD5-Zhang
//
//  Created by 张旭 on 16/11/10.
//  Copyright © 2016年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWHotUpdateConfig.h"

@interface TWUpdateSDK : NSObject

+ (instancetype)instance;

/**
 * 先初始化 TWHotUpdateConfig 模型进行信息配置
 * 调此方法初始化 SDK
 */
- (void)initializeWithConfig:(TWHotUpdateConfig *)config;


/**
 * 获取解压后文件的根目录
 */
- (NSString *)getJSRootDirectory;


/**
 * 获取当前JS文件版本号
 */
- (NSInteger)getCurrentVersonCode;


/**
 * 检查是否有更新
 */
- (void)checkUpdate;


/**
 * 还原初始版本
 */
- (void)restore;

@end
