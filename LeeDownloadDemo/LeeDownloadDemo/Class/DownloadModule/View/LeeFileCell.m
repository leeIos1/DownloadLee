//
//  LeeFileCell.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/19.
//  Copyright © 2020 apple. All rights reserved.
//

#import "LeeFileCell.h"

#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define rgba_lee(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define rgb_lee(l) [UIColor colorWithRed:l/255.0 green:l/255.0 blue:l/255.0 alpha:1]

@interface LeeFileCell()

@property (nonatomic ,strong)UILabel *fileNameLb;
@property (nonatomic ,strong)UIButton *statusBtn;
@property (nonatomic ,strong)UIButton *cancleBtn;
@property (nonatomic ,strong)UILabel *progressLabel;
@property (nonatomic ,strong)UIView *lineView;

@end

@implementation LeeFileCell

#pragma mark -Life Cycle Methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
        [self updateViewsFrame];
    }
    return self;
}

-(void)dealloc{
    [self.fileModel removeObserver:self forKeyPath:@"progress"];
    [self.fileModel removeObserver:self forKeyPath:@"downloadType"];
}

#pragma mark -Private Methods
-(void)initUI{
    [self addSubview:self.fileNameLb];
    [self addSubview:self.statusBtn];
    [self addSubview:self.cancleBtn];
    [self addSubview:self.progressLabel];
    [self addSubview:self.lineView];
}

-(void)updateViewsFrame{
    self.fileNameLb.frame = CGRectMake(15, 15, ScreenWidth - 140, 30);
    self.progressLabel.frame = CGRectMake(ScreenWidth - 115, 15, 60, 30);
    self.statusBtn.frame = CGRectMake(CGRectGetMaxX(self.progressLabel.frame)+5, 20, 20, 20);
    self.cancleBtn.frame = CGRectMake(CGRectGetMaxX(self.statusBtn.frame)+5, 20, 20, 20);
    self.lineView.frame = CGRectMake(0, 59.5, ScreenWidth, 0.5);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    LeeFileModel *model = (LeeFileModel *)object;
    //防止刷新删除等导致的复用问题
    if (![model.fileId isEqualToString:self.fileModel.fileId]) {
        return;
    }
    float from = 0, to = 0;
    if ([keyPath isEqualToString:@"progress"]) {
        if (change[NSKeyValueChangeOldKey]) {
            from = [change[NSKeyValueChangeOldKey] floatValue];
        }
        if (change[NSKeyValueChangeNewKey]) {
             to = [change[NSKeyValueChangeNewKey] floatValue];
        }
        self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",to];
    }
    
    if ([keyPath isEqualToString:@"downloadType"]) {
        if([change[NSKeyValueChangeOldKey] integerValue]!=[change[NSKeyValueChangeNewKey] integerValue]){
            [self updateUIWithDownloadType];
        }
    }
}

-(void)updateUIWithDownloadType{
    WeakSelf()
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (weakSelf.fileModel.downloadType) {
            case LeeWaitDownloadType:
                [weakSelf.statusBtn setImage:[UIImage imageNamed:@"LeeDownLoad"] forState:UIControlStateNormal];
                weakSelf.progressLabel.hidden = YES;
                weakSelf.cancleBtn.hidden = YES;
                break;
            case LeeDownloadingType:
                 [weakSelf.statusBtn setImage:[UIImage imageNamed:@"LeePause"] forState:UIControlStateNormal];
                 weakSelf.progressLabel.hidden = NO;
                 weakSelf.cancleBtn.hidden = NO;
                break;
            case LeeDownloadSupendType:
                 [weakSelf.statusBtn setImage:[UIImage imageNamed:@"LeeDownLoad"] forState:UIControlStateNormal];
                 weakSelf.progressLabel.hidden = NO;
                 weakSelf.cancleBtn.hidden = NO;
                break;
            case LeeDownloadCompletedType:
                [weakSelf.statusBtn setImage:[UIImage imageNamed:@"LeeCompleted"] forState:UIControlStateNormal];
                weakSelf.progressLabel.hidden = YES;
                weakSelf.cancleBtn.hidden = YES;
                break;
            default:
                break;
        }
    });
}

#pragma mark -Target Methods
-(void)changeDownLoadStatusAction{
    switch (self.fileModel.downloadType) {
        case LeeWaitDownloadType:
            self.fileModel.downloadType = LeeDownloadingType;
            if(self.downloadBlock){
                self.downloadBlock(self.fileModel);
            }
            break;
        case LeeDownloadingType:
             self.fileModel.downloadType = LeeDownloadSupendType;
             if(self.supendBlock){
                 self.supendBlock(self.fileModel);
             }
            break;
        case LeeDownloadSupendType:
             self.fileModel.downloadType = LeeDownloadingType;
             if(self.resumeBlock){
                 self.resumeBlock(self.fileModel);
             }
            break;
        case LeeDownloadCompletedType:
            return;
        break;
        default:
            break;
    }
    [self updateUIWithDownloadType];
}

-(void)cancleAction{
    self.fileModel.downloadType = LeeWaitDownloadType;
    if(self.cancleBlock){
        self.cancleBlock(self.fileModel);
    }
    [self updateUIWithDownloadType];
}

#pragma mark -Setters && Getters
-(void)setFileModel:(LeeFileModel *)fileModel{
    _fileModel = fileModel;
    _fileNameLb.text = fileModel.fileName;
    [_fileModel addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld context:nil];
    [_fileModel addObserver:self forKeyPath:@"downloadType" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld context:nil];
    [self updateUIWithDownloadType];
}

-(UILabel *)fileNameLb{
    if(!_fileNameLb){
        _fileNameLb = [[UILabel alloc] init];
        _fileNameLb.textColor = rgb_lee(33);
        _fileNameLb.font = [UIFont systemFontOfSize:15];
    }
    return _fileNameLb;
}

-(UIButton *)statusBtn{
    if(!_statusBtn){
        _statusBtn = [[UIButton alloc] init];
        [_statusBtn setImage:[UIImage imageNamed:@"LeeDownLoad"] forState:UIControlStateNormal];
        [_statusBtn addTarget:self action:@selector(changeDownLoadStatusAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _statusBtn;;
}

-(UIButton *)cancleBtn{
    if(!_cancleBtn){
        _cancleBtn = [[UIButton alloc] init];
        [_cancleBtn setImage:[UIImage imageNamed:@"LeeCancle"] forState:UIControlStateNormal];
        [_cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        _cancleBtn.hidden = YES;
    }
    return _cancleBtn;
}

-(UILabel *)progressLabel{
    if(!_progressLabel){
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = rgb_lee(150);
        _progressLabel.font = [UIFont systemFontOfSize:13];
        _progressLabel.layer.borderColor = rgb_lee(245).CGColor;
        _progressLabel.layer.borderWidth = 0.5;
        _progressLabel.hidden = YES;
    }
    return _progressLabel;
}

-(UIView *)lineView{
    if(!_lineView){
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = rgb_lee(245);
    }
    return _lineView;
}

@end
