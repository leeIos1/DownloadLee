//
//  LeeFileVC.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/19.
//  Copyright © 2020 apple. All rights reserved.
//

#import "LeeFileVC.h"
#import "LeeFileCell.h"
#import "LeeFileModel.h"
#import "LeeCacheManager.h"
#import "LeeDownloadManager.h"
#import "UIViewController+LeeCategory.h"

static NSString *LeeFileIdentifier = @"LeeFileIdentifier";

@interface LeeFileVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong)LeeDownloadManager *downloadManager;
@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)NSMutableArray <LeeFileModel *>*dataArr;

@end

@implementation LeeFileVC

#pragma mark -Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"文件列表";
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        self.navigationController.navigationBar.translucent = NO;
    }
    [self clearOriginFiles];
    [self initUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadError:) name:LeeDownloadErrorNotification object:nil];
}
 
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -Private Methods
-(void)initUI{
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(cancleAllAction) forControlEvents:UIControlEventTouchUpInside];
        
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:cancleButton];
    rightItem.imageInsets = UIEdgeInsetsMake(0, -15,0, 0);
    self.navigationItem.rightBarButtonItem = rightItem;
    UIButton *resumeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [resumeButton setTitle:@"恢复" forState:UIControlStateNormal];
    [resumeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [resumeButton addTarget:self action:@selector(resumeAllAction) forControlEvents:UIControlEventTouchUpInside];
        
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:resumeButton];
    leftItem.imageInsets = UIEdgeInsetsMake(0, 15,0, 0);
    self.navigationItem.leftBarButtonItem = leftItem;

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

-(void)clearOriginFiles{
    [[LeeCacheManager shareCacheManger] clearFiles];
}
 
- (void)downlaodWithUrlString:(LeeFileModel *)fileModel{
    WeakSelf()
    NSURL *url = [NSURL URLWithString:fileModel.fileUrl];
    [self.downloadManager downloadWithURL:url type:^(NSInteger loadType) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(loadType == 0){
                fileModel.downloadType = LeeDownloadSupendType;
                [weakSelf showAlertDialogWithTitle:@"提示" messgae:[NSString stringWithFormat:@"当前最大下载任务量为%d",LeeMaxDownloadCount]];
            }else{
                fileModel.downloadType = LeeDownloadingType;
            }
        });
        
    } progress:^(NSInteger completeSize, NSInteger expectSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            fileModel.progress = 100.0 * completeSize / expectSize;
        });
        
    } complete:^(NSDictionary * _Nullable respose, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                fileModel.downloadType = LeeWaitDownloadType;
                [weakSelf showAlertDialogWithTitle:@"提示" messgae:[NSString stringWithFormat:@"%@下载失败",fileModel.fileName]];
            }else{
                fileModel.downloadType = LeeDownloadCompletedType;
            }
        });
    }];
  
}

- (void)downloadError:(NSNotification *)notification{
    NSDictionary *dic = notification.object;
    WeakSelf()
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showAlertDialogWithTitle:@"提示" messgae:dic[LeeErrorKey]];
    });
}

#pragma mark -Target Methods
-(void)cancleAllAction{
    for (LeeFileModel *fileModel in self.dataArr) {
        if(fileModel.downloadType == LeeDownloadingType){
            fileModel.downloadType = LeeDownloadSupendType;
        }
    }
    [self.downloadManager suspendAllDownloadTask];
}

-(void)resumeAllAction{
    NSInteger count = 0;
    for (LeeFileModel *fileModel in self.dataArr) {
        if(fileModel.downloadType == LeeDownloadSupendType){
            count++;
            if(count > LeeMaxDownloadCount){
                return;
            }
            [self downlaodWithUrlString:fileModel];
        }
    }
//    [self.downloadManager startAllDownloadTask];
}

#pragma mark -Tableview delegate && datasource Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeeFileCell *cell = [tableView dequeueReusableCellWithIdentifier:LeeFileIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LeeFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeeFileIdentifier];
    }
    cell.fileModel = self.dataArr[indexPath.row];
    WeakSelf()
    cell.downloadBlock = ^(LeeFileModel * _Nonnull fileModel) {
        [weakSelf downlaodWithUrlString:fileModel];
    };
    cell.supendBlock = ^(LeeFileModel * _Nonnull fileModel) {
        [weakSelf.downloadManager supendDownloadWithUrl:fileModel.fileUrl];
    };
    cell.resumeBlock = ^(LeeFileModel * _Nonnull fileModel) {
        [weakSelf downlaodWithUrlString:fileModel];
    };
    cell.cancleBlock = ^(LeeFileModel * _Nonnull fileModel) {
        [weakSelf.downloadManager cancelDownloadWithUrl:fileModel.fileUrl];
    };
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -Setter && Getter Methods
-(NSMutableArray<LeeFileModel *> *)dataArr{
    if(!_dataArr){
        _dataArr = [[NSMutableArray alloc] init];
        NSString *jsonPath;
        jsonPath = [[NSBundle mainBundle] pathForResource:@"LeeFile" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        NSError *jsonError;
        NSDictionary *optionDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];
        NSArray *datas = optionDic[@"items"];
        for (NSDictionary *dic in datas) {
            LeeFileModel *fileModel = [LeeFileModel allocModelWithDic:dic];
            [_dataArr addObject:fileModel];
        }
    }
    return _dataArr;
}

-(UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - DeviceNavHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[LeeFileCell class] forCellReuseIdentifier:LeeFileIdentifier];
    }
    return _tableView;
}

-(LeeDownloadManager *)downloadManager{
    return [LeeDownloadManager shareManager];
}
@end
