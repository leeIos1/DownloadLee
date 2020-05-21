//
//  LeeDownloadManager.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import "LeeDownloadManager.h"
#import "LeeDownloadSesstion.h"

#import "LeeCacheManager.h"

@interface LeeDownloadManager()

@property(nonatomic,strong) LeeDownloadSesstion *downloadSession;

@end

@implementation LeeDownloadManager

+ (instancetype)shareManager {
    static LeeDownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LeeDownloadManager alloc] init];
    });
    return instance;
}


#pragma mark - 外界交互
- (void)downloadWithURL:(NSURL *)url complete:(void(^)(NSDictionary *,NSError *))complete{
    [self downloadWithURL:url begin:nil progress:nil complete:complete];
}

- (void)downloadWithURL:(NSURL *)url progress:(void(^)(NSInteger,NSInteger ))progress complete:(void(^)(NSDictionary *,NSError *))complete {
    [self downloadWithURL:url begin:nil progress:progress complete:complete];
}

- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString *))begin progress:(void(^)(NSInteger,NSInteger))progress complete:(void(^)(NSDictionary *,NSError *))complete {
    
    if (![url isKindOfClass:NSURL.class]) {
        if ([url isKindOfClass:NSString.class]) {
            url = [NSURL URLWithString:(NSString *)url];
        }else {
            // 失败回调
            
            return;
        }
    }
    // 开启异步 操作
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 本地查找
        NSDictionary *fileInfo = [[LeeCacheManager shareCacheManger] queryFileInfoWithUrl:url.absoluteString];
        // 本地存在直接返回
        if ([fileInfo[LeeFinishKey] integerValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !complete ? : complete(fileInfo,nil);
            });
            return;
        }
        
        // 交给downloader下载
        [self.downloadSession downloadWithURL:url begin:begin progress:progress complete:complete];
    });
    
}

#pragma mark -
- (void)startDownLoadWithUrl:(NSString *)url {
    // 本地查找
    NSDictionary *fileInfo = [[LeeCacheManager shareCacheManger] queryFileInfoWithUrl:url];
    
    if (fileInfo) {
        return;
    }
    //
    [self.downloadSession startDownLoadWithUrl:url];
}

- (void)supendDownloadWithUrl:(NSString *)url {
    // 暂停下载
    [_downloadSession supendDownloadWithUrl:url];
}

- (void)cancelDownloadWithUrl:(NSString *)url {
    // 取消下载
    [_downloadSession cancelDownloadWithUrl:url];
}


/** 暂停当前所有的下载任务 下载任务不会从列队中删除 */
- (void)suspendAllDownloadTask {
    [_downloadSession suspendAllDownloads];
}

/** 开启当前列队中所有被暂停的下载任务 */
- (void)startAllDownloadTask {
    [_downloadSession startAllDownloads];
}

/** 停止当前所有的下载任务 调用此方法会清空所有列队下载任务 */
- (void)stopAllDownloads {
    [_downloadSession cancelAllDownloads];
    _downloadSession = nil;
}

#pragma mark - lazy load
- (LeeDownloadSesstion *)downloadSession {
    if (!_downloadSession) {
        _downloadSession = [[LeeDownloadSesstion alloc] init];
    }
    return _downloadSession;
}

@end
