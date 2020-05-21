//
//  UIViewController+LeeCategory.m
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/21.
//  Copyright © 2020 apple. All rights reserved.
//

#import "UIViewController+LeeCategory.h"

@implementation UIViewController (LeeCategory)

- (void)showAlertDialogWithTitle:(NSString *)title
                         messgae:(NSString *)message
{
    [self showAlertDialogWithTitle:title messgae:message sureBlcok:nil cancleBlock:nil cancelBtnTitle:nil otherBtnTitle:@"好"];
}

- (void)showAlertDialogWithTitle:(NSString *)title
                         messgae:(NSString *)message
                       sureBlcok:(LeeAlertBlock)sureBlock
                        btnTitle:(NSString *__nullable)str
{
    [self showAlertDialogWithTitle:title messgae:message sureBlcok:sureBlock cancleBlock:nil cancelBtnTitle:nil otherBtnTitle:str];
}

- (void)showAlertDialogWithTitle:(NSString *)title
                         messgae:(NSString *)message
                       sureBlcok:(LeeAlertBlock __nullable)sureBlock
                     cancleBlock:(LeeAlertBlock __nullable)cancleBlock
                  cancelBtnTitle:(NSString *__nullable)cancelTitle
                   otherBtnTitle:(NSString *__nullable)otherTitle

{
    if ([self validString:title] && [self validString:message])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        //修改按钮的颜色
        UIAlertAction *sure = [UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(sureBlock){
                sureBlock();
            }
        }];
        [sure setValue:[UIColor redColor] forKey:@"_titleTextColor"];
        if(!cancelTitle){
            cancelTitle = @"";
        }
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if(cancleBlock){
                cancleBlock();
            }
        }];
        [cancle setValue:[UIColor grayColor] forKey:@"_titleTextColor"];
        [alert addAction:sure];
        if(cancelTitle&&![cancelTitle
                          isEqualToString:@""]){
            [alert addAction:cancle];
        }
        [self presentViewController:alert animated:true completion:nil];
    }
}

-(BOOL)validString:(NSString *)string{
    if (string && [string isKindOfClass:[NSString class]] && string.length > 0)
    {
        return YES;
    }
    return NO;
}


@end
