//
//  LeeDownloadSesstion.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LeeDownloadSesstion : NSObject

// 接口回调
- (void)downloadWithURL:(NSURL *)url
                  begin:(void(^)(NSString *))begin
               progress:(void(^)(NSInteger,NSInteger))progress
               complete:(void(^)(NSDictionary *,NSError *))complet;


- (void)startDownLoadWithUrl:(NSString *)url;
- (void)supendDownloadWithUrl:(NSString *)url;
- (void)cancelDownloadWithUrl:(NSString *)url;
- (void)cancelAllDownloads;
- (void)startAllDownloads;
- (void)suspendAllDownloads;

@end

NS_ASSUME_NONNULL_END
