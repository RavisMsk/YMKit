//
//  YMShopPayment.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 9/5/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMShopPayment.h"

@interface YMShopPayment ()

@end

@implementation YMShopPayment

+ (YMShopPayment*)shopPaymentWithPatternId:(NSString *)pattern patternParameters:(NSDictionary *)params{
    YMShopPayment *payment=[[YMShopPayment alloc] init];
    payment.patternId=pattern;
    payment.parameters=params;
    return payment;
}

-(id)init{
    self=[super init];
    if (self){
        
    }
    return self;
}

@end
