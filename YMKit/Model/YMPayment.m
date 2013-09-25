//
//  YMPayment.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 9/5/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMPayment.h"

@interface YMPayment ()

@end

@implementation YMPayment

- (id)init{
    self=[super init];
    if (self){
        self.state=paymentIdle;
        self.debugMode=0;
    }
    return self;
}

@end
