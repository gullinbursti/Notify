//
//  FontAllocator.h
//  Modd
//
//  Created on 11/17/15.
//  Copyright © 2015. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FontAllocator : NSObject
+ (FontAllocator *)sharedInstance;

- (UIFont *)avenirHeavy;
- (UIFont *)cartoGothicBold;
- (UIFont *)cartoGothicBoldItalic;
- (UIFont *)cartoGothicBook;
- (UIFont *)cartoGothicBookItalic;
- (UIFont *)cartoGothicItalic;
- (UIFont *)helveticaNeueFontBold;
- (UIFont *)helveticaNeueFontBoldItalic;
- (UIFont *)helveticaNeueFontLight;
- (UIFont *)helveticaNeueFontMedium;
- (UIFont *)helveticaNeueFontRegular;
- (UIFont *)helveticaNeueFontRegularItalic;

- (NSParagraphStyle *)doubleLineSpacingParagraphStyleForFont:(UIFont *)font;
- (NSParagraphStyle *)forceLineSpacingParagraphStyle:(CGFloat)spacing forFont:(UIFont *)font;
- (NSParagraphStyle *)halfLineSpacingParagraphStyleForFont:(UIFont *)font;
- (NSParagraphStyle *)orthodoxLineSpacingParagraphStyleForFont:(UIFont *)font;
@end
