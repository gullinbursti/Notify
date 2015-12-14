//
//  FontAllocator.m
//  Modd
//
//  Created on 11/17/15.
//  Copyright © 2015. All rights reserved.
//

#import "FontAllocator.h"

@implementation FontAllocator
static FontAllocator *sharedInstance = nil;

+ (FontAllocator *)sharedInstance {
	static FontAllocator *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
		
	}
	return (self);
}


- (UIFont *)avenirHeavy {
	return ([UIFont fontWithName:@"Avenir-Heavy" size:24.0]);
}

- (UIFont *)cartoGothicBold {
	return ([UIFont fontWithName:@"CartoGothicStd-Bold" size:24.0]);
}

- (UIFont *)cartoGothicBoldItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-BoldItalic" size:24.0]);
}

- (UIFont *)cartoGothicBook {
	return ([UIFont fontWithName:@"CartoGothicStd-Book" size:24.0]);
}

- (UIFont *)cartoGothicBookItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-BookItalic" size:24.0]);
}

- (UIFont *)cartoGothicItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-Italic" size:24.0]);
}


- (UIFont *)helveticaNeueFontBold {
	return ([UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]);
}

- (UIFont *)helveticaNeueFontBoldItalic {
	return ([UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0]);
}

- (UIFont *)helveticaNeueFontLight {
	return ([UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]);
}

- (UIFont *)helveticaNeueFontMedium {
	return ([UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]);
}

- (UIFont *)helveticaNeueFontRegular {
	return ([UIFont fontWithName:@"HelveticaNeue" size:18.0]);
}

- (UIFont *)helveticaNeueFontRegularItalic {
	return ([UIFont fontWithName:@"HelveticaNeue-Italic" size:18.0]);
}


- (NSParagraphStyle *)doubleLineSpacingParagraphStyleForFont:(UIFont *)font {
	NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = font.lineHeight;
	paragraphStyle.maximumLineHeight *= 2.0;
	
	return (paragraphStyle);
}

- (NSParagraphStyle *)forceLineSpacingParagraphStyle:(CGFloat)spacing forFont:(UIFont *)font {
	NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = font.lineHeight + spacing;
	
	return (paragraphStyle);
}

- (NSParagraphStyle *)halfLineSpacingParagraphStyleForFont:(UIFont *)font {
	NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = font.capHeight + font.descender;
	paragraphStyle.maximumLineHeight += font.ascender;
	
	return (paragraphStyle);
}

- (NSParagraphStyle *)orthodoxLineSpacingParagraphStyleForFont:(UIFont *)font {
	NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = font.lineHeight;
	//	paragraphStyle.maximumLineHeight *= 0.5;
	
	return (paragraphStyle);
}


@end
