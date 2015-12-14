//
//  UIScrollView+Modd.h
//  Modd
//
//  Created on 1/29/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Modd)
- (BOOL)isAtContentBottom;
- (BOOL)isAtContentLeft;
- (BOOL)isAtContentRight;
- (BOOL)isAtContentTop;
- (CGFloat)scrollPosition;
@end
