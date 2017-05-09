//
//  MyWebViewController.m
//  HotUpdatedTest
//
//  Created by 张旭 on 17/5/9.
//  Copyright © 2017年 ZX. All rights reserved.
//

#import "MyWebViewController.h"
#import "TWUpdateSDK.h"

@interface MyWebViewController ()<UIWebViewDelegate> {
    UIWebView *webview;
}

@end

@implementation MyWebViewController

- (void)viewDidLoad {
    webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webview];
    
    NSString *filePath = [[TWUpdateSDK instance] getJSRootDirectory];
    NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:filePath];
    
    // 例如你有一个Url为：http://10.0.0.122:8080/dist/reservation.html 然后只需要把 "/dist/reservation" 截取出来作为 htmlName 就行了，这里没做测试，只是告诉大家怎么用。
    
    NSString *htmlName = @"/dist/reservation";
    NSString *path = [[NSBundle mainBundle] pathForResource:htmlName ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [webview loadHTMLString:html baseURL:baseURL];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}



@end
