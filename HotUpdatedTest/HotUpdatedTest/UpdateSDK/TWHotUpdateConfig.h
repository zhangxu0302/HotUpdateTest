//
//  TWHotUpdateConfig.h
//  MD5-Zhang
//
//  Created by 张旭 on 16/11/14.
//  Copyright © 2016年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWHotUpdateConfig : NSObject

/**
 * 每隔多少时间请求最新版(单位/秒)
 */
@property (nonatomic, assign) NSInteger updateInterval;

/**
 * 请求版本信息url
 */
@property (nonatomic, strong) NSString *updateInfoUrl;

/**
 * 本地存储文件名
 */
@property (nonatomic, strong) NSString *jsVersonPath;

@end
