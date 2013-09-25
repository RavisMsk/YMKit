//
//  YMPayment.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 9/5/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDefines.h"



@interface YMPayment : NSObject

/**
	Holds payments current state.
 */
@property (nonatomic,assign) YMPaymentState state;

/**
	Debug mode payment. Means, that real transaction wont happen. Only API will work, checking the parameters, etc.
 */
@property (nonatomic,assign) BOOL debugMode;

/**
	RequestId is populated after first step of payment (requestPayment:...). You should not use this property. It will be used automatically.
 */
@property (nonatomic,strong) NSString *requestId;


@end
