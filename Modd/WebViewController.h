//
//  WebViewController.h
//  Modd
//
//  Created on 03.26.13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>
- (id)initWithURL:(NSString *)url title:(NSString *)title;

- (void)_goClose;

@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic, strong) NSString *url;
@end
