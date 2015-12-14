//
//  StaticInlines.h
//  Modd
//
//  Created on 11/4/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <UIKit/UIKit.h>


/* Definition of `MODD_INLINE'. */

#if !defined(MODD_INLINE)
# if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define MODD_INLINE static inline
# elif defined(__cplusplus)
#  define MODD_INLINE static inline
# elif defined(__GNUC__)
#  define MODD_INLINE static __inline__
# else
#  define MODD_INLINE static
# endif
#endif



#pragma mark - Logging


#pragma mark - CGAffineTransform

MODD_INLINE CGAffineTransform
CGAffineTransformMakeScalePercent(CGRect frame, CGFloat percent)
{
	CGSize perSize = CGSizeMake(frame.size.width * percent, frame.size.height * percent);
	CGSize scaleSize = CGSizeMake(perSize.width / frame.size.width, perSize.width / frame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(frame) - CGRectGetMidX(CGRectInset(frame, perSize.width, perSize.height)), CGRectGetMidY(frame) - CGRectGetMidY(CGRectInset(frame, perSize.width, perSize.height)));
	
	CGAffineTransform t;
	t.a = scaleSize.width;
	t.b = 0.0;
	t.c = 0.0;
	t.d = scaleSize.height;
	t.tx = offsetPt.x;
	t.ty = offsetPt.y;
	return (t);
}

MODD_INLINE CGAffineTransform
CGAffineTransformMakeNormal()
{
	CGAffineTransform t;
	t.a = 1.0;
	t.b = 0.0;
	t.c = 0.0;
	t.d = 1.0;
	t.tx = 0.0;
	t.ty = 0.0;
	return t;
}


#pragma mark - CGFloat

MODD_INLINE CGFloat
CGPointDistance(CGPoint pt1, CGPoint pt2)
{
	CGFloat dist = sqrt(pow((pt1.x - pt2.x), 2) + pow((pt1.y - pt2.y), 2));
	return dist;
}


#pragma mark - CGPoint

MODD_INLINE CGPoint
CGPointAdd(CGPoint pt1, CGPoint pt2)
{
	CGPoint summatedPoint;
	summatedPoint = CGPointMake(pt1.x + pt2.x, pt1.y + pt2.y);
	return summatedPoint;
}

MODD_INLINE CGPoint
CGPointDivide(CGPoint pt1, CGPoint pt2)
{
	CGPoint summatedPoint;
	summatedPoint = CGPointMake(pt1.x / pt2.x, pt1.y / pt2.y);
	return summatedPoint;
}

MODD_INLINE CGPoint
CGPointMultiply(CGPoint pt1, CGPoint pt2)
{
	CGPoint summatedPoint;
	summatedPoint = CGPointMake(pt1.x * pt2.x, pt1.y * pt2.y);
	return summatedPoint;
}

MODD_INLINE CGPoint
CGPointMultiplyFactor(CGPoint pt1, CGFloat factor)
{
	CGPoint summatedPoint;
	summatedPoint = CGPointMake(pt1.x * factor, pt1.y * factor);
	return summatedPoint;
}

MODD_INLINE CGPoint
CGPointRotatedAroundPoint(CGPoint point, CGPoint pivot, CGFloat degrees)
{
	CGAffineTransform translation, rotation;
	translation	= CGAffineTransformMakeTranslation(-pivot.x, -pivot.y);
	point		= CGPointApplyAffineTransform(point, translation);
	rotation	= CGAffineTransformMakeRotation(degrees * (M_PI / 180.0));
	point		= CGPointApplyAffineTransform(point, rotation);
	translation	= CGAffineTransformMakeTranslation(pivot.x, pivot.y);
	point		= CGPointApplyAffineTransform(point, translation);
	return point;
}


#pragma mark - CGRect


MODD_INLINE CGPoint
CGRectBottomLeftPoint(CGRect rect)
{
	return CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
}

MODD_INLINE CGPoint
CGRectBottomRightPoint(CGRect rect)
{
	return CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
}

MODD_INLINE CGPoint
CGRectCenterPoint(CGRect rect)
{
	CGPoint centerPoint = CGPointZero;
	centerPoint.x = CGRectGetMidX(rect);
	centerPoint.y = CGRectGetMidY(rect);
	return centerPoint;
}

MODD_INLINE CGRect
CGRectExtendSize(CGRect rect, CGSize size)
{
	CGRect resizeRect;
	resizeRect.origin.x = rect.origin.x;
	resizeRect.origin.y = rect.origin.y;
	resizeRect.size.width = rect.size.width + size.width;
	resizeRect.size.height = rect.size.height + size.height;
	return resizeRect;
}

MODD_INLINE CGRect
CGRectExtendHeight(CGRect rect, CGFloat length)
{
	CGRect resizeRect = CGRectExtendSize(rect, CGSizeMake(0.0, length));
	return resizeRect;
}

MODD_INLINE CGRect
CGRectExtendWidth(CGRect rect, CGFloat length)
{
	CGRect resizeRect = CGRectExtendSize(rect, CGSizeMake(length, 0.0));
	return resizeRect;
}

