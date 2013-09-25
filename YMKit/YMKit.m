//
//  YMKit.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMKit.h"
#import "YMApiClient.h"
#import "YMAuthorization.h"
#import "YMUser.h"
#import "YMKeychain.h"
#import "YMPayment.h"

@interface YMKit ()

@property (nonatomic,retain,readwrite) YMApiClient *apiClient;

@end

@implementation YMKit

#pragma mark - Shared Instance

+ (instancetype)sharedInstance{
    static YMKit *_sharedInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance=[[YMKit alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Property

- (YMApiClient *)apiClient{
    if (!_apiClient){
        _apiClient=[YMApiClient sharedClient];
        [_apiClient setAuthorizationHeaderWithToken:[YMUser currentUser].token];
    }
    return _apiClient;
}

#pragma mark - 

- (void)setAppClientId:(NSString *)clientId scopes:(NSArray *)scopes authorizationLandingPagePath:(NSURL *)landingPage{
    YMAuthorization *auth=[YMAuthorization new];
    [auth setClientId:clientId];
    [auth setScopes:scopes];
    [auth setLandingPage:landingPage];
    [self.apiClient setAuth:auth];
}

- (void)authorize:(YMGenericCompletionHandler)handler{
    YMLog(@"Starting authorize process...");
    [self.apiClient createAuthorizationWithSuccessHandler:^(NSString *token, NSError *error){
        if (error){
            if (handler)
                handler(error);
        }else{
            if (token){
                YMLog(@"Received persistent token. Setting header and getting current user...");
                [self.apiClient setAuthorizationHeaderWithToken:token];
                [self getCurrentUserWithHandler:^(id user,NSError *error){
                    if (error){
                        handler(error);
                    }else{
                        YMLog(@"Received current user.");
                        [YMKeychain storeAuthenticationToken:token
                                                 userAccount:[(YMUser*)user account]];
                        YMLog(@"Saved token to keychain.");
                        handler(nil);
                    }
                }];
            }else{
                NSError *error=[NSError errorWithDomain:kYMKitErrorDomain
                                                   code:100
                                               userInfo:@{NSLocalizedDescriptionKey:@"Token is null!"}];
                if (handler)
                    handler(error);
            }
        }
    }];
}

- (void)revokeAccess:(YMGenericCompletionHandler)handler{
    YMLog(@"Starting token revoke process...");
    [self.apiClient revokeCurrentAuthorizedUserWithHandler:^(NSError *error){
        if (error){
            if (handler)
                handler(error);
        }else{
            [self.apiClient clearAuthorizationHeader];
#ifndef YMKitDEBUG
            [YMUser setCurrentUser:nil];
#else
            YMLog(@"Testing whether token is removed from keychain...");
            NSString *account=[YMUser currentUser].account;
            YMLog(@"Saved account = %@", account);
            [YMUser setCurrentUser:nil];
            YMLog(@"Current user set to nil.");
            NSString *token=[YMKeychain authenticationTokenForAccount:account];
            YMLog(@"Token from keychain = %@", token);
            YMLog(@"Everything is %@",token?@"BAD.":@"GOOD.");
#endif
            if (handler)
                handler(nil);
        }
    }];
}

- (void)getCurrentUserWithHandler:(YMObjectHandler)handler{
    [self.apiClient getAuthorizedUserWithHandler:^(id object, NSError *error){
        if (!error){
            NSError *internalError=nil;
            NSDictionary *userDict=[NSJSONSerialization JSONObjectWithData:object
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&internalError];
            if (internalError){
                if (handler)
                    handler(nil,internalError);
            }else{
                YMLog(@"Current user received and set.");
                YMUser *user=[YMUser objectWithDictionary:userDict];
                [YMUser setCurrentUser:user];
                [[NSUserDefaults standardUserDefaults] setObject:user.balance forKey:user.account];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (handler)
                    handler(user,nil);
            }
        }else{
            if (handler)
                handler(nil,error);
        }
    }];
}

- (void)requestPayment:(YMPayment*)payment withHandler:(YMGenericCompletionHandler)handler immediateProcess:(BOOL)immediate{
    if (!payment){
        if (handler){
            NSError *error=[NSError errorWithDomain:kYMKitErrorDomain
                                               code:100
                                           userInfo:@{NSLocalizedDescriptionKey:@"Payment = (nil)"}];
            handler(error);
        }
    }else{
        [self.apiClient sendRequestPayment:payment resultHandler:^(YMPaymentRequestResult result, NSError *error){
            if (!error){
                if (immediate){
                    [self processPayment:payment withHandler:^(NSError *error){
                        if (handler){
                            if (error)
                                handler(error);
                            else
                                handler(nil);
                        }
                    }];
                }else{
                    if (handler)
                        handler(nil);
                }
            }else{
                if (handler)
                    handler(error);
            }
        }];
    }
}

- (void)processPayment:(YMPayment*)payment withHandler:(YMGenericCompletionHandler)handler{
    if (!payment){
        if (handler){
            NSError *error=[NSError errorWithDomain:kYMKitErrorDomain
                                               code:100
                                           userInfo:@{NSLocalizedDescriptionKey:@"Payment = (nil)"}];
            handler(error);
        }
    }else{
        [self.apiClient sendProcessPayment:payment resultHandler:^(YMPaymentProcessResult result, NSError *error){
            if (!error){
                switch (result) {
                    case paymentProcessSuccessful:
                        if (handler)
                            handler(nil);
                        break;
                    case paymentProcessInProgress:{
                        NSError *error=[NSError errorWithDomain:kYMKitErrorDomain
                                                           code:100
                                                       userInfo:@{NSLocalizedDescriptionKey:@"Payment process is in-progress. Repeat process-payment in a few minutes."}];
                        if (handler)
                            handler(error);
                        break;
                    }
                    default:
                        break;
                }
            }else{
                if (handler)
                    handler(error);
            }
        }];
    }
}

@end
