//
//  LeeFileCell.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/19.
//  Copyright © 2020 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeeFileModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^LeeDownloadBlock)(LeeFileModel * fileModel);
//typedef void(^LeePauseBlock)(LeeFileModel * fileModel);
//typedef void(^LeeCancleBlock)(LeeFileModel * fileModel);

@interface LeeFileCell : UITableViewCell

@property (nonatomic ,strong)LeeFileModel *fileModel;
@property (nonatomic ,copy)LeeDownloadBlock downloadBlock;
@property (nonatomic ,copy)LeeDownloadBlock pauseBlock;
@property (nonatomic ,copy)LeeDownloadBlock resumeBlock;
@property (nonatomic ,copy)LeeDownloadBlock cancleBlock;

@end

NS_ASSUME_NONNULL_END
