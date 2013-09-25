//
//  YMShopPayment.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 9/5/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMPayment.h"
#import "YMDefines.h"

@interface YMShopPayment : YMPayment

/**
	Payment pattern id of your shop.
 */
@property (nonatomic,retain) NSString *patternId;

/**
	Custom parameters, required for your pattern.
 */
@property (nonatomic,retain) NSDictionary *parameters;


/**
	Creates YMShopPayment object ready for payment requesting.
	@param pattern Matches pattern_id in actual request. It is payment pattern id of your shop.
	@param params Dictionary of parameters, required for pattern of your shop.
	@returns Initialized and ready for request YMShopPayment.
 */
+ (YMShopPayment*)shopPaymentWithPatternId:(NSString*)pattern patternParameters:(NSDictionary*)params;


@end