MODD_INLINE CGRect
CGRectFactorSQResize(CGRect rect, CGFloat factor)
{
	CGRect resizeRect;
	resizeRect.origin.x = rect.origin.x;
	resizeRect.origin.y = rect.origin.y;
	resizeRect.size.width = rect.size.width * factor;
	resizeRect.size.height = rect.size.height * factor;
	return resizeRect;
}

MODD_INLINE CGRect
CGRectFactorResize(CGRect rect, CGPoint factor)
{
	CGRect resizeRect;
	resizeRect.origin.x = rect.origin.x;
	resizeRect.origin.y = rect.origin.y;
	resizeRect.size.width = rect.size.width * factor.x;
	resizeRect.size.height = rect.size.height * factor.y;
	return resizeRect;
}

MODD_INLINE CGRect
CGRectFactorResizeX(CGRect rect, CGFloat factor)
{
	CGRect resizeRect = CGRectFactorResize(rect, CGPointMake(factor, 1.0));
	return resizeRect;
}

MODD_INLINE CGRect
CGRectFactorResizeY(CGRect rect, CGFloat factor)
{
	CGRect resizeRect = CGRectFactorResize(rect, CGPointMake(1.0, factor));
	return resizeRect;
}

MODD_INLINE CGRect
CGRectFromSize(CGSize size)
{
	CGRect rect;
	rect.origin.x = 0.0;
	rect.origin.y = 0.0;
	rect.size.width = size.width;
	rect.size.height = size.height;
	return rect;
}

MODD_INLINE CGRect
CGRectOffsetX(CGRect rect, CGFloat amount)
{
	CGRect transRect = CGRectOffset(rect, amount, 0.0);
	return (transRect);
}

MODD_INLINE CGRect
CGRectOffsetY(CGRect rect, CGFloat amount)
{
	CGRect transRect = CGRectOffset(rect, 0.0, amount);
	return (transRect);
}

MODD_INLINE CGRect
CGRectResize(CGRect rect, CGSize size)
{
	CGRect resizeRect;
	resizeRect.origin.x = rect.origin.x;
	resizeRect.origin.y = rect.origin.y;
	resizeRect.size.width = size.width;
	resizeRect.size.height = size.height;
	return resizeRect;
}

MODD_INLINE CGRect
CGRectResizeHeight(CGRect rect, CGFloat newHeight)
{
	CGRect resizeRect = CGRectResize(rect, CGSizeMake(rect.size.width, newHeight));
	return resizeRect;
}

MODD_INLINE CGRect
CGRectResizeWidth(CGRect rect, CGFloat newWidth)
{
	CGRect resizeRect = CGRectResize(rect, CGSizeMake(newWidth, rect.size.height));
	return resizeRect;
}

MODD_INLINE CGPoint
CGRectTopLeftPoint(CGRect rect)
{
	return CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
}

MODD_INLINE CGPoint
CGRectTopRightPoint(CGRect rect)
{
	return CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
}

MODD_INLINE CGRect
CGRectTranslate(CGRect rect, CGPoint pos)
{
	CGRect transRect;
	transRect.origin.x = pos.x;
	transRect.origin.y = pos.y;
	transRect.size.width = rect.size.width;
	transRect.size.height = rect.size.height;
	
	return (transRect);
}

MODD_INLINE CGRect
CGRectTranslateX(CGRect rect, CGFloat pos)
{
	CGRect transRect = CGRectTranslate(rect, CGPointMake(pos, rect.origin.y));
	return (transRect);
}

MODD_INLINE CGRect
CGRectTranslateY(CGRect rect, CGFloat pos)
{
	CGRect transRect = CGRectTranslate(rect, CGPointMake(rect.origin.x, pos));
	return (transRect);
}


#pragma mark - CGSize

MODD_INLINE CGSize
CGSizeAdd(CGSize size, CGSize amount)
{
	CGSize adjSize;
	adjSize.width = size.width + amount.width;
	adjSize.height = size.height + amount.height;
	return adjSize;
}

MODD_INLINE CGSize
CGSizeExpand(CGSize size, CGSize amount)
{
	CGSize adjSize;
	adjSize.width = size.width + amount.width;
	adjSize.height = size.height + amount.height;
	return adjSize;
}

MODD_INLINE CGSize
CGSizeMult(CGSize size, CGFloat mult)
{
	CGSize adjSize;
	adjSize.width = size.width * mult;
	adjSize.height = size.height * mult;
	return adjSize;
}

MODD_INLINE CGSize
CGSizeNegate(CGSize size)
{
	CGSize negSize;
	negSize.width = size.width * -1;
	negSize.height = size.height * -1;
	return negSize;
}

MODD_INLINE CGSize
CGSizeSubtract(CGSize size, CGSize amount)
{
	CGSize adjSize = CGSizeAdd(size, CGSizeNegate(size));
	return adjSize;
}


MODD_INLINE CGSize
CGSizeFromLength(CGFloat length)
{
	CGSize size;
	size.width = length;
	size.height = length;
	return size;
}


#pragma mark - NSString

