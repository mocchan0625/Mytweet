//
//  WebViewController.h
//  Twicchar
//
//  Created by mocchan on 2014/06/21.
//  Copyright (c) 2014年 mocchan.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) NSURL *openURL;

@end
