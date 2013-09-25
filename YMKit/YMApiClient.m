//
//  YMApiClient.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMApiClient.h"
#import "YMAuthorization.h"
#import "YMLoginView.h"
#import "YMKeychain.h"
#import "YMPayment.h"
#import "YMUserPayment.h"
#import "YMShopPayment.h"

@implementation YMApiClient

+ (YMApiClient *)sharedClient{
    static YMApiClient *_sharedClient=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient=[[YMApiClient alloc] initWithBaseURL:[NSURL URLWithString:kYMApiClientBaseURLString]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url{
    self=[super initWithBaseURL:url];
    if (!self) return nil;
    
    return self;
}

#pragma mark - Auth headers

- (void)setAuthorizationHeaderWithToken:(NSString *)token{
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
    if (!token){
        YMLog(@"Empty token set to auth header.");
    }else{
        YMLog(@"Token set to auth header.");
    }
}

- (void)verifyAuthorizationHeader{
    YMLog(@"Verifying auth header...");
    if (! [self defaultValueForHeader:@"Authorization"]) {
        YMLog(@"Its not set. Setting...");
        NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:kYMCurrentUserAccountKey];
        YMLog(@"Got current account = %@", account);
        NSString *token = [YMKeychain authenticationTokenForAccount:account];
        YMLog(@"Got token = %@", token);
        [self setAuthorizationHeaderWithToken:token];
    }
    YMLog(@"Checked auth header.");
}

#pragma mark -

- (void)createAuthorizationWithSuccessHandler:(YMAuthSuccessHandler)handler{
    //login view part
    YMLoginView *loginView=[[YMLoginView alloc] initWithAuthorization:self.auth];
    [loginView showLoginDialogWithSuccessBlock:^(NSString *tempToken, NSError *error){
        if (error){
            if (handler)
                handler(nil,error);
        }else{
            //got tempToken, now exchange it for real token
            AFHTTPClient *authClient=[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kYMApiClientAuthURLString]];
            [authClient postPath:@"/oauth/token"
                      parameters:@{@"code":tempToken,@"client_id":self.auth.clientId,@"grant_type":@"authorization_code",@"redirect_uri":self.auth.landingPage}
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                             if (handler){
                                 NSError *error=nil;
                                 NSDictionary *response=[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                        options:NSJSONReadingAllowFragments
                                                                                          error:&error];
                                 if (response[@"access_token"]&&!error){
                                     handler(response[@"access_token"],nil);
                                 }else{
                                     NSError *error=[NSError errorWithDomain:kYMKitErrorDomain
                                                                        code:100
                                                                    userInfo:@{NSLocalizedDescriptionKey:response[@"error"]}];
                                     handler(nil,error);
                                 }
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             if (handler){
                                 handler(nil,error);
                             }
                         }];
        }
    }];
}

- (void)getAuthorizedUserWithHandler:(YMObjectHandler)handler{
    [self verifyAuthorizationHeader];
    [self setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded;charset=UTF-8"];
    [self postPath:@"/api/account-info"
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject){
               if (handler)
                   handler(responseObject,nil);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error){
               if (handler)
                   handler(nil,error);
           }];
}

- (void)revokeCurrentAuthorizedUserWithHandler:(YMGenericCompletionHandler)handler{
    [self verifyAuthorizationHeader];
    [self postPath:@"/api/revoke"
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject){
               NSInteger code = operation.response.statusCode;
               NSError *error=nil;
               if (code==200){
                   //OK means token revoked
                   error=nil;
               }else if (code==400){
                   error=[NSError errorWithDomain:kYMKitErrorDomain
                                                      code:100
                                                  userInfo:@{NSLocalizedDescriptionKey:@"Maybe auth header lost?"}];
                   if (handler)
                       handler(error);
               }else if (code==401){
                   error=[NSError errorWithDomain:kYMKitErrorDomain
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"Token doesnt exist."}];
               }
               if (handler)
                   handler(error);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error){
               if (handler)
                   handler(error);
           }];
}

