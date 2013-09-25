//
//  YMUser.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMUser.h"
#import "YMKeychain.h"

static YMUser *_currentUser = nil;

@implementation YMUser

- (NSString *)token{
    if (_currentUser){
        return [YMKeychain authenticationTokenForAccount:_currentUser.account];
    }
    else return nil;
}

+ (instancetype)currentUser{
    if (!_currentUser){
        NSString *account=[[NSUserDefaults standardUserDefaults] objectForKey:kYMCurrentUserAccountKey];
        if (account){
            NSNumber *balance=[[NSUserDefaults standardUserDefaults] objectForKey:account];
            _currentUser=[YMUser objectWithDictionary:@{@"account":account,@"balance":balance}];
        }
    }
    return  _currentUser;
}

+ (void)setCurrentUser:(YMUser *)user{
    if (user){
        //set new user data
        _currentUser=user;
        [[NSUserDefaults standardUserDefaults] setObject:user.account forKey:kYMCurrentUserAccountKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [YMKeychain storeAuthenticationToken:user.token userAccount:user.account];
    }else{
        [YMKeychain removeAuthenticationTokenForAccount:_currentUser.account];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_currentUser.account];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kYMCurrentUserAccountKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _currentUser=nil;
    }
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dict{
    YMUser *object=[YMUser new];
    object.account=dict[@"account"];
    object.balance=dict[@"balance"];
    return object;
}

@end
