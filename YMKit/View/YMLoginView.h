//
//  YMLoginView.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMDefines.h"

@class YMAuthorization;

@interface YMLoginView : UIView

- (id)initWithAuthorization:(YMAuthorization*)auth;

- (void)showLoginDialogWithSuccessBlock:(YMLoginSuccessHandler)handler;
- (void)hideLoginDialog;

@end
