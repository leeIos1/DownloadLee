//
//  NSURLSession+LeeCategory.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (LeeCategory)

- (NSURLSessionDataTask *)lee_downloadDataTaskWithUrlString:(NSString *)urlString startSize:(int64_t)startSize;

@end

NS_ASSUME_NONNULL_END
