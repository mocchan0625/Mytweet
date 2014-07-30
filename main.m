//
//  main.m
//  Twicchar
//
//  Created by mocchan on 2014/06/17.
//  Copyright (c) 2014年 mocchan.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "MyUIApplication.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc,
                                 argv,
                                NSStringFromClass([MyUIApplication class]),NSStringFromClass([AppDelegate class]));
    }
}
