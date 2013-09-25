//
//  YMAppDelegate.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMKit.h"

@class YMViewController;

@interface YMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) YMKit *yandex;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YMViewController *viewController;

@end
