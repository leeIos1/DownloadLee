//
//  LeeDownLoadQueue.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeeHeader.h"
NS_ASSUME_NONNULL_BEGIN

typedef  enum : NSUInteger {
    LeeDownloadHandleTypeStart,    // 开始下载
    LeeDownloadHandleTypeSuspend,  // 暂停下载
    LeeDownloadHandleTypeCancel,   // 取消下载
} LeeDownloadHandleType;


@interface LeeDownLoadQueue : NSObject

- (void)addDownloadWithSession:(NSURLSession *)session
                             URL:(NSURL *)url
                            type:(LeeDownloadTypeBlock)typeBlock
                        progress:(LeeDownloadProgressBlock)progressBlock
                        complete:(LeeDownloadCompleteBlock)completeBlock;

// 对当前任务进行操作
- (void)operateDownloadWithUrl:(NSString *)url handle:(LeeDownloadHandleType)handle;

- (void)cancelAllTasks;
- (void)suspendAllTasks;
- (void)startAllTasks;

- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response;
- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;
- (void)task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
