//
//  YMKit.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDefines.h"

@class YMApiClient;
@class YMPayment;

@interface YMKit : NSObject

/**
	HTTP client performs all request tasks.
 */
@property (nonatomic,retain,readonly) YMApiClient *apiClient;



/**
	Singleton YMKit object, this one should be used.
	@returns singleton YMKit object.
 */
+ (instancetype)sharedInstance;


/**
	Sets application client id(API client id) and scopes, required for your needs.
	@param clientId Application client id (API id).
	@param scopes Scopes:account-info,payment-shop,payment-p2p,operation-history,operation-details,money-source.
    @param landingPage Page on your server, which your client will be redirected to. In parameter it will hold token.
 */
- (void)setAppClientId:(NSString*)clientId scopes:(NSArray*)scopes authorizationLandingPagePath:(NSURL*)landingPage;


/**
	Starts authorization process, showing webView for authorization and automatically performing exchange of temporary token for persistent(real) token. User data can be accessed with currentUser method of YMUser class after authorization is completed successfuly(or during handler call).
	@param handler Block, that should process result of authorization. If error exists, means authorization failed.
 */
- (void)authorize:(YMGenericCompletionHandler)handler;


/**
	Perform token revoking operation. Currently stored user data will be wiped(token,account number,balance).
	@param handler Block, that should process result of token revoking.
 */
- (void)revokeAccess:(YMGenericCompletionHandler)handler;


/**
	Method for repeated account-info request. Account-info request will be sent to Y.Money API.
	@param handler Block, that should process result of user re-fetching. If returned error is nil, current user data will be re-written, also the YMUser object will be returned to handler. If error exists, you should process it.
 */
- (void)getCurrentUserWithHandler:(YMObjectHandler)handler;


/**
	Request-payment is used for creating payment on server, checking parameters of payment and its possibility.
	@param payment One of YMPayment subclasses: YMUserPayment or YMShopPayment. All payment parameters should be set.
	@param handler Block, that should process result of request-payment. If error is not nil, its description should be used to find the solution(whether not_enough_funds, or something else). If error is nil, means this payment(exactly this one, which you sent to requestPayment) is registered at server and now should be processed with processPayment:withHandler: method.
	@param immediate Bool value. If immediate is YES, the second step(processPayment) will be instantly sent after successful requestPayment. If immediate is NO, the user have to manually call processPayment:withHandler: method.
 */
- (void)requestPayment:(YMPayment*)payment withHandler:(YMGenericCompletionHandler)handler immediateProcess:(BOOL)immediate;


/**
	Process-payment is used for finishing actual, registered on server payment.
	@param payment One of YMPayment subclasses: YMUserPayment or YMShopPayment. This is object, that was already successfuly registered on server by requestPayment:withHandler:immediateProcess: method. If not registered payment is used, error will be returned to handler block.
	@param handler Block, that should process result of payment processing. If error is not nil, you should process it. If error is nil, then payment went well and is finished now. 
 */
- (void)processPayment:(YMPayment*)payment withHandler:(YMGenericCompletionHandler)handler;


@end
