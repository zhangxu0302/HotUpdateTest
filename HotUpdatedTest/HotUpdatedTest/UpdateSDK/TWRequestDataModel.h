//
//  TWRequestDataModel.h
//  MD5-Zhang
//
//  Created by 张旭 on 16/11/10.
//  Copyright © 2016年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWRequestDataModel : NSObject

/**
 * 请求操作
 * 1 更新新版本
 * 0 不更新
 */
@property (nonatomic, assign) NSInteger updateResult;



/**
 * 请求文件的md5码
 */
@property (nonatomic, strong) NSString *Md5Code;



/**
 * js版本号
 */
@property (nonatomic, assign) NSInteger versionCode;



/**
 * 解压完后js文件数量
 */
@property (nonatomic, assign) NSInteger fileCount;



/**
 * 补丁Url地址
 */
@property (nonatomic, strong) NSString *patchUrl;



/**
 * 更新策略
 * 0 重启更新
 * 1 立即更新
 */
@property (nonatomic, assign) NSInteger updateStrategy;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
