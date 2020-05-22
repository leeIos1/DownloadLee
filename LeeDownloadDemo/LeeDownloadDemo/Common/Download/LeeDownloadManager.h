//
//  LeeDownloadManager.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeeHeader.h"
NS_ASSUME_NONNULL_BEGIN

 
@interface LeeDownloadManager : NSObject

+ (instancetype)shareManager;
 
/** 开启下载任务 监听下载进度、完成下载 */
- (void)downloadWithURL:(NSURL *)url
                   type:(LeeDownloadTypeBlock)typeBlock
               progress:(LeeDownloadProgressBlock)progressBlock
               complete:(LeeDownloadCompleteBlock)completeBlock;
 
- (void)startDownLoadWithUrl:(NSString *)url;

- (void)supendDownloadWithUrl:(NSString *)url;
 
- (void)cancelDownloadWithUrl:(NSString *)url;

- (void)suspendAllDownloadTask;

- (void)startAllDownloadTask;

- (void)stopAllDownloads;

@end

NS_ASSUME_NONNULL_END
