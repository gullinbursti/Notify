//
//  UILabel+Modd.h
//  Modd
//
//  Created 06/16/2014.
//  Copyright (c) 2014. All rights reserved.
//


@interface UILabel (Modd)
- (CGRect)boundingRectForAllCharacters;
- (CGRect)boundingRectForCharacterRange:(NSRange)range;
- (CGRect)boundingRectForSubstring:(NSString *)substring;
- (int)numberOfLinesNeeded;
- (void)resizeFrameForText;
- (void)resizeWidthUsingCaption:(NSString *)caption boundedBySize:(CGSize)maxSize;
- (CGSize)sizeForText;

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setFont:(UIFont *)font range:(NSRange)range;

@end
