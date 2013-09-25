//
//  YMKeychain.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMKeychain.h"
#import "SSKeychain.h"

@implementation YMKeychain

+ (BOOL)storeAuthenticationToken:(NSString *)token userAccount:(NSString *)userAccount
{
    NSString *account = userAccount ?: kYMKitKeychainDefaultAccount;
    return [SSKeychain setPassword:token
                        forService:kYMKeychainServiceName
                           account:account];
}

+ (NSString *)authenticationTokenForAccount:(NSString *)account
{
    return [SSKeychain passwordForService:kYMKeychainServiceName account:account];
}

+ (void)removeAuthenticationTokenForAccount:(NSString *)account
{
    [SSKeychain deletePasswordForService:kYMKeychainServiceName account:account];
}

@end
