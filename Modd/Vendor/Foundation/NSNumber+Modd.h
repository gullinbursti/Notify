//
//  NSNumber+Modd.h
//  Modd
//
//  Created on 1/29/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSNumber (Modd)

+ (instancetype)randomIntegerWithinRange:(NSRange)range;

- (NSUInteger)factorial;
- (NSUInteger)gcfWithNumber:(NSInteger)number;
- (BOOL)isEven;
- (BOOL)isPrime;
- (NSUInteger)lcmWithNumber:(NSInteger)number;
- (NSNumber *)reverseNumber;
- (NSUInteger)sumOfDigits;
@end