inline unsigned long long
__unistrlen(unichar *chars)
{
	unsigned long long length = 0llu;
	if(NULL == chars) return length;
	
	while(NULL != &chars[length])
		length++;
	
	return length;
}


MODD_INLINE NSString*
NSStringFromABAuthorizationStatus(ABAuthorizationStatus val)
{
	NSString *string = (val == kABAuthorizationStatusNotDetermined) ? @"NotDetermined" : (val == kABAuthorizationStatusDenied) ? @"Denied" : (val == kABAuthorizationStatusAuthorized) ? @"Authorized" : @"UNKNOWN";
	return string;
}

MODD_INLINE NSString*
NSStringFromBOOL(BOOL val)
{
	NSString *string = (val) ? @"YES" : @"NO";
	return string;
}

MODD_INLINE NSString*
NSStringFromCGFloat(CGFloat val)
{
	NSString *string = [NSString stringWithFormat:@"%f", (float)val];
	return string;
}

MODD_INLINE NSString*
NSStringFromCLAuthorizationStatus(CLAuthorizationStatus val)
{
	NSString *string = (val == kCLAuthorizationStatusAuthorized) ? @"Authorized" : (val == kCLAuthorizationStatusAuthorizedAlways) ? @"AuthorizedAlways" : (val == kCLAuthorizationStatusAuthorizedWhenInUse) ? @"AuthorizedWhenInUse" : (val == kCLAuthorizationStatusDenied) ? @"Denied" : (val == kCLAuthorizationStatusRestricted) ? @"Restricted" : (val == kCLAuthorizationStatusNotDetermined) ? @"NotDetermined" : @"UNKNOWN";
	return string;
}

MODD_INLINE NSString*
NSStringFromCLLocation(CLLocation *val)
{
	NSString *string = [NSString stringWithFormat:@"(%.04f, %.04f)", val.coordinate.longitude, val.coordinate.latitude];
	return string;
}

MODD_INLINE NSString*
NSStringFromDouble(double val)
{
	NSString *string = NSStringFromCGFloat((CGFloat)val);
	return string;
}

MODD_INLINE NSString*
NSStringFromFloat(float val)
{
	NSString *string = NSStringFromCGFloat((CGFloat)val);
	return string;
}

MODD_INLINE NSString*
NSStringFromHex(unichar *val)
{
	NSString *string = [NSString stringWithCharacters:val
											   length:__unistrlen(val)];
	return string;
}


MODD_INLINE NSString*
NSStringFromInt(int val)
{
	NSString *string = [NSString stringWithFormat:@"%d", val];
	return string;
}

MODD_INLINE NSString*
NSStringFromNSDictionary(NSDictionary *val)
{
	NSString *string = [NSString stringWithFormat:@"%@", val];
	return string;
}

MODD_INLINE NSString*
NSStringFromNSIndexPath(NSIndexPath *val)
{
	NSString *string = [NSString stringWithFormat:@"(%ld × %ld)", (long)val.section, (long)val.row];
	return string;
}

MODD_INLINE NSString*
NSStringFromNSNumber(NSNumber *val, int precision)
{
	if (precision == 0)
		return NSStringFromInt([val intValue]);
	
	NSString *string = [NSString stringWithFormat:[NSString stringWithFormat:@"%%.0%df", precision], val];
	return string;
}

MODD_INLINE NSString*
NSStringFromUIGestureRecognizerState(UIGestureRecognizerState val)
{
//	NSString *string = (val == UIGestureRecognizerStatePossible) ? @"Possible" : (val == UIGestureRecognizerStateBegan) ? @"Began" : (val == UIGestureRecognizerStateChanged) ? @"Changed" : (val == UIGestureRecognizerStateEnded) ? @"Ended" : (val == UIGestureRecognizerStateCancelled) ? @"Canceled" : (val == UIGestureRecognizerStateFailed) ? @"Failed" : (val == UIGestureRecognizerStateRecognized) ? @"Recognized" : @"UNKNOWN";
	NSString *string = (val == UIGestureRecognizerStatePossible) ? @"Possible" : (val == UIGestureRecognizerStateBegan) ? @"Began" : (val == UIGestureRecognizerStateEnded) ? @"Ended" : (val == UIGestureRecognizerStateCancelled) ? @"Canceled" : (val == UIGestureRecognizerStateFailed) ? @"Failed" : (val == UIGestureRecognizerStateRecognized) ? @"Recognized" : @"UNKNOWN";
	return (string);
}

MODD_INLINE NSString*
NSStringFromUIImageOrientation(UIImageOrientation val)
{
	NSString *string = (val == UIImageOrientationUp) ? @"Up" : (val == UIImageOrientationDown) ? @"Down" : (val == UIImageOrientationLeft) ? @"Left" : (val == UIImageOrientationRight) ? @"Right" : (val == UIImageOrientationUpMirrored) ? @"UpMirrored" : (val == UIImageOrientationDownMirrored) ? @"DownMirrored" : (val == UIImageOrientationLeftMirrored) ? @"LeftMirrored" : (val == UIImageOrientationRightMirrored) ? @"RightMirrored" : @"UNKNOWN";
	return string;
}
