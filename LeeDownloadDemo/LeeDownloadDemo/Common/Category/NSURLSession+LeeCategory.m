//
//  NSURLSession+LeeCategory.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import "NSURLSession+LeeCategory.h"

@implementation NSURLSession (LeeCategory)

- (NSURLSessionDataTask *)lee_downloadDataTaskWithUrlString:(NSString *)urlString startSize:(int64_t)startSize{
    if (urlString && [urlString isKindOfClass:[NSString class]] && urlString.length > 0){
         NSURL *url = [NSURL URLWithString:urlString];
         if (!url) {
             return nil;
         }
         NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
         /*
          bytes=0-100    请求0-100
          bytes=200-1000
          bytes=200-     从200开始直到结尾
          bytes=-100
          */
         NSString *rangeStr = [NSString stringWithFormat:@"bytes=%lld-",startSize];
         [request setValue:rangeStr forHTTPHeaderField:@"Range"];
         return [self dataTaskWithRequest:request];
    }
    return nil;
}

@end