- (void)sendRequestPayment:(YMPayment *)payment resultHandler:(YMPaymentRequestResultHandler)handler{
    switch (payment.state) {
        case paymentReadyToProcess:
        case paymentRequestError:
        case paymentRequestSent:
            //not ok to sent, already sent and got result
            if (handler){
                NSError *error=[NSError errorWithDomain:kYMKitErrorDomain
                                                   code:100
                                               userInfo:@{NSLocalizedDescriptionKey:@"State does not match for request-payment"}];
                handler(paymentRequestRefused,error);
            }
            return;
            break;
        case paymentIdle:
        default:
            //ok to sent request-payment
            break;
    }
    [self verifyAuthorizationHeader];
    NSDictionary *params=nil;
    if ([payment isKindOfClass:[YMUserPayment class]]){
        YMUserPayment *userPayment=(YMUserPayment*)payment;
        params=!payment.debugMode?@{@"pattern_id":@"p2p",@"to":userPayment.recepient,@"amount":[NSString stringWithFormat:@"%.02f",userPayment.amount],@"comment":userPayment.comment,@"message":userPayment.message}:@{@"pattern_id":@"p2p",@"to":userPayment.recepient,@"amount":[NSString stringWithFormat:@"%.02f",userPayment.amount],@"comment":userPayment.comment,@"message":userPayment.message,@"test_payment":@"true",@"test_result":@"success"};
        
        if (userPayment.debugMode) YMLog(@"YMUserPayment request-payment Debug Mode.");
        
    }else if ([payment isKindOfClass:[YMShopPayment class]]){
        YMShopPayment *shopPayment=(YMShopPayment*)payment;
        NSMutableDictionary* mutableParams=[NSMutableDictionary dictionaryWithObject:shopPayment.patternId forKey:@"pattern_id"];
        for (NSString *key in shopPayment.parameters){
            [mutableParams setObject:shopPayment.parameters[key] forKey:key];
        }
        if (shopPayment.debugMode){
            [mutableParams setObject:@"true" forKey:@"test_payment"];
            [mutableParams setObject:@"success" forKey:@"test_result"];
            YMLog(@"YMShopPayment request-payment Debug Mode.");
        }
        params=[NSDictionary dictionaryWithDictionary:mutableParams];
    }else{
        NSAssert(NO, @"Should send YMUserPayment or YMShopPayment to YMKit!");
    }
    
    YMLog(@"Sending request-payment...\nParameters:%@",params);
    payment.state=paymentRequestSent;
    [self setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded;charset=UTF-8"];
    [self postPath:@"/api/request-payment"
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject){
               NSError *error=nil;
               NSDictionary *resp=[NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:0
                                                                    error:&error];
               if ([resp[@"status"] isEqualToString:@"success"]){
                   YMLog(@"Success response for YMUserPayment request-payment.");
                   payment.requestId=resp[@"request_id"];
                   payment.state=paymentReadyToProcess;
                   if (handler){
                       handler(paymentRequestSuccessful,nil);
                   }
               }else if([resp[@"status"] isEqualToString:@"refused"]){
                   YMLog(@"Refused YMUserPayment request-payment.");
                   payment.state=paymentRequestError;
                   error=[NSError errorWithDomain:kYMKitErrorDomain
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:resp[@"error_description"],NSLocalizedFailureReasonErrorKey:resp[@"error"]}];
                   if (handler){
                       handler(paymentRequestRefused,error);
                   }
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error){
               YMLog(@"Error sending request-payment.");
               payment.state=paymentRequestError;
               if (handler)
                   handler(paymentRequestRefused,error);
           }];
    
}

- (void)sendProcessPayment:(YMPayment *)payment resultHandler:(YMPaymentProcessResultHandler)handler{
    if (![payment isKindOfClass:[YMUserPayment class]] && ![payment isKindOfClass:[YMShopPayment class]])
        NSAssert(NO, @"Should send YMUserPayment or YMShopPayment to YMKit!");
    switch (payment.state) {
        case paymentReadyToProcess:
            //ok to call process-payment
            break;
        default:{
            NSError *error=[NSError errorWithDomain:kYMKitErrorDomain
                                               code:100
                                           userInfo:@{NSLocalizedDescriptionKey:@"State doesnt match to action."}];
            if (handler)
                handler(paymentProcessRefused, error);
            return;
            break;
        }
    }
    if (!payment.requestId){
        NSError *error=[NSError errorWithDomain:kYMKitErrorDomain
                                           code:100
                                       userInfo:@{NSLocalizedDescriptionKey:@"No requestId in call to process-payment"}];
        if (handler)
            handler(paymentProcessRefused,error);
        return;
    }
    [self verifyAuthorizationHeader];
//    if ([payment isKindOfClass:[YMUserPayment class]]){
//        YMUserPayment *userPayment=(YMUserPayment*)payment;
    NSDictionary *params=!payment.debugMode?@{@"request_id":payment.requestId}:@{@"request_id":payment.requestId,@"test_payment":@"true",@"test_result":@"success"};
    
    if (payment.debugMode) YMLog(@"YMPayment process-payment Debug Mode.");
    
    payment.state=paymentProcessSent;
    YMLog(@"Sending YMUserPayment process-payment...\nParameters:%@",params);
    [self setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded;charset=UTF-8"];
    [self postPath:@"/api/process-payment"
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject){
               NSError *error=nil;
               NSDictionary *resp=[NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:0
                                                                    error:&error];
               if ([resp[@"status"] isEqualToString:@"success"]){
                   YMLog(@"Success response for YMUserPayment process-payment.");
                   payment.state=paymentFinished;
                   if (handler)
                       handler(paymentProcessSuccessful, nil);
               }else if ([resp[@"status"] isEqualToString:@"refused"]){
                   YMLog(@"Refused YMUserPayment process-payment.");
                   payment.state=paymentProcessError;
                   if (handler){
                       error=[NSError errorWithDomain:kYMKitErrorDomain
                                                 code:100
                                             userInfo:@{NSLocalizedDescriptionKey:resp[@"error"]}];
                       handler(paymentProcessRefused, error);
                   }
               }else{
                   YMLog(@"In-Progress YMUserPayment process-payment.");
                   payment.state=paymentProcessShouldRepeat;
                   if (handler){
                       handler(paymentProcessInProgress, nil);
                   }
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error){
               YMLog(@"Error sending process-payment.");
               if (handler)
                   handler(paymentProcessRefused, error);
           }];
//    }else if ([payment isKindOfClass:[YMShopPayment class]]){
//        
//    }else{
//    }
}

@end
