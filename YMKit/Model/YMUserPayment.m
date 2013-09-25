//
//  YMUserPayment.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 9/5/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMUserPayment.h"

@interface YMUserPayment ()

@end

@implementation YMUserPayment

+ (YMUserPayment *)userPaymentTo:(NSString *)to amount:(float)amount comment:(NSString *)comm message:(NSString *)msg{
    YMUserPayment *payment=[[YMUserPayment alloc] init];
    payment.recepient=to;
    payment.amount=amount;
    payment.comment=comm;
    payment.message=msg;
    return payment;
}

- (id)init{
    self=[super init];
    if (self){
        
    }
    return self;
}

@end
