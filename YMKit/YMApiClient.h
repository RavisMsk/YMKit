//
//  YMApiClient.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "AFNetworking.h"
#import "YMDefines.h"

@class YMAuthorization;
@class YMPayment;

@interface YMApiClient : AFHTTPClient

@property (nonatomic,strong) YMAuthorization *auth;

+ (YMApiClient*)sharedClient;

- (void)createAuthorizationWithSuccessHandler:(YMAuthSuccessHandler)handler;
- (void)getAuthorizedUserWithHandler:(YMObjectHandler)handler;
- (void)revokeCurrentAuthorizedUserWithHandler:(YMGenericCompletionHandler)handler;

- (void)sendRequestPayment:(YMPayment*)payment resultHandler:(YMPaymentRequestResultHandler)handler;
- (void)sendProcessPayment:(YMPayment*)payment resultHandler:(YMPaymentProcessResultHandler)handler;

@end
