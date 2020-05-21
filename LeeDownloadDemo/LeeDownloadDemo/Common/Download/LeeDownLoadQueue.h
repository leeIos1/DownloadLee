//
//  LeeDownLoadQueue.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/** 下载处理 */
typedef  enum : NSUInteger {
    LeeDownloadHandleTypeStart,    // 开始下载
    LeeDownloadHandleTypeSuspend,  // 暂停下载
    LeeDownloadHandleTypeCancel,   // 取消下载
} LeeDownloadHandleType;


@interface LeeDownLoadQueue : NSObject

// 添加下载任务
- (void)addDownloadWithSession:(NSURLSession *)session
                        URL:(NSURL *)url
                      begin:(void(^)(NSString * filePath))begin
                   progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress
                   complete:(void(^)(NSDictionary *respose,NSError *error))complet;

// 对当前任务进行操作
- (void)operateDownloadWithUrl:(NSString *)url handle:(LeeDownloadHandleType)handle;

// 取消所有任务
- (void)cancelAllTasks;
- (void)suspendAllTasks;
- (void)startAllTasks;

// 供downloader 处理下载调用
- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response;

- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;

- (void)task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
