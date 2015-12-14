//
//  HomeViewCell.m
//  Modd
//
//  Created on 7/29/15.
//  Copyright (c) 2015. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "AFNetworking.h"

#import "FontAllocator.h"
#import "HomeViewCell.h"
#import "Button.h"

@interface HomeViewCell () <HomeViewCellDelegate>
@property (nonatomic, strong) UIImageView *onlineImageView;
@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) Button *subscribeButton;
@end

@implementation HomeViewCell
@synthesize delegate = _delegate;
@synthesize channelVO = _channelVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
//		[self hideChevron];
	}
	
	return (self);
}


- (void)populateFields:(NSDictionary *)dictionary {
	
	_onlineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([[dictionary objectForKey:@"online"] isEqualToString:@"Y"]) ? @"ledOnline" : @"ledOffline"]];
	_onlineImageView.frame = CGRectOffset(_onlineImageView.frame, 0.0, (self.frame.size.height - _onlineImageView.frame.size.height) * 0.5);
	[self.contentView addSubview:_onlineImageView];
	
	_thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(21.0, (self.frame.size.height - 40) * 0.5, 39.0, 39.0)];
	_thumbImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Channel", (self.indexPath.section == 0) ? @"user" : @"user"]];
	[self.contentView addSubview:_thumbImageView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(68.0, 13.0, self.frame.size.width - 24.0, 13.0)];
	titleLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
	titleLabel.textColor = [UIColor colorWithRed:0.278 green:0.243 blue:0.243 alpha:1.00];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = [dictionary objectForKey:@"title"];
	[self.contentView addSubview:titleLabel];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, 29.0, self.frame.size.width - 124.0, 14.0)];
	participantsLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:10];
	participantsLabel.textColor = [UIColor colorWithWhite:0.40 alpha:1.00];
	participantsLabel.backgroundColor = [UIColor clearColor];
	participantsLabel.text = @"Loading…";
	[self.contentView addSubview:participantsLabel];
	
	_subscribeButton = [Button buttonWithType:UIButtonTypeCustom];
	[_subscribeButton setBackgroundImage:[UIImage imageNamed:@"subscribeButton_nonActive"] forState:UIControlStateNormal];
	[_subscribeButton setBackgroundImage:[UIImage imageNamed:@"subscribeButton_Active"] forState:UIControlStateHighlighted];
	_subscribeButton.frame = CGRectOffset(_subscribeButton.frame, (self.frame.size.width - _subscribeButton.frame.size.width) - 11.0, (self.frame.size.height - _subscribeButton.frame.size.height) * 0.5);
	[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:_subscribeButton];
	
	NSString *apiPath = [NSString stringWithFormat:@"channels/%@", [[dictionary objectForKey:@"title"] lowercaseString]];
	NSLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", @"https://api.twitch.tv/kraken", apiPath, nil);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitch.tv/kraken"]];
	[httpClient getPath:apiPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			
		} else {
			NSLog(@"AFNetworking [-] %@ |[:]>> RESULT [:]|>>\n%@", [[self class] description], result);
			int followers = [[result objectForKey:@"followers"] intValue];
			int views = [[result objectForKey:@"views"] intValue];
			
			if ([result objectForKey:@"logo"] != [NSNull null]) {
				void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					_thumbImageView.image = image;
				};
				
				void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
					_thumbImageView.image = [UIImage imageNamed:@"defaultClubCover"];
				};
				
				[_thumbImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[result objectForKey:@"logo"]]
																		 cachePolicy:NSURLRequestReturnCacheDataElseLoad
																	 timeoutInterval:3.0]
									   placeholderImage:nil
												success:imageSuccessBlock
												failure:imageFailureBlock];
			}
			
			
			
			//participantsLabel.text = [NSString stringWithFormat:@"%@ follower%@ / %@ view%@", [numberFormatter stringFromNumber:@(followers)], (followers == 1) ? @"" : @"s", [numberFormatter stringFromNumber:@(views)], (views == 1) ? @"" : @"s"];
			participantsLabel.text = [NSString stringWithFormat:@"%@ follower%@", [numberFormatter stringFromNumber:@(followers)], (followers == 1) ? @"" : @"s"];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"AFNetworking [-] %@: (%@) Failed Request - (%d) %@", [[self class] description], [[operation request] URL], (int)[operation response].statusCode, [error localizedDescription]);
	}];
	
	NSLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", @"https://api.twitch.tv/kraken", @"streams", @{@"channel"	: [[dictionary objectForKey:@"title"] lowercaseString]});
	AFHTTPClient *httpClient2 = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitch.tv/kraken"]];
	[httpClient2 getPath:@"streams" parameters:@{@"channel"	: [[dictionary objectForKey:@"title"] lowercaseString]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			
		} else {
			NSLog(@"AFNetworking [-] %@ |[:]>> RESULT [:]|>>\n%@", [[self class] description], result);
			if ([[result objectForKey:@"_total"] intValue] > 0) {
				_onlineImageView.image = [UIImage imageNamed:@"ledOnline"];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"AFNetworking [-] %@: (%@) Failed Request - (%d) %@", [[self class] description], [[operation request] URL], (int)[operation response].statusCode, [error localizedDescription]);
	}];
}


#pragma mark - Public
- (void)setChannelVO:(ChannelVO *)channelVO {
	_channelVO = channelVO;
}


#pragma mark - Navigation
- (void)_goSubscribe {
	if ([self.delegate respondsToSelector:@selector(homeViewCell:didSelectSubscribe:)])
		[self.delegate homeViewCell:self didSelectSubscribe:_channelVO];
}
@end
