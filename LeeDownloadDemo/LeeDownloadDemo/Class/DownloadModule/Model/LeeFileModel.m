//
//  LeeFileModel.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/19.
//  Copyright © 2020 apple. All rights reserved.
//

#import "LeeFileModel.h"

@implementation LeeFileModel

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+(instancetype)allocModelWithDic:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{}



@end
