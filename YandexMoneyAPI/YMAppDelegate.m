//
//  YMAppDelegate.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMAppDelegate.h"

#import "YMViewController.h"

#warning Dont forget to set this for testing!
static NSString * const kYMTestingClientId=@"";

@implementation YMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //Yandex money setup
    YMKit *kit=[YMKit sharedInstance];
    //I'll give you my example landing page, its on heroku, just one page, giving this client ability to receive token
    [kit setAppClientId:kYMTestingClientId scopes:@[@"account-info",@"payment-p2p"] authorizationLandingPagePath:[NSURL URLWithString:@"http://warm-thicket-1611.herokuapp.com/cb"]];
    _yandex=kit;
    // Override point for customization after application launch.
    self.viewController = [[YMViewController alloc] initWithNibName:@"YMViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
