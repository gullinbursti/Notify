//
//  ChannelViewController.h
//  Modd
//
//  Created on 11/17/15.
//  Copyright © 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChannelVO.h"

typedef NS_ENUM(NSUInteger, ChannelAlertViewType) {
	ChannelAlertViewTypeInvite = 0
};

@interface ChannelViewController : UIViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate>
- (id)initFromDeepLinkWithChannelName:(NSString *)channelName;
- (id)initWithChannel:(ChannelVO *)channelVO;
- (id)initWithChannel:(ChannelVO *)channelVO asTwitchUser:(NSDictionary *)twitchUser;
@end
