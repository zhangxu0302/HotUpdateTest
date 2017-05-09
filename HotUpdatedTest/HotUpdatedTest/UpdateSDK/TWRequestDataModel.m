//
//  TWRequestDataModel.m
//  MD5-Zhang
//
//  Created by 张旭 on 16/11/10.
//  Copyright © 2016年 ZX. All rights reserved.
//

#import "TWRequestDataModel.h"

@implementation TWRequestDataModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}


@end
