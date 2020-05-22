//
//  LeeDownloadOperation.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import "LeeDownloadOperation.h"
#import "LeeCacheManager.h"
#import "NSURLSession+LeeCategory.h"

 

@interface LeeDownloadOperation()

/** 文件句柄 可以记录文件的下载的位置 */
@property (nonatomic,strong) NSFileHandle *handle;
@property (nonatomic,assign) int64_t totalSize;
@property (nonatomic,assign) int64_t currentSize;
@property (nonatomic,copy) NSString *fileName;
/** 当前下载文件沙盒全路径 */
@property (nonatomic,copy) NSString *fullPath;

@end

@implementation LeeDownloadOperation

#pragma mark -Instance Methods
- (instancetype)initWith:(NSString *)url session:(NSURLSession *)session {
    if (self = [super init]) {
        _url = url;
        _currentSize = [self getFileSizeWithURL:url];
        _totalSize = [[LeeCacheManager shareCacheManger] totalSizeWith:url];
        if (self.currentSize == self.totalSize && self.totalSize != 0) {
            return nil;
        }
        _dataTask = [session lee_downloadDataTaskWithUrlString:url startSize:_currentSize];
    }
    return _dataTask ? self : nil;
}

#pragma mark -Private Methods
- (int64_t)getFileSizeWithURL:(NSString *)url {
    self.fileName = url;
    // 创建文件储存路径
    if (![[NSFileManager defaultManager] fileExistsAtPath:LeeFileDirector]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:LeeFileDirector withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 设置下载路径
    self.fullPath = [LeeFileDirector stringByAppendingString:self.fileName];
    // 获取下载进度
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:self.fullPath error:nil];
    // 获取已下载的长度
    return  [fileInfo[NSFileSize] longLongValue];
}

/** 成功回调 1代表下载后成功回调 2代表直接从磁盘中获取了 */
- (void)completCusesseWithCode:(NSInteger)code {
    NSDictionary *dict = [self downLoadInfoWithFinished:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:LeeDownloadCompletedNotification object:self userInfo:dict];
    if (code == 1) {
        // 存储 文件下载信息
        [[LeeCacheManager shareCacheManger] saveFileInfoWithDic:dict];
    }
    if (self.completeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completeBlock(dict,nil);
        });
    }
}

/** 失败回调 */
- (void)completFailueWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:LeeDownloadCompletedNotification object:self userInfo:@{@"error":error}];
    // 存储
    [[LeeCacheManager shareCacheManger] saveFileInfoWithDic:[self downLoadInfoWithFinished:NO]];
    if (self.completeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completeBlock(nil,error);
        });
    }
}

#pragma mark - get download info
// 构造回调信息
- (NSDictionary *)downLoadInfoWithFinished:(BOOL)finished {
    return  @{
                LeeFileUrlKey    : self.url,
                LeeFileNameKey   : self.fileName,
                LeeFilePathKey   : self.fullPath,
                LeeFileSizeKey   : @(self.currentSize),
                LeeTotalSizeKey  : @(self.totalSize),
                LeeFinishKey     : @(finished)
            };
}

#pragma mark -Public Methods
- (void)operateWithResponse:(NSURLResponse *)response {
    self.totalSize = self.currentSize + response.expectedContentLength;
    if (self.currentSize == 0) {
        // 创建空的文件
        [[NSFileManager defaultManager]  createFileAtPath:self.fullPath contents:nil attributes:nil];
    }
    // 创建文件句柄
    self.handle = [NSFileHandle fileHandleForWritingAtPath:self.fullPath];
    // 文件句柄移动到文件末尾 位置 // 返回值是 unsign long long
    [self.handle seekToEndOfFile];
    // 开始下载记录文件下载信息
    [[LeeCacheManager shareCacheManger] saveFileInfoWithDic:[self downLoadInfoWithFinished:NO]];
}

- (void)operateWithReceivingData:(NSData *)data {
    // 获得已经下载的文件大小
    self.currentSize += data.length;
    // 写入文件
    [self.handle writeData:data];
    if (self.progressBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressBlock((NSUInteger)self.currentSize,(NSUInteger)self.totalSize);
        });
    }
}

- (void)operateWithComplete:(NSError *)error {
    // 关闭文件句柄
    [self.handle closeFile];
    // 释放文件句柄
    self.handle = nil;
    if (error) {
        [self completFailueWithError:error];
    } else {
        [self completCusesseWithCode:1];
    }
}

- (void)configCallBacksWithDidReceiveResponseprogress:(LeeDownloadProgressBlock)progressBlock complete:(LeeDownloadCompleteBlock)completeBlock{
    self.progressBlock = progressBlock;
    self.completeBlock = completeBlock;
}

@end

