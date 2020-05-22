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

#pragma mark -Life Cycle Methods
- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResiveDownloadFileCompete:) name:LeeDownloadCompletedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark -Private Methods
- (void)didResiveDownloadFileCompete:(NSNotification *)noti{
    LeeDownloadOperation *operation = noti.object;
    if (operation) {
        [self.operations removeObject:operation];
    }
}

-(BOOL)judgeResumeOperation{
    __block NSInteger count = 0;
    [self.operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        if(obj.dataTask.state == NSURLSessionTaskStateRunning){
            count++;
        }
    }];
    NSLog(@"当前下载数量%ld",count);
    return count<LeeMaxDownloadCount;
}

#pragma mark -Public Methods
- (void)addDownloadWithSession:(NSURLSession *)session URL:(NSURL *)url type:(LeeDownloadTypeBlock)typeBlock progress:(LeeDownloadProgressBlock)progressBlock complete:(LeeDownloadCompleteBlock)completeBlock{
    LeeDownloadOperation *operation = [self operationWithUrl:url.absoluteString];
    if (operation == nil) {
        operation = [[LeeDownloadOperation alloc] initWith:url.absoluteString session:session];
        if (operation == nil) {
            // 没有下载任务代表已下载完成
            NSDictionary *fileInfo = [[LeeCacheManager shareCacheManger] queryFileInfoWithUrl:url.absoluteString];
            if (fileInfo && completeBlock) {
                completeBlock(fileInfo,nil);
            }else {
                completeBlock(nil,[NSError errorWithDomain:@"构建下载任务失败" code:-1 userInfo:nil]);
            }
            return;
        }
        [self.operations addObject:operation];
    }
    [operation configCallBacksWithDidReceiveResponseprogress:progressBlock complete:completeBlock];
    if([self judgeResumeOperation]){
        [operation.dataTask resume];
        typeBlock(1);
    }else{
        typeBlock(0);
    }
}

- (void)operateDownloadWithUrl:(NSString *)url handle:(LeeDownloadHandleType)handle{
    LeeDownloadOperation *operation = [self operationWithUrl:url];
    if (!operation) {
        return;
    } else if (!operation.dataTask) {
        if(operation.completeBlock){
            operation.completeBlock(nil,[NSError errorWithDomain:@"任务出错" code:-1 userInfo:nil]);
        }
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
    [self.operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.dataTask cancel];
    }];
    self.operations = nil;
}
- (void)suspendAllTasks {
    [self.operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.dataTask suspend];
    }];
}
- (void)startAllTasks {
    [self.operations enumerateObjectsUsingBlock:^(LeeDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.dataTask resume];
    }];
}

- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response {
    [[self oprationWithDataTask:dataTask] operateWithResponse:response];
}

- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self oprationWithDataTask:dataTask] operateWithReceivingData:data];
}

- (void)task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [[self oprationWithDataTask:task] operateWithComplete:error];
}

#pragma mark -Setter && Getter Methods
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

- (NSMutableSet<LeeDownloadOperation *> *)operations {
    if (!_operations) {
        _operations = [NSMutableSet set];
    }
    return _operations;
}

@end
