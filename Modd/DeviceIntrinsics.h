//
//  HONDeviceIntrinsics.h
//  Modd
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:08.
//  Copyright (c) 2014. All rights reserved.
//

extern const CGSize kScreenMult;

@interface DeviceIntrinsics : NSObject
+ (DeviceIntrinsics *)sharedInstance;

- (NSString *)uniqueIdentifierWithoutSeperators:(BOOL)noDashes;
- (NSString *)advertisingIdentifierWithoutSeperators:(BOOL)noDashes;
- (NSString *)identifierForVendorWithoutSeperators:(BOOL)noDashes;



- (BOOL)isIOS7;
- (BOOL)isIOS8;
- (BOOL)isPhoneType5s;
- (BOOL)isRetina4Inch;
- (BOOL)isPhoneType6;
- (BOOL)isPhoneType6Plus;
- (CGFloat)scaledScreenHeight;
- (CGSize)scaledScreenSize;
- (CGFloat)scaledScreenWidth;

- (NSString *)lanIPAddress;
- (NSString *)locale;
- (NSString *)modelName;
- (NSString *)deviceName;
- (NSString *)osName;
- (NSString *)osNameVersion;
- (NSString *)osVersion;

- (void)writePushToken:(NSString *)pushToken;
- (NSString *)pushToken;

- (void)writeDataPushToken:(NSData *)pushToken;
- (NSData *)dataPushToken;


- (NSDictionary *)geoLocale;
- (void)updateGeoLocale:(NSDictionary *)locale;

- (BOOL)hasNetwork;

- (NSMutableString *)hmacToken;

- (void)writePhoneNumber:(NSString *)phoneNumber;
- (NSString *)phoneNumber;
- (NSString *)areaCodeFromPhoneNumber;
@end
