//
//  ViewController.h
//  Modd
//
//  Created on 11/18/15.
//  Copyright © 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HomeActionSheetType) {
	HomeActionSheetTypeTermsAgreement = 0,
	HomeActionSheetTypeRowSelect,
	HomeActionSheetTypeSubscribe
};

typedef NS_ENUM(NSUInteger, HomeAlertViewType) {
	HomeAlertViewTypeFlag = 0,
	HomeAlertViewTypeTermsAgreement,
	HomeAlertViewTypePurchase
};

@interface HomeViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@end

