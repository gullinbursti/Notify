//
//  NSCharacterSet+Modd.h
//  Modd
//
//  Created on 11/24/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSCharacterSet (Modd)
+ (instancetype)invalidCharacterSet;
+ (instancetype)invalidCharacterSetWithLetters;
+ (instancetype)invalidCharacterSetWithNumbers;
+ (instancetype)invalidCharacterSetWithPunctuation;

+ (instancetype)characterSetCombiningStringChars:(NSString *)appendChars;
+ (instancetype)characterSetExcludingStringChars:(NSString *)dropChars;


- (NSCharacterSet *)addChars:(NSString *)appendChars;
- (NSCharacterSet *)dropChars:(NSString *)excludeChars;

- (NSArray *)arrayFromCharacterSet;
- (NSString *)stringFromCharacterSet;

@end
