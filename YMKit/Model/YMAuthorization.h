//
//  YMAuthorization.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMAuthorization : NSObject

@property (nonatomic,strong) NSString *clientId;
@property (nonatomic,strong) NSArray *scopes;
@property (nonatomic,strong) NSURL *landingPage;

@end
