//
//  LeeFileModel.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/19.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef  enum : NSUInteger {
    LeeWaitDownloadType = 0,         // 等待下载
    LeeDownloadingType,              // 下载中
    LeeDownloadSupendType,           // 等待下载
    LeeDownloadCompletedType,        // 下载完成
} LeeDownloadType;

@interface LeeFileModel : NSObject

@property (nonatomic ,strong)NSString *fileId;
@property (nonatomic ,strong)NSString *fileName;
@property (nonatomic ,strong)NSString *fileUrl;
@property (nonatomic ,strong)NSError *error;
@property (nonatomic ,assign)LeeDownloadType downloadType;
@property (nonatomic ,assign)float progress;

-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)allocModelWithDic:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
