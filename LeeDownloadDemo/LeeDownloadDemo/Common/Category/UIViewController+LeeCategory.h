//
//  UIViewController+LeeCategory.h
//  LeeDownLoadDemo
//
//  Created by apple on 2020/5/21.
//  Copyright © 2020 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 确定按钮回调 */
typedef void (^LeeAlertBlock)(void);

@interface UIViewController (LeeCategory)

- (void)showAlertDialogWithTitle:(NSString *)title
                         messgae:(NSString *)message;

- (void)showAlertDialogWithTitle:(NSString *)title
                         messgae:(NSString *)message
                       sureBlcok:(LeeAlertBlock __nullable)sureBlock
                        btnTitle:(NSString *__nullable)str;

- (void)showAlertDialogWithTitle:(NSString *)title
                         messgae:(NSString *)message
                       sureBlcok:(LeeAlertBlock __nullable)sureBlock
                     cancleBlock:(LeeAlertBlock __nullable)cancleBlock
                  cancelBtnTitle:(NSString *__nullable)cancelTitle
                   otherBtnTitle:(NSString *__nullable)otherTitle;

@end

NS_ASSUME_NONNULL_END
