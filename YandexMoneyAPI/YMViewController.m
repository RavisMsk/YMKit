//
//  YMViewController.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMViewController.h"
#import "YMAppDelegate.h"
#import "YMUser.h"
#import "YMUserPayment.h"
#import "YMShopPayment.h"

#import "SVProgressHUD.h"

#define YMKIT [(YMAppDelegate*)[[UIApplication sharedApplication] delegate] yandex]

#warning This has to be set for testing!
static NSString * const kYMUserTestingRecepient=@"";
static NSString * const kYMShopTestingPattern=@"";

@interface YMViewController () <UIActionSheetDelegate>
- (void)testPaymentOneStep:(BOOL)oneStep;
@end

@implementation YMViewController

- (void)quitApp:(id)sender{
    exit(0);
}

- (void)testPaymentClick:(id)sender{
    UIActionSheet *steps=[[UIActionSheet alloc] initWithTitle:@"1-step or 2-step?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1-step", @"2-steps", nil];
    [steps showInView:self.view];
}

- (void)testPaymentOneStep:(BOOL)oneStep{
    YMPayment *payment=nil;
    payment=[YMUserPayment userPaymentTo:kYMUserTestingRecepient
                                             amount:10.0
                                            comment:@"Тестовый платеж"
                                            message:@"Тестовый платеж"];
//    payment=[YMShopPayment shopPaymentWithPatternId:kYMShopTestingPattern
//                                             patternParameters:@{}];
    payment.debugMode=YES;
    [SVProgressHUD showWithStatus:@"Paying..." maskType:SVProgressHUDMaskTypeBlack];
    [YMKIT requestPayment:payment withHandler:^(NSError *error){
        if (!error){
            if (!oneStep){
                [YMKIT processPayment:payment withHandler:^(NSError *error){
                    if (!error){
                        [SVProgressHUD showSuccessWithStatus:@"Done!"];
                    }else{
                        NSLog(@"Handler = %@", error);
                        [SVProgressHUD showErrorWithStatus:@"Error"];
                    }
                }];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Done!"];
            }
        }else{
            NSLog(@"Handler = %@", error);
            if ([error.localizedFailureReason isEqualToString:@"not_enough_funds"])
                [SVProgressHUD showErrorWithStatus:@"Not enough funds"];
            else
                [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }immediateProcess:oneStep];
}

- (void)refreshBtnClick:(id)sender{
    //just re-fetch user again
    [SVProgressHUD showWithStatus:@"Refreshing..." maskType:SVProgressHUDMaskTypeGradient];
    [YMKIT getCurrentUserWithHandler:^(id object, NSError *error){
        if (error){
            NSLog(@"Account-info fetch error: %@", error);
            [SVProgressHUD showErrorWithStatus:@"Couldn't re-fetch data."];
        }else{
            //From now on refreshed account-info is at YMUser currentUser
            YMUser *user=(YMUser*)object;//same as [YMUser currentUser] now
            self.account.text=user.account;
            self.balance.text=user.balance.stringValue;
            [self refreshBtn];
            [SVProgressHUD showSuccessWithStatus:@"Done!"];
        }
    }];
}

- (void)refreshBtn{
    if ([YMUser currentUser]){
        [self.btn setTitle:@"Revoke" forState:UIControlStateNormal];
        self.refresh.enabled=YES;
        self.testPaymentBtn.enabled=YES;
    }else{
        [self.btn setTitle:@"Authorize" forState:UIControlStateNormal];
        self.refresh.enabled=NO;
        self.testPaymentBtn.enabled=NO;
    }
}

- (void)authBtn:(id)sender{
    if ([YMUser currentUser]){
        [SVProgressHUD showWithStatus:@"Revoking token..." maskType:SVProgressHUDMaskTypeGradient];
        [YMKIT revokeAccess:^(NSError *error){
            if (error){
                NSLog(@"Revoke error: %@", error);
                [SVProgressHUD showErrorWithStatus:@"Error revoking token."];
            }else{
                self.account.text=@"";
                self.balance.text=@"";
                [self refreshBtn];
                [SVProgressHUD showSuccessWithStatus:@"Token revoked!"];
            }
        }];
    }else{
        [YMKIT authorize:^(NSError *error){
            if (error){
                NSLog(@"Auth error: %@",error);
                [SVProgressHUD showErrorWithStatus:@"Auth error"];
            }
            else{
                NSLog(@"Auth error = nil. Auth worked ok.");
                YMUser *user=[YMUser currentUser];
                self.account.text=user.account;
                self.balance.text=user.balance.stringValue;
                [self refreshBtn];
                [SVProgressHUD showSuccessWithStatus:@"Done!"];
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([YMUser currentUser]){
        NSLog(@"CurrentUser exists at start.");
        YMUser *user=[YMUser currentUser];
        self.account.text=user.account;
        self.balance.text=user.balance.stringValue;
    }
    [self refreshBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self testPaymentOneStep:YES];
            break;
        case 1:
            [self testPaymentOneStep:NO];
            break;
        default:
            break;
    }
}

@end
