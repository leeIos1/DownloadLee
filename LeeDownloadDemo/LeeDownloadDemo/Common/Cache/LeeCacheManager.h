//
//  LeeCacheManager.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
 

NS_ASSUME_NONNULL_BEGIN

@interface LeeCacheManager : NSObject

+(LeeCacheManager *)shareCacheManger;

-(NSDictionary *)queryFileInfoWithUrl:(NSString *)url;
-(BOOL)saveFileInfoWithDic:(NSDictionary *)dic;
-(BOOL)deleteFileWithUrl:(NSString *)urlString;
-(NSInteger)totalSizeWith:(NSString *)urlString;
/**清除下载文件*/
-(BOOL)clearFiles;
/**清除下载文件缓存信息*/
-(BOOL)clearFileInfos;
/**清除下载文件和下载文件的缓存信息*/
-(BOOL)clearFileAndFileInfos;

@end

NS_ASSUME_NONNULL_END
