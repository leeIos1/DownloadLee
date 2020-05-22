//
//  LeeDownloadSesstion.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeeHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface LeeDownloadSesstion : NSObject

- (void)downloadWithURL:(NSURL *)url
                   type:(LeeDownloadTypeBlock)typeBlock
               progress:(LeeDownloadProgressBlock)progressBlock
               complete:(LeeDownloadCompleteBlock)completeBlock;

- (void)startDownLoadWithUrl:(NSString *)url;
- (void)supendDownloadWithUrl:(NSString *)url;
- (void)cancelDownloadWithUrl:(NSString *)url;
- (void)cancelAllDownloads;
- (void)startAllDownloads;
- (void)suspendAllDownloads;

@end

NS_ASSUME_NONNULL_END
