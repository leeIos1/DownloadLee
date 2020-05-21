//
//  LeeHeader.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#ifndef LeeHeader_h
#define LeeHeader_h

typedef void(^LeeDownloadProgressBlock)(NSInteger completeSize,NSInteger expectSize);
typedef void(^LeeDownloadCompleteBlock)(NSDictionary *respose,NSError *error);

#endif /* LeeHeader_h */
