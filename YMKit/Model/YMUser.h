//
//  YMUser.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDefines.h"

@interface YMUser : NSObject

/**
	Holds account number.
 */
@property (nonatomic,retain) NSString *account;

/**
	Holds balance of user.
 */
@property (nonatomic,retain) NSDecimalNumber *balance;

/**
	Token is read-only property with custom getter.
 */
@property (nonatomic,strong,readonly) NSString *token;


/**
	Currently authorized user.
	@returns YMUser instance, holding all users data.
 */
+ (instancetype)currentUser;

/**
	Sets new current user.
	@param user YMUser object, representing new user. If nil is sent, data will be wiped and no credentials left.
 */
+ (void)setCurrentUser:(YMUser*)user;

/**
	Creates YMUser object from dictionary.
	@param dict Dictionary, received from Y.Money API.
	@returns Initialized YMUser object.
 */
+ (instancetype)objectWithDictionary:(NSDictionary*)dict;

@end
