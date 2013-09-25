//
//  YMViewController.h
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMViewController : UIViewController

@property (nonatomic,retain) IBOutlet UILabel *account;
@property (nonatomic,retain) IBOutlet UILabel *balance;
@property (nonatomic,retain) IBOutlet UIButton *btn;
@property (nonatomic,retain) IBOutlet UIButton *refresh;
@property (nonatomic,retain) IBOutlet UIButton *testPaymentBtn;

-(IBAction)authBtn:(id)sender;
-(IBAction)refreshBtnClick:(id)sender;
-(IBAction)quitApp:(id)sender;
-(IBAction)testPaymentClick:(id)sender;

@end
