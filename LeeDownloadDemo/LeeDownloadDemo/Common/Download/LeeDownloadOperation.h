//
//  LeeDownloadOperation.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeeHeader.h"
NS_ASSUME_NONNULL_BEGIN
 

@interface LeeDownloadOperation : NSObject

@property (nonatomic,copy) LeeDownloadProgressBlock progressBlock;
@property (nonatomic,copy) LeeDownloadCompleteBlock completeBlock;
@property (readonly,nonatomic, copy)NSString *url;
@property (readonly,nonatomic,strong)NSURLSessionDataTask *dataTask;

- (instancetype)initWith:(NSString *)url session:(NSURLSession *)session;
- (void)operateWithResponse:(NSURLResponse *)response;
- (void)operateWithReceivingData:(NSData *)data;
- (void)operateWithComplete:(NSError *)error;
- (void)configCallBacksWithDidReceiveResponseprogress:(LeeDownloadProgressBlock)progressBlock complete:(LeeDownloadCompleteBlock)completeBlock;

@end

NS_ASSUME_NONNULL_END
