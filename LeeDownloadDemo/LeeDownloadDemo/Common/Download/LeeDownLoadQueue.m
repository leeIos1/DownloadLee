//
//  LeeDownLoadQueue.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import "LeeDownLoadQueue.h"
#import "LeeDownloadOperation.h"
#import "LeeCacheManager.h"
#import "LeeHeader.h"

@interface LeeDownLoadQueue()

// 列队管理集合
@property (nonatomic,strong) NSMutableSet <LeeDownloadOperation *> *operations;

@end

@implementation LeeDownLoadQueue

- (instancetype)init {

    if (self = [super init]) {
        // 监听完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResiveDownloadFileCompete:) name:LeeDownloadCompletedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didResiveDownloadFileCompete:(NSNotification *)noti{
    LeeDownloadOperation *operation = noti.object;
    if (operation) {
        [self.operations removeObject:operation];
    }
}

#pragma mark - handle Out operations
- (void)addDownloadWithSession:(NSURLSession *)session URL:(NSURL *)url begin:(void(^)(NSString *))begin progress:(void(^)(NSInteger,NSInteger))progress complete:(void(^)(NSDictionary *,NSError *))complet {
    // 获取operation对象
    LeeDownloadOperation *operation = [self operationWithUrl:url.absoluteString];
    if (operation == nil) {
        operation = [[LeeDownloadOperation alloc] initWith:url.absoluteString session:session];
        if (operation == nil) {
            // 没有下载任务代表已下载完成
            NSDictionary *fileInfo = [[LeeCacheManager shareCacheManger] queryFileInfoWithUrl:url.absoluteString];
            if (fileInfo && complet) {
                complet(fileInfo,nil);
            }else {
                complet(nil,[NSError errorWithDomain:@"构建下载任务失败" code:-1 userInfo:nil]);
            }
            return;
        }
        
        [self.operations addObject:operation];
    }
    if(self.operations.count<=LeeMaxDownloadCount){
        // 回调赋值operation
        [operation configCallBacksWithDidReceiveResponse:begin didReceivData:progress didComplete:complet];
        [operation.dataTask resume];
    }
}

- (void)operateDownloadWithUrl:(NSString *)url handle:(LeeDownloadHandleType)handle{
    
    LeeDownloadOperation *operation = [self operationWithUrl:url];
    if (!operation) {
        return;
    } else if (!operation.dataTask) {
//        if (!operation.didComplete || !(handle == DownloadHandleTypeStart)) {
//            [self.operations removeObject:operation];
//            return;
//        }
//
//        NSDictionary *fileInfo = [SGCacheManager queryFileInfoWithUrl:url];
//
//        if (fileInfo) {
//            operation.didComplete(fileInfo,nil);
//        }
        [self.operations removeObject:operation];
        return;
    }
    
    
    switch (handle) {
        case LeeDownloadHandleTypeStart:
            [operation.dataTask resume]; // 开始
            break;
        case LeeDownloadHandleTypeSuspend:
            [operation.dataTask suspend]; // 暂停
            break;
        case LeeDownloadHandleTypeCancel:
            [operation.dataTask cancel];  // 取消
            [self.operations removeObject:operation]; // 删除任务
            break;
    }
}

- (void)cancelAllTasks {
    // 取消所有的任务
    [_operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.dataTask cancel];
    }];
    // 清理内存
    _operations = nil;
}
- (void)suspendAllTasks {
    // 取消所有的任务
    [_operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.dataTask suspend];
    }];
}
- (void)startAllTasks {
    // 恢复
    [_operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.dataTask resume];
    }];
}


#pragma mark - handle download
- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response {
    
    [[self oprationWithDataTask:dataTask] operateWithResponse:response];
}

- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self oprationWithDataTask:dataTask] operateWithReceivingData:data];
}


- (void)task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [[self oprationWithDataTask:task] operateWithComplete:error];
}


#pragma mark - query operation
- (LeeDownloadOperation *)operationWithUrl:(NSString *)url{
    __block LeeDownloadOperation *operation = nil;
    
    [self.operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.url isEqualToString:url]) {
            operation = obj;
            *stop = YES;
        }
    }];
    
    return operation;
}

// 寻找operation
- (LeeDownloadOperation *)oprationWithDataTask:(NSURLSessionTask *)dataTask {
    
    __block LeeDownloadOperation *operation = nil;
    
    [self.operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.dataTask == dataTask) {
            operation = obj;
            *stop = YES;
        }
    }];
    
    return operation;
}
#pragma mark - lazy load
- (NSMutableSet<LeeDownloadOperation *> *)operations {
    
    if (!_operations) {
        _operations = [NSMutableSet set];
    }
    return _operations;
}

@end
