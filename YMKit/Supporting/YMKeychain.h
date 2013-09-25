//
//  YMKeychain.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDefines.h"

@interface YMKeychain : NSObject

+ (BOOL)storeAuthenticationToken:(NSString *)token userAccount:(NSString *)userAccount;

+ (NSString *)authenticationTokenForAccount:(NSString *)account;

+ (void)removeAuthenticationTokenForAccount:(NSString *)account;

@end
