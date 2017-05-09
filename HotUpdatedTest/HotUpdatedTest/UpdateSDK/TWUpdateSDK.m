//
//  TWUpdateSDK.m
//  MD5-Zhang
//
//  Created by 张旭 on 16/11/10.
//  Copyright © 2016年 ZX. All rights reserved.
//

#import "TWUpdateSDK.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>
#import "TWRequestDataModel.h"
#import "SSZipArchive.h"


static NSString *kVersonUserDefaultsKey = @"kVersonUserDefaultsKey";
static NSString *kSaveDateDefaultsKey = @"kSaveDateDefaultsKey";


@implementation TWUpdateSDK {
    TWRequestDataModel *requestModel;
    NSString *localAddress;
    NSString *currentVersonStr;
    NSInteger timeValue;
    NSString *requestUrl;
}

+ (instancetype)instance {
    static dispatch_once_t onceTocken;
    static TWUpdateSDK *manager = nil;
    dispatch_once(&onceTocken, ^{
        manager = [[TWUpdateSDK alloc] init];
    });
    return manager;
}

- (void)initializeWithConfig:(TWHotUpdateConfig *)config {
    localAddress = config.jsVersonPath;
    timeValue = config.updateInterval;
    requestUrl = config.updateInfoUrl;
    
    NSInteger localVerson = [[[NSUserDefaults standardUserDefaults] objectForKey:kVersonUserDefaultsKey] integerValue];
    if (localVerson == 0) {
        currentVersonStr = [self getVersonString];
    } else {
        currentVersonStr = [NSString stringWithFormat:@"%zd", localVerson];
    }
    
    [self createFolder];   // 创建文件夹
    
    [self requestData:config.updateInfoUrl];
}

- (NSString *)getAppMainVerson {
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)getVersonString {
    NSArray *numberArray = [[self getAppMainVerson] componentsSeparatedByString:@"."];
    NSString *numberStr = @"";
    for (int i = 0; i < numberArray.count; i++) {
        NSString *tempStr = [NSString stringWithFormat:@"%03zd", [numberArray[i] integerValue]];
        numberStr = [numberStr stringByAppendingString:tempStr];
    }
    return [NSString stringWithFormat:@"%zd",numberStr.integerValue];
}

/* 沙盒中创建存放数据的文件夹 */
- (void)createFolder {
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@", pathDocuments, localAddress];
    if (![[NSFileManager defaultManager]fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"有这个文件了");
    }
}

- (NSString *)getLocalPath {
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", localAddress]];
}

/* 请求后台数据 */
- (void)requestData:(NSString *)url {
    if (url) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        // 设置非校验证书模式
        manager.requestSerializer.timeoutInterval = 20;
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        manager.securityPolicy.allowInvalidCertificates = YES;
        [manager.securityPolicy setValidatesDomainName:NO];
        
        __weak typeof(self) weakSelf =  self;
        [manager POST:url parameters:@{@"nativeVersionCode":[self getVersonString] ?: @"", @"jsVersionCode":currentVersonStr ?: @"", @"platForm":@(1)}
              success:^(NSURLSessionTask *operation, id responseObject) {
                  __strong __typeof(weakSelf)strongSelf = weakSelf;
                  if (responseObject != nil) {
                      long long now_timestamp = [[NSDate date] timeIntervalSince1970];
                      [[NSUserDefaults standardUserDefaults] setObject:@(now_timestamp) forKey:kSaveDateDefaultsKey];  // 记录本次请求时间戳
                      NSDictionary *respObj = responseObject;
                      NSDictionary *result = [respObj objectForKey:@"data"];
                      strongSelf->requestModel = [[TWRequestDataModel alloc] initWithDictionary:result];
                      [weakSelf downloadData];
                  }
              } failure:^(NSURLSessionTask *operation, NSError *error) {
                  NSLog(@"err:%@", error);
              }];
    }
}

