//
//  UIViewController+Modd.h
//  Modd
//
//  Created on 3/15/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Modd)
+ (UIViewController *)findBestViewController:(UIViewController *)vc;
+ (UIViewController *)currentViewController;
@end
