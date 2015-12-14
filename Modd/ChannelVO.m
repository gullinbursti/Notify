//
//  ChannelVO.m
//  Modd
//
//  Created on 11/17/15.
//  Copyright © 2015. All rights reserved.
//

#import "ChannelVO.h"

@implementation ChannelVO
+ (ChannelVO *)channelWithDictionary:(NSDictionary *)dictionary {
	ChannelVO *vo = [[ChannelVO alloc] init];
	
	vo.dictionary = dictionary;
	
	return (vo);
}
@end
