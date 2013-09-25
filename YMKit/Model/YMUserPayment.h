//
//  YMUserPayment.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 9/5/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMPayment.h"
#import "YMDefines.h"

@interface YMUserPayment : YMPayment

/**
	Recepient account number.
 */
@property (nonatomic,strong) NSString *recepient;

/**
	Amount of money to pay(in rubles).
 */
@property (nonatomic,assign) float amount;

/**
	Comment to payment, shown to payer.
 */
@property (nonatomic,strong) NSString *comment;

/**
	Message to payment, shown to payee.
 */
@property (nonatomic,strong) NSString *message;


/**
	Create YMUserPayment object, ready for requesting.
	@param to Recepient account number.
	@param amount Amount of money to pay.
	@param comm Comment to payment.
	@param msg Message to payment.
	@returns Initialized, ready for requesting YMUserPayment object.
 */
+ (YMUserPayment*)userPaymentTo:(NSString*)to amount:(float)amount comment:(NSString*)comm message:(NSString*)msg;


@end
