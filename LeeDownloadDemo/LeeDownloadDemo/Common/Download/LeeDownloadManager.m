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

#pragma mark -Instance Methods
+ (instancetype)shareManager {
    static LeeDownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LeeDownloadManager alloc] init];
    });
    return instance;
}

#pragma mark -Public Methods
- (void)downloadWithURL:(NSURL *)url type:(LeeDownloadTypeBlock)typeBlock progress:(LeeDownloadProgressBlock)progressBlock complete:(LeeDownloadCompleteBlock)completeBlock{
    if (![url isKindOfClass:NSURL.class]) {
           if ([url isKindOfClass:NSString.class]) {
               url = [NSURL URLWithString:(NSString *)url];
           }else {
               if(completeBlock){
                   completeBlock(nil,[NSError errorWithDomain:@"构建下载任务失败" code:-1 userInfo:nil]);
               }
               return ;
           }
       }
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           NSDictionary *fileInfo = [[LeeCacheManager shareCacheManger] queryFileInfoWithUrl:url.absoluteString];
           if ([fileInfo[LeeFinishKey] integerValue]) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   if(completeBlock){
                       completeBlock(fileInfo,nil);
                   }
               });
               return;
           }
           [self.downloadSession downloadWithURL:url type:typeBlock progress:progressBlock complete:completeBlock];
       });
}

- (void)startDownLoadWithUrl:(NSString *)url {
    NSDictionary *fileInfo = [[LeeCacheManager shareCacheManger] queryFileInfoWithUrl:url];
    if (fileInfo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LeeDownloadErrorNotification object:self userInfo:@{LeeErrorKey:@"该文件已下载"}];
        return;
    }
    [self.downloadSession startDownLoadWithUrl:url];
}

- (void)supendDownloadWithUrl:(NSString *)url {
    [_downloadSession supendDownloadWithUrl:url];
}

- (void)cancelDownloadWithUrl:(NSString *)url {
    [_downloadSession cancelDownloadWithUrl:url];
}

- (void)suspendAllDownloadTask {
    [_downloadSession suspendAllDownloads];
}

- (void)startAllDownloadTask {
    [_downloadSession startAllDownloads];
}

- (void)stopAllDownloads {
    [_downloadSession cancelAllDownloads];
    _downloadSession = nil;
}

#pragma mark -Setter && Getter Methods
- (LeeDownloadSesstion *)downloadSession {
    if (!_downloadSession) {
        _downloadSession = [[LeeDownloadSesstion alloc] init];
    }
    return _downloadSession;
}

@end