/* 下载js文件 */
- (void)downloadData {
    if (requestModel && requestModel.patchUrl && requestModel.updateResult == 1 && requestModel.versionCode != currentVersonStr.integerValue) {
        [self clearDraftBox];
        NSURL *url = [NSURL URLWithString:requestModel.patchUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        __weak typeof(self) weakSelf =  self;
        NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            // 返回下载到哪里(返回值是一个路径)
            NSURL *storeURL = [NSURL fileURLWithPath:[self filepath]];
            return storeURL;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            // 下载完成回调
            if (!error) {
                // 获取下载文件的 md5 值
                
                NSLog(@"=======:%@", filePath);
                
                NSString *md5Str = [self getMD5String:[self filepath]];
                if ([md5Str isEqualToString:requestModel.Md5Code]) {
                    [weakSelf unzipFile];
                }
            }
        }];
        // 开始请求
        [task resume];
    } else {
        [self removeAllData];       // 如果不请求则清理沙盒中无用数据
    }
}

/* 获取文件的md5值 */
- (NSString *)getMD5String:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) {
        return nil;
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData *fileData = [handle readDataOfLength: 256];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    
    return s;
}

/* 解压文件 */
- (void)unzipFile {
    NSString *path = [[self getLocalPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%zd", requestModel.versionCode]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        // 如果已经有改文件夹先删除
        [self removeDataWithPath:path];
    }
    
    if ([SSZipArchive unzipFileAtPath:[self filepath] toDestination:[self getLocalPath]]) {
        // 解压成功
        NSInteger count = [self getFilesCountWithPath:path];
        if (count == requestModel.fileCount) {  // 判断解压文件数量和后台返回count一致则保存
            [[NSUserDefaults standardUserDefaults] setObject:@(requestModel.versionCode) forKey:kVersonUserDefaultsKey];
        }
    }
}

/* 获取解压后文件的根目录 */
- (NSString *)getJSRootDirectory {
    [self checkUpdate];
    
    // 如果第一次加载返回 nil
    NSInteger localVerson = [[[NSUserDefaults standardUserDefaults] objectForKey:kVersonUserDefaultsKey] integerValue];
    if (localVerson == 0) {
        return nil;
    } else {
        NSString *path = [[self getLocalPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", currentVersonStr]];
        return path;
    }
}

- (void)checkUpdate {
    long long now_timestamp = [[NSDate date] timeIntervalSince1970];
    long long currentTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kSaveDateDefaultsKey] longLongValue];
    if (currentTime - now_timestamp > timeValue) {  // 上次请求超过间隔时间 触发请求
        [self requestData:requestUrl];
    }
}

/* 删除.zip文件 */
- (void)clearDraftBox {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self filepath] error:nil];
}

/* 返回归档文件的存储路径 */
- (NSString *)filepath {
    if (localAddress) {
        return [[self getLocalPath] stringByAppendingPathComponent:@"myData.zip"];
    }
    return @"";
}

/* 删除除需要用的文件以外的所有文件 */
- (void)removeAllData {
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[self getLocalPath]];
    for (NSString *fileName in enumerator) {
        if (![fileName hasPrefix:currentVersonStr]) {
            [[NSFileManager defaultManager] removeItemAtPath:[[self getLocalPath] stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

/* 删除指定文件夹 */
- (void)removeDataWithPath:(NSString *)path {
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for (NSString *fileName in enumerator) {
        [[NSFileManager defaultManager] removeItemAtPath:[[self getLocalPath] stringByAppendingPathComponent:fileName] error:nil];
    }
}

/* 获取指定文件夹中文件数量 */
- (NSInteger)getFilesCountWithPath:(NSString *)path {
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    return enumerator.allObjects.count + 1;
}

- (NSInteger)getCurrentVersonCode {
    
    return currentVersonStr.integerValue;
}

- (void)restore {
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kVersonUserDefaultsKey];
}

@end
