//
//  AuthViewController.h
//  Modd
//
//  Created on 12/1/15.
//  Copyright © 2015. All rights reserved.
//

#import "WebViewController.h"

@class AuthViewController;
@protocol AuthViewControllerDelegate <NSObject>
- (void)authViewController:(AuthViewController *)viewController didAuthAsOwner:(NSDictionary *)twitchUser;
@end

@interface AuthViewController : WebViewController <UIAlertViewDelegate>
- (id)initWithTwitchOwner:(int)twitchID;

@property (nonatomic, retain) NSString *twitchName;
@property (nonatomic, assign) id<AuthViewControllerDelegate> delegate;
@end
