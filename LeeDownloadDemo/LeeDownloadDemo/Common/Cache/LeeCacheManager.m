//
//  LeeCacheManager.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

#import "LeeCacheManager.h"

@interface LeeCacheManager ()

@property (nonatomic ,strong) dispatch_semaphore_t semaphore;
@property (nonatomic ,strong) NSMutableDictionary *fileInfoDic;

@end

@implementation LeeCacheManager

#pragma mark -Instance Methods
+(LeeCacheManager *)shareCacheManger{
    static LeeCacheManager *sharedCacheManagerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCacheManagerInstance = [[LeeCacheManager alloc] init];
        sharedCacheManagerInstance.semaphore = dispatch_semaphore_create(1);
    });
    return sharedCacheManagerInstance;
}

#pragma mark - Public Methods
-(NSDictionary *)queryFileInfoWithUrl:(NSString *)url{
    NSMutableDictionary *dic = [[self.fileInfoDic objectForKey:url] mutableCopy];
    if (dic) {
        NSString *path = [LeeFileDirector stringByAppendingString:dic[LeeFileNameKey]];
        [dic setObject:path forKey:LeeFilePathKey];
    }
    return dic;
}
 
-(BOOL)saveFileInfoWithDic:(NSDictionary *)dic{
    //信号量+1(线程等待)
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSString *key = dic[LeeFileUrlKey];
    NSMutableDictionary *dict =  self.fileInfoDic;
    [dict setObject:dic forKey:key];
    BOOL flag = [dict writeToFile:LeeFileInfoPath atomically:YES];
    //信号量-1(线程结束）
    dispatch_semaphore_signal(_semaphore);
    return flag;
}
 
-(BOOL)deleteFileWithUrl:(NSString *)urlString {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSDictionary *dict = self.fileInfoDic[urlString];
    BOOL flag = [[NSFileManager defaultManager] removeItemAtPath:dict[LeeFilePathKey] error:nil];
    [self.fileInfoDic removeObjectForKey:urlString];
    BOOL writeFlag = [self.fileInfoDic writeToFile:LeeFileInfoPath atomically:YES];
    dispatch_semaphore_signal(self.semaphore);
    return (flag && writeFlag);
}

-(NSInteger)totalSizeWith:(NSString *)urlString{
    return [[self queryFileInfoWithUrl:urlString][LeeTotalSizeKey] integerValue];
}

-(BOOL)clearFiles{
   return  [[NSFileManager defaultManager] removeItemAtPath:LeeFileDirector error:nil];
}

-(BOOL)clearFileInfos{
    [self.fileInfoDic removeAllObjects];
    return YES;
}

-(BOOL)clearFileAndFileInfos {
    return [self clearFiles] && [self clearFileInfos];
}

#pragma mark -Setter && Getter Methods
-(NSMutableDictionary *)fileInfoDic{
    if(!_fileInfoDic){
        _fileInfoDic = [[NSDictionary dictionaryWithContentsOfFile:LeeFileInfoPath] mutableCopy];
        if (!_fileInfoDic) {
            _fileInfoDic = [NSMutableDictionary dictionary];
        }
    }
    return _fileInfoDic;
}

@end
