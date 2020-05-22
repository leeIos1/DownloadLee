//
//  LeeDownloadSesstion.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import "LeeDownloadSesstion.h"
#import "LeeDownLoadQueue.h"

@interface LeeDownloadSesstion()<NSURLSessionDataDelegate>


/** session 可以支持多个任务下载 */
@property (nonatomic,strong) NSURLSession *session;

/** 下载列队管理 专门负责接收到数据时分配给不同operation */
@property (nonatomic,strong) LeeDownLoadQueue *queue;

@end

@implementation LeeDownloadSesstion

#pragma mark -Public Methods
- (void)downloadWithURL:(NSURL *)url type:(LeeDownloadTypeBlock)typeBlock progress:(LeeDownloadProgressBlock)progressBlock complete:(LeeDownloadCompleteBlock)completeBlock{
    [self.queue addDownloadWithSession:self.session URL:url type:typeBlock progress:progressBlock complete:completeBlock];
}

- (void)startDownLoadWithUrl:(NSString *)url {
    [self.queue operateDownloadWithUrl:url handle:LeeDownloadHandleTypeStart];
}

- (void)supendDownloadWithUrl:(NSString *)url {
    [self.queue operateDownloadWithUrl:url handle:LeeDownloadHandleTypeSuspend];
}

- (void)cancelDownloadWithUrl:(NSString *)url {
    [self.queue operateDownloadWithUrl:url handle:LeeDownloadHandleTypeCancel];
}

- (void)cancelAllDownloads {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //调用 URLSession:task:didCompleteWithError: 方法抛出error取消
        [self.session invalidateAndCancel];
    });
}
- (void)startAllDownloads {
    [_queue startAllTasks];
}
- (void)suspendAllDownloads {
    [_queue suspendAllTasks];
}

#pragma mark -NSURLSessionDataDelegate Methods

// ssl 服务 证书信任
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge   completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if(![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        return;
    }
    // 信任该插件
    NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    // 第一个参数 告诉系统如何处置
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

//当请求协议是https的时候回调用该方法
//Challenge 挑战 质询(受保护空间)
//NSURLAuthenticationMethodServerTrust 服务器信任证书
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    if(![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        return;
    }
    // 信任该插件
    NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    // 第一个参数 告诉系统如何处置
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

// 接受到响应调用
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    // 将响应交给列队处理
    [self.queue dataTask:dataTask didReceiveResponse:response];
    // 允许下载
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.queue dataTask:dataTask didReceiveData:data];
}

// <NSURLSessionDataDelegate> 完成下载
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.queue task:task didCompleteWithError:error];
}

#pragma mark -Setter && Getter
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = -1;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    }
    return _session;
}

- (LeeDownLoadQueue *)queue {
    if (!_queue) {
        _queue = [[LeeDownLoadQueue alloc] init];
    }
    return _queue;
}

@end
