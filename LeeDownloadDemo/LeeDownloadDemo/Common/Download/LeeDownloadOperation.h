//
//  LeeDownloadOperation.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeeHeader.h"
NS_ASSUME_NONNULL_BEGIN
 

typedef void(^LeeReceiveResponseOperation)(NSString *filePath);
typedef void(^LeeReceivDataOperation)(NSInteger completeSize,NSInteger expectSize);
typedef void(^LeeCompleteOperation)(NSDictionary *respose,NSError *error);

 
// 供queue管理方法
@protocol LeeDownloadOperationProtocol <NSObject>
// 处理响应值
- (void)operateWithResponse:(NSURLResponse *)response;
// 处理接收到的碎片
- (void)operateWithReceivingData:(NSData *)data;
// 处理完成回调
- (void)operateWithComplete:(NSError *)error;


/**
 设置block回调

 @param didReceiveResponse 开始下载的回调
 @param didReceivData 接收到下载的回调
 @param didComplete 下载完成的回调
 */
- (void)configCallBacksWithDidReceiveResponse:(LeeReceiveResponseOperation)didReceiveResponse
                                didReceivData:(LeeReceivDataOperation)didReceivData
                                  didComplete:(LeeCompleteOperation)didComplete;

@end

@interface LeeDownloadOperation : NSObject <LeeDownloadOperationProtocol>

// 创建下载操作任务
- (instancetype)initWith:(NSString *)url session:(NSURLSession *)session;
// 绑定的标示及task的创建
@property (readonly,nonatomic, copy)NSString *url;
// 下载任务
@property (readonly,nonatomic,strong)NSURLSessionDataTask *dataTask;

@end

NS_ASSUME_NONNULL_END
