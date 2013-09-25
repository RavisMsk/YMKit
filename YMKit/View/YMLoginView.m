//
//  YMLoginView.m
//  YandexMoneyAPI
//
//  Created by Nikita Anisimov on 8/28/13.
//  Copyright (c) 2013 Nikita Anisimov. All rights reserved.
//

#import "YMLoginView.h"
#import "YMAuthorization.h"
//#import "YMStatusBar.h"
#import <QuartzCore/QuartzCore.h>

static float const kYMLoginViewVerticalOffset=45.0f;
static float const kYMLoginViewHorizontalOffset=25.0f;

@interface YMLoginView () <UIWebViewDelegate>

@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,retain) UIButton *closeBtn;
@property (nonatomic,retain) UIView *backGround;
@property (nonatomic,retain) UIActivityIndicatorView *indic;

@property (nonatomic,retain) NSString *authParams;

@end

@implementation YMLoginView{
    YMLoginSuccessHandler _handler;
}

#pragma mark - Lifecycle

- (id)init{
    self=[super initWithFrame:CGRectZero];
    if (self){
        _handler=nil;
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIImage *closeImg=[UIImage imageNamed:@"close.png"];
        _closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:closeImg forState:UIControlStateNormal];
        [_closeBtn setBackgroundColor:[UIColor clearColor]];
        [_closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
        
        _backGround=[[UIView alloc]init];
        [_backGround setBackgroundColor:[UIColor blackColor]];
        [_backGround setAlpha:0.0f];
        [self addSubview:_backGround];
        
        _webView=[[UIWebView alloc]initWithFrame:CGRectMake(kYMLoginViewHorizontalOffset,kYMLoginViewVerticalOffset,320-2*kYMLoginViewHorizontalOffset,480-2*kYMLoginViewVerticalOffset)];
        [_webView setDelegate:self];
        [_webView setAlpha:0.0f];
        [_webView setScalesPageToFit:NO];
        
        [self addSubview:_webView];
    }
    return self;
}

- (id)initWithAuthorization:(YMAuthorization *)auth{
    self=[self init];
    if (self){
        //serialize auth params right here into member variable
        NSMutableString *params=[NSMutableString string];
        [params appendFormat:@"client_id=%@&response_type=%@&redirect_uri=%@&scope=%@",auth.clientId,kYMLoginViewResponseType,auth.landingPage,[auth.scopes componentsJoinedByString:@" "]];
        self.authParams=params;
    }
    return self;
}

#pragma mark - Usage

- (void)showLoginDialogWithSuccessBlock:(YMLoginSuccessHandler)handler{
    //Set completion handler, because work with this view undetermined amount of time
    _handler=handler;
    //Load auth page on _webView
    [self loadAuthorizationPage];
    //Present this class to main app window
    UIWindow *window=[[UIApplication sharedApplication] keyWindow];
    if (!window)
        window=[[[UIApplication sharedApplication] windows]objectAtIndex:0];
    [self setFrame:window.frame];
    CALayer *webLayer=[_webView layer];
    [webLayer setCornerRadius:5.0f];
    [webLayer setBorderWidth:2.0f];
    [webLayer setMasksToBounds:YES];
    [_backGround setFrame:window.frame];
    [_closeBtn setFrame:CGRectMake(320-kYMLoginViewHorizontalOffset-16, kYMLoginViewVerticalOffset-10, 29, 29)];
    [_closeBtn setAlpha:0.0f];
    [self addSubview:_closeBtn];
    [window addSubview:self];
    [UIView animateWithDuration:0.5f animations:^{
        _backGround.alpha=0.5f;
        _webView.alpha=1.0f;
        _closeBtn.alpha=1.0f;
    }];
}

- (void)hideLoginDialog{
    _handler=nil;
//    [YMStatusBar setParentView:nil];
    [UIView animateWithDuration:0.5f animations:^{
        [_backGround setAlpha:0.0f];
        [_webView setAlpha:0.0f];
        [_closeBtn setAlpha:0.0f];
    }completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

- (void)loadAuthorizationPage{
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self.authParams dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    [request setURL:[NSURL URLWithString:@"https://m.sp-money.yandex.ru/oauth/authorize"]];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebView delegates

- (void)webViewDidStartLoad:(UIWebView *)webView{
//    [YMStatusBar showWithProcessText:@"Loading..." indicationAnimating:YES finishText:@"Ok."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *url=webView.request.URL.absoluteString;
//    [YMStatusBar finish];
    if ([url rangeOfString:@"cb?code="].location!=NSNotFound){
        NSString *tempToken=[url substringFromIndex:[url rangeOfString:@"cb?code="].location+8];
        [self succeded:tempToken];
    }else if ([url rangeOfString:@"herokuapp"].location!=NSNotFound){
        [self closeClick];
    }
    
    [_webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"var result = '';"
      "var viewport = null;"
      "var content = null;"
      "var document_head = document.getElementsByTagName( 'head' )[0];"
      "var child = document_head.firstChild;"
      "while ( child )"
      "{"
      " if ( null == viewport && child.nodeType == 1 && child.nodeName == 'META' && child.getAttribute( 'name' ) == 'viewport' )"
      "   {"
      "     viewport = child;"
      "     viewport.setAttribute( 'content' , 'width=270;initial-scale=1.0' );"
      "     result = 'fixed meta tag';"
      " }"
      " child = child.nextSibling;"
      "}"
      "if (null == viewport)"
      "{"
      " var meta = document.createElement( 'meta' );"
      " meta.setAttribute( 'name' , 'viewport' );"
      " meta.setAttribute( 'content' , 'width=device-width;initial-scale=1.0' );"
      " document_head.appendChild( meta );"
      " result = 'added meta tag';"
      "}"
      ]
     ];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.absoluteString rangeOfString:@"sp-money"].location != NSNotFound || [request.URL.absoluteString rangeOfString:@"yandex"].location != NSNotFound || [request.URL.absoluteString rangeOfString:@"herokuapp"].location != NSNotFound)
        return YES;
    return NO;
}

#pragma mark - Delegating

- (void)succeded:(NSString*)tempToken{
    if (_handler)
        _handler(tempToken,nil);
    [self hideLoginDialog];
}

- (void)closeClick{
    if (_handler){
        NSError *error=[NSError errorWithDomain:kYMKitErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:@"User closed authorization dialog."}];
        _handler(nil,error);
    }
    [self hideLoginDialog];
}

@end
