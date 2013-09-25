//
//  YMDefines.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/29/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef YandexMoneyAPI_YMDefines_h
#define YandexMoneyAPI_YMDefines_h

#define YMKitDEBUG

#ifdef YMKitDEBUG
    #define YMLog(format, ...)  NSLog([(@"YMKit debugz:::") stringByAppendingString:format], ##__VA_ARGS__)
#else
    #define YMLog(format, ...)  ;
#endif

extern NSString * const kYMApiClientAuthURLString;
extern NSString * const kYMApiClientBaseURLString;
extern NSString * const kYMKitErrorDomain;
extern NSString * const kYMCurrentUserAccountKey;
extern NSString * const kYMKitKeychainDefaultAccount;
extern NSString * const kYMKeychainServiceName;
extern NSString * const kYMLoginViewResponseType;


/**
	Represents state of YMPayment.
 */
typedef enum{
    paymentIdle=0,//means nothing started yet
    paymentRequestSent,//means request-payment sent
    paymentRequestError,//got error in response to request-payment
    paymentReadyToProcess,//request-payment succeded, ready to send process-request
    paymentProcessSent,//sent process-payment request
    paymentProcessError,//got error in response to process-payment
    paymentProcessShouldRepeat,
    paymentFinished,//payment completed
}YMPaymentState;



/**
	Represents result of paymentRequest:... method of YMKit.
 */
typedef enum{
    paymentRequestSuccessful=0,
    paymentRequestRefused,
}YMPaymentRequestResult;

/**
	Represents result of paymentProcess:... method of YMKit.
 */
typedef enum{
    paymentProcessSuccessful=0,
    paymentProcessRefused,
    paymentProcessInProgress,
    paymentProcessUnknown,
}YMPaymentProcessResult;


typedef void(^YMGenericCompletionHandler)(NSError *error);
typedef void(^YMLoginSuccessHandler)(NSString *tempToken,NSError *error);
typedef void(^YMAuthSuccessHandler)(NSString *token, NSError *error);
typedef void(^YMObjectHandler)(id object, NSError *error);
typedef void(^YMPaymentRequestResultHandler)(YMPaymentRequestResult result, NSError *error);
typedef void(^YMPaymentProcessResultHandler)(YMPaymentProcessResult result, NSError *error);

#endif
