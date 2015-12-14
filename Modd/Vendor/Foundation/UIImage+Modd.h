//
//  NSDate+Modd.h
//  Modd
//
//  Created on 11/4/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ColorMask) {
	ColorMaskRed   = 1,
	ColorMaskGreen = 2,
	ColorMaskBlue  = 4
};

@interface UIImage (Modd)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

- (UIImage *)imageWithMosaic:(CGFloat)scale;
- (UIImage *)mirrorImage;

- (UIImage *)fixOrientation;

- (UIImage *)convertToGreyscale;

-(unsigned char*) grayscalePixels;
-(unsigned char*) rgbaPixels;
@end