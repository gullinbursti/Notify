//
//  ChannelVO.h
//  Modd
//
//  Created on 11/17/15.
//  Copyright © 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelVO : NSObject
+ (ChannelVO *)channelWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@end
