//
//  ChannelViewController.m
//  Modd
//
//  Created on 11/17/15.
//  Copyright © 2015. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import <AWSS3/AWSS3.h>
//#import <AWSiOSSDKv2/S3.h>
#import <PubNub/PubNub.h>

#import "UIImageView+AFNetworking.h"
#import "UIView+Modd.h"
#import "NSDate+Modd.h"

#import "AFNetworking.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "PBJVision.h"
#import "PBJVisionUtilities.h"

#import "AppDelegate.h"
#import "Button.h"
#import "DeviceIntrinsics.h"
#import "FontAllocator.h"
#import "StaticInlines.h"

#import "ChannelViewController.h"
#import "ChannelVO.h"
#import "CommentVO.h"
#import "CommentItemView.h"


@interface ChannelViewController () <PBJVisionDelegate, PNObjectEventListener>
@property (nonatomic, strong) UIView *channelHeaderView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) UIView *cameraPreviewView;
@property (nonatomic, strong) UIView *finaleTintView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *cameraPreviewLayer;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpGestureRecognizer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *lastMessage;
@property (nonatomic, strong) NSString *lastVideo;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) UILabel *historyLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *participantsLabel;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *expireLabel;
@property (nonatomic, strong) Button *cameraFlipButton;
@property (nonatomic, strong) Button *cancelCameraButton;
@property (nonatomic, strong) UILabel *countdownLabel;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) UIImageView *commentFooterImageView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) Button *commentToggleButton;
@property (nonatomic, strong) Button *submitButton;
@property (nonatomic, strong) Button *messengerButton;
@property (nonatomic, strong) Button *likeButton;
@property (nonatomic, strong) Button *takePhotoButton;
@property (nonatomic, strong) NSTimer *focusTimer;
@property (nonatomic, strong) UIView *commentsHolderView;
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) ChannelVO *channelVO;
@property (nonatomic) BOOL isChannelOwner;
@property (nonatomic) BOOL isDeepLink;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isSubmitting;
@property (nonatomic) int messageTotal;
@property (nonatomic) int participants;
@property (nonatomic) int countdown;
@property (nonatomic) float lastDuration;
@end


@implementation ChannelViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_appEnteringBackground:)
													 name:@"APP_ENTERING_BACKGROUND" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_appLeavingBackground:)
													 name:@"APP_LEAVING_BACKGROUND" object:nil];
		_isActive = YES;
		_comment = @"";
		
		PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:kPubNubPublishKey
																		 subscribeKey:kPubNubSubscribeKey];
		
		_client = [PubNub clientWithConfiguration:configuration];
	}
	
	return (self);
}

- (id)initFromDeepLinkWithChannelName:(NSString *)channelName {
	if ((self = [self init])) {
		_channelName = channelName;
		_isDeepLink = YES;
	}
	
	return (self);
}

- (id)initWithChannel:(ChannelVO *)channelVO {
	if ((self = [self init])) {
		_channelName = [channelVO.dictionary objectForKey:@"channel"];
		_channelVO = channelVO;
	}
	
	return (self);
}

- (id)initWithChannel:(ChannelVO *)channelVO asTwitchUser:(NSDictionary *)twitchUser {
	if ((self = [self initWithChannel:channelVO])) {
		_channelName = [channelVO.dictionary objectForKey:@"channel"];
		_isChannelOwner = YES;
		
		[_client subscribeToChannels:@[[twitchUser objectForKey:@"_id"]] withPresence:YES];
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_submitTextComment {
	_isSubmitting = NO;
	[_client publish:_comment toChannel:_channelName mobilePushPayload:@{@"apns"	: @{@"aps"	: @{@"alert"	: _comment,
																									@"sound"	: @"selfie_notification.aif",
																									@"channel"	: _channelName}}} withCompletion:^(PNPublishStatus *status) {
																										NSLog(@"\nSEND");// MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
																									}];
}

- (void)_appendMessageWithContent:(NSString *)txtContent usingFrames:(NSArray *)frames {
	_player = [AVPlayer playerWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/popup-vids/%@.mp4", [txtContent stringByReplacingOccurrencesOfString:@"pic" withString:@"audio"]]]];
	[_player play];
	
	NSDictionary *dict = @{@"filename"	: [txtContent stringByReplacingOccurrencesOfString:@"pic" withString:@""],
						   @"frames"	: frames,
						   @"duration"	: @([frames count] * 0.333)};
	
	[_messages addObject:dict];
	
	_imageView.animationImages = frames;
	_imageView.animationDuration = _lastDuration;
	[_imageView startAnimating];
	
	[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
		_animationImageView.alpha = 0.0;
		_expireLabel.alpha = 0.0;
	} completion:^(BOOL finished) {
		_animationImageView.hidden = YES;
		_animationImageView.alpha = 1.0;
	}];
}

- (void)_retrieveStream {
	NSLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"GET", @"https://api.twitch.tv/kraken", @"streams", @{@"channel"	: [[_channelVO.dictionary objectForKey:@"title"] lowercaseString]});
	AFHTTPClient *httpClient2 = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitch.tv/kraken"]];
	[httpClient2 getPath:@"streams" parameters:@{@"channel"	: [[_channelVO.dictionary objectForKey:@"title"] lowercaseString]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			
		} else {
			NSLog(@"AFNetworking [-] %@ |[:]>> RESULT [:]|>>\n%@", [[self class] description], result);
			if ([[result objectForKey:@"_total"] intValue] > 0) {
				_titleLabel.text = [_titleLabel.text stringByAppendingFormat:@" / %@", [[[[result objectForKey:@"streams"] firstObject] objectForKey:@"channel"] objectForKey:@"game"]];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"AFNetworking [-] %@: (%@) Failed Request - (%d) %@", [[self class] description], [[operation request] URL], (int)[operation response].statusCode, [error localizedDescription]);
	}];
}

- (void)_channelSetup {
	_participants = 0;
	
	[[NSUserDefaults standardUserDefaults] setObject:_channelName forKey:@"channel_name"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
	[_client addListener:self];
	[_client subscribeToChannels:@[_channelName] withPresence:YES];
	//[_client pushNotificationEnabledChannelsForDeviceWithPushToken:[[HONDeviceIntrinsics sharedInstance] dataPushToken] andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
	
		[UIView animateWithDuration:0.250 delay:3.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
			_expireLabel.alpha = 0.0;
		} completion:^(BOOL finished) {
		}];
		
		[self.client hereNowForChannel:_channelName withVerbosity:PNHereNowUUID
							completion:^(PNPresenceChannelHereNowResult *result,
										 PNErrorStatus *status) {
								
								//[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"join_channel"];
								NSLog(@"::: PRESENCE OBSERVER - [%@] :::", result.data.uuids);
								NSLog(@"PARTICIPANTS:[%d]", (int)[result.data.uuids count]);
								
								_participants = (int)[result.data.uuids count];
								_participantsLabel.text = [NSString stringWithFormat:@"• Online with %d other%@", MAX(0, _participants - 1), (MAX(0, _participants - 1) == 1) ? @"" : @"s"];
								
								if (_participants > 1) {
									_expireLabel.text = [NSString stringWithFormat:@"Alerting… %d %@", MAX(0, _participants - 1), ((_participants - 1) == 1) ? @"person" : @"people"];
								} else {
									_expireLabel.text = @"No one is here, invite friends…";
								}
								
								_expireLabel.alpha = 1.0;
								[UIView animateWithDuration:0.250 delay:3.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
									_expireLabel.alpha = 0.0;
								} completion:^(BOOL finished) {
								}];
								
								// Check whether request successfully completed or not.
								if (!status.isError) {
									// Handle downloaded presence information using:
									//   result.data.uuids - list of uuids.
									//   result.data.occupancy - total number of active subscribers.
								} else {
									
									// Handle presence audit error. Check 'category' property to find out possible issue because of which request did fail.
									// Request can be resent using: [status retry];
								}
							}];
		
		
		[self.client historyForChannel:_channelName start:nil end:nil limit:100
						withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
							NSLog(@"::: HISTORY OBSERVER - [%d] :::", (int)[result.data.messages count]);
							
							// Check whether request successfully completed or not.
							if (!status.isError) {
								
								_messageTotal = (int)[result.data.messages count];
								_historyLabel.text = NSStringFromInt(_messageTotal);
								[result.data.messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
									NSDictionary *dict = (NSDictionary *)obj;
									
									NSString *txtContent = ([dict isKindOfClass:[NSDictionary class]]) ? ([dict objectForKey:@"pn_other"] != nil) ? [dict objectForKey:@"pn_other"] : ([dict objectForKey:@"text"] != nil) ? [dict objectForKey:@"text"] : @"" : @"";
									NSLog(@"txtContent:[%@]\n%@", txtContent, dict);
									
									
									if ([txtContent length] > 0 && [txtContent rangeOfString:@"pic_"].location != NSNotFound) {
										_lastDuration = [[[txtContent componentsSeparatedByString:@":"] lastObject] floatValue];
										txtContent = [[txtContent componentsSeparatedByString:@":"] firstObject];
										
										if (_imageView.animationImages == nil) {
											//[self _downloadAudio:[NSString stringWithFormat:@"%@.mp4", [txtContent stringByReplacingOccurrencesOfString:@"pic" withString:@"audio"]]];
											
											NSMutableArray *frames = [NSMutableArray array];
											
											for (int i=0; i<(int)(_lastDuration * 2)-1; i++) {
												NSString *imageURL = [NSString stringWithFormat:@"http://s3.amazonaws.com/popup-thumbs/%@_%02d.jpg", txtContent, i];
												AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]
																														  imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
																															  NSLog(@"IMAGE REQUEST:[%@]", NSStringFromCGSize(image.size));
																															  
																															  [frames addObject:image];
																															  
																															  if ([frames count] == (int)(_lastDuration * 2) -1)
																																  [self _appendMessageWithContent:txtContent usingFrames:frames];
																															  
																														  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
																															  //SelfieclubJSONLog(@"AFNetworking [-] %@: Failed Request - %@\n%@", [[self class] description], [error localizedDescription], request.URL.absoluteURL);
																															  
																															  CGSize imageSize = CGSizeMake(64, 64);
																															  UIColor *fillColor = [UIColor blackColor];
																															  UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
																															  CGContextRef context = UIGraphicsGetCurrentContext();
																															  [fillColor setFill];
																															  CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
																															  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
																															  UIGraphicsEndImageContext();
																															  
																															  [frames addObject:image];
																															  
																															  if ([frames count] == (int)(_lastDuration * 2)-1) {
																																  _player = [AVPlayer playerWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/popup-vids/%@.mp4", [txtContent stringByReplacingOccurrencesOfString:@"pic" withString:@"audio"]]]];
																																  [_player play];
																																  
																																  NSDictionary *dict = @{@"filename"	: [txtContent stringByReplacingOccurrencesOfString:@"pic" withString:@""],
																																						 @"frames"		: frames,
																																						 @"duration"	: @([frames count] * 0.333)};
																																  
																																  [_messages addObject:dict];
																																  
																																  _imageView.animationImages = frames;
																																  _imageView.animationDuration = _lastDuration;
																																  [_imageView startAnimating];
																																  
																																  [UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
																																	  _animationImageView.alpha = 0.0;
																																	  _expireLabel.alpha = 0.0;
																																  } completion:^(BOOL finished) {
																																	  _animationImageView.hidden = YES;
																																	  _animationImageView.alpha = 1.0;
																																  }];
																															  }
																														  }];
												[operation start];
											}
											
											_expireLabel.text = @"Loading moment…";
											_expireLabel.alpha = 1.0;
											[UIView animateWithDuration:0.250 delay:3.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
												_expireLabel.alpha = 0.0;
											} completion:^(BOOL finished) {
											}];
										}
									}
								}];
								
								
								// Handle downloaded history using:
								//   result.data.start - oldest message time stamp in response
								//   result.data.end - newest message time stamp in response
								//   result.data.messages - list of messages
							}
							// Request processing failed.
							else {
								
								// Handle message history download error. Check 'category' property to find
								// out possible issue because of which request did fail.
								//
								// Request can be resent using: [status retry];
							}
							
							
							_takePhotoButton.enabled = YES;
							_messengerButton.enabled = YES;
							_cameraFlipButton.enabled = YES;
							_likeButton.enabled = YES;
						}];
}


- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
	// Handle new message stored in message.data.message
	if (message.data.actualChannel) {
  
		// Message has been received on channel group stored in
		// message.data.subscribedChannel
	}
	else {
  
		// Message has been received on channel stored in
		// message.data.subscribedChannel
	}
	//NSLog(@"Received message: %@ on channel %@ at %@", message.data.message, message.data.subscribedChannel, message.data.timetoken);
	
	NSString *txtContent = ([message.data.message isKindOfClass:[NSDictionary class]]) ? ([message.data.message objectForKey:@"pn_other"] != nil) ? [message.data.message objectForKey:@"pn_other"] : @"" : message.data.message;
	NSLog(@"Received message: %@ on channel %@ at %@", txtContent, message.data.subscribedChannel, message.data.timetoken);
	
	if ([txtContent length] > 0) {
		if ([txtContent rangeOfString:@"pic_"].location != NSNotFound) {
			_messageTotal++;
			
			_lastDuration = [[[txtContent componentsSeparatedByString:@":"] lastObject] floatValue];
			txtContent = [[txtContent componentsSeparatedByString:@":"] firstObject];
			
			_historyLabel.text = NSStringFromInt(_messageTotal);
			
			//[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - playVideo"] withProperties:@{@"file"		: txtContent,
			//																															  @"channel"	: _channelName}];
			[_imageView stopAnimating];
			
			//[self _downloadAudio:[NSString stringWithFormat:@"https://s3.amazonaws.com/popup-vids/%@.mp4", [txtContent stringByReplacingOccurrencesOfString:@"pic" withString:@"audio"]]];
			
			NSMutableArray *frames = [NSMutableArray array];
			
			for (int i=0; i<(int)(_lastDuration * 2)-1; i++) {
				NSString *imageURL = [NSString stringWithFormat:@"http://s3.amazonaws.com/popup-thumbs/%@_%02d.jpg", txtContent, i];
				AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]
																						  imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
																							  NSLog(@"IMAGE REQUEST:[%@]", NSStringFromCGSize(image.size));
																							  
																							  [frames addObject:image];
																							  
																							  NSLog(@"FRAMES:[%d/%d]", [frames count], (((int)_lastDuration) * 2) -1);
																							  
																							  if ([frames count] == (((int)_lastDuration) * 2) -1)
																								  [self _appendMessageWithContent:txtContent usingFrames:frames];
																							  
																						  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
																							  //SelfieclubJSONLog(@"AFNetworking [-] %@: Failed Request - %@\n%@", [[self class] description], [error localizedDescription], request.URL.absoluteURL);
																							  
																							  CGSize imageSize = CGSizeMake(64, 64);
																							  UIColor *fillColor = [UIColor blackColor];
																							  UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
																							  CGContextRef context = UIGraphicsGetCurrentContext();
																							  [fillColor setFill];
																							  CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
																							  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
																							  UIGraphicsEndImageContext();
																							  
																							  [frames addObject:image];
																							  
																							  if ([frames count] == (int)(_lastDuration * 2)-1) {
																								  _player = [AVPlayer playerWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/popup-vids/%@.mp4", [txtContent stringByReplacingOccurrencesOfString:@"pic" withString:@"audio"]]]];
																								  [_player play];
																								  
																								  NSDictionary *dict = @{@"filename"	: [txtContent stringByReplacingOccurrencesOfString:@"pic" withString:@""],
																														 @"frames"		: frames,
																														 @"duration"	: @([frames count] * 0.333)};
																								  
																								  [_messages addObject:dict];
																								  
																								  _imageView.animationImages = frames;
																								  _imageView.animationDuration = _lastDuration;
																								  [_imageView startAnimating];
																								  
																								  [UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
																									  _animationImageView.alpha = 0.0;
																									  _expireLabel.alpha = 0.0;
																								  } completion:^(BOOL finished) {
																									  _animationImageView.hidden = YES;
																									  _animationImageView.alpha = 1.0;
																								  }];
																							  }
																						  }];
				[operation start];
			}
			
			_expireLabel.text = @"Loading moment…";
			_expireLabel.alpha = 1.0;
			[UIView animateWithDuration:0.250 delay:3.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
				_expireLabel.alpha = 0.0;
			} completion:^(BOOL finished) {
			}];
			
		} else {
			NSDictionary *dict = @{@"id"				: @"0",
								   @"msg_id"			: @"0",
								   
								   @"owner_member"		: @{@"id"	: @(2392),
															@"name"	: @"anon:"},
								   @"image"				: @"",
								   @"text"				: txtContent,
								   
								   @"net_vote_score"	: @(0),
								   @"status"			: NSStringFromInt(0),
								   @"added"				: [NSDate stringFormattedISO8601],
								   @"updated"			: [NSDate stringFormattedISO8601]};
			
			
			CommentVO *commentVO = [CommentVO commentWithDictionary:dict];
			[self _appendComment:commentVO];
		}
	}
}


-(void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
 
	// Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
	// state-change).
	if (event.data.actualChannel) {
		
		// Presence event has been received on channel group stored in
		// event.data.subscribedChannel
	}
	else {
		
		// Presence event has been received on channel stored in
		// event.data.subscribedChannel
	}
	NSLog(@"Did receive presence event: %@", event.data.presenceEvent);
	
	if ([event.data.presenceEvent isEqualToString:@"join"]) {
		id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
		[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
															  action:@"User Joined"
															   label:[_channelVO.dictionary objectForKey:@"title"]
															   value:@1] build]];
	}
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
	
	if (status.category == PNUnexpectedDisconnectCategory) {
		// This event happens when radio / connectivity is lost
	}
	
	else if (status.category == PNConnectedCategory) {
  
		// Connect event. You can do stuff like publish, and know you'll get it.
		// Or just use the connected event to confirm you are subscribed for
		// UI / internal notifications, etc
  
	}
	else if (status.category == PNReconnectedCategory) {
  
		// Happens as part of our regular operation. This event happens when
		// radio / connectivity is lost, then regained.
	}
	else if (status.category == PNDecryptionErrorCategory) {
  
		// Handle messsage decryption error. Probably client configured to
		// encrypt messages and on live data feed it received plain text.
	}

}


#pragma mark - Notifications
- (void)_appEnteringBackground:(NSNotification *)notification {
	_isActive = NO;
	
	//--	[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
}

- (void)_appLeavingBackground:(NSNotification *)notification {
	_isActive = YES;
	
	//--	if (_moviePlayer.contentURL != nil)
	//--		[_moviePlayer play];
	
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
														message:[NSString stringWithFormat:@"Want to share %@ with your friends?", [_channelVO.dictionary objectForKey:@"title"]]
													   delegate:self
											  cancelButtonTitle:@"Yes"
											  otherButtonTitles:@"Cancel", nil];
	[alertView setTag:ChannelAlertViewTypeInvite];
	[alertView show];
}

- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	UITextField *textField = (UITextField *)[notification object];
	
	if (textField.tag == 0 && [textField.text length] == 0)
		textField.text = @"What is your name?";
}


#pragma mark - UI Presentation
- (void)_appendComment:(CommentVO *)vo {
	NSLog(@"_appendComment:[%@]", vo.textContent);
		  
	CGFloat offset = 33.0;
	CommentItemView *itemView = [[CommentItemView alloc] initWithFrame:CGRectMake(0.0, offset + _commentsHolderView.frame.size.height, self.view.frame.size.width, 38.0)];
	itemView.commentVO = vo;
	itemView.alpha = 0.0;
	[_commentsHolderView addSubview:itemView];
	
	_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, itemView.frame.size.height);
	
	[UIView animateKeyframesWithDuration:0.25 delay:0.00
								 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
							  animations:^(void) {
								  itemView.alpha = 1.0;
								  itemView.frame = CGRectOffsetY(itemView.frame, -offset);
							  } completion:^(BOOL finished) {
							  }];
	
	
	_scrollView.contentSize = _commentsHolderView.frame.size;
	[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
	if (_scrollView.frame.size.height - _commentsHolderView.frame.size.height < 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:NO];
}

- (void)_updateCountdown {
	if (--_countdown <= 0) {
		[_countdownTimer invalidate];
		_countdownTimer = nil;
		
		_countdownLabel.text = @"";
		_countdownLabel.hidden = YES;
		//		_expireLabel.hidden = NO;
	}
	
	_countdownLabel.text = [NSString stringWithFormat:@":%02d", _countdown];
}

- (void)_updateFocus {
	CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:self.view.center inFrame:self.view.frame];
	[[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}



#pragma mark - Camera Setup
- (void)_setupCamera {
	PBJVision *vision = [PBJVision sharedInstance];
	vision.delegate = self;
	vision.usesApplicationAudioSession = YES;
	vision.cameraDevice = ([vision isCameraDeviceAvailable:PBJCameraDeviceFront]) ? PBJCameraDeviceFront : PBJCameraDeviceBack;
	[vision setMaximumCaptureDuration:CMTimeMakeWithSeconds(5, 600)];
	vision.cameraMode = PBJCameraModeVideo;
	vision.cameraOrientation = PBJCameraOrientationPortrait;
	vision.focusMode = PBJFocusModeLocked;
	vision.exposureMode = PBJExposureModeContinuousAutoExposure;
	vision.outputFormat = PBJOutputFormatStandard;
	vision.videoRenderingEnabled = YES;
	vision.captureSessionPreset = AVCaptureSessionPresetHigh;
	[vision setPresentationFrame:_cameraPreviewView.frame];
	[vision setVideoFrameRate:30];
	vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264MainAutoLevel,
											   AVVideoAllowFrameReorderingKey : @(NO)}; // AVVideoProfileLevelKey requires specific captureSessionPreset
	
	_focusTimer = [NSTimer scheduledTimerWithTimeInterval:2.50
												   target:self
												 selector:@selector(_updateFocus)
												 userInfo:nil repeats:YES];
	
	NSLog(@"SETUP CAMERA");
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_imageView];
	
	[self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"channelGradient"]]];

	_cameraPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height * 1.0000, self.view.frame.size.width, self.view.frame.size.height)];
	_cameraPreviewView.backgroundColor = (_isDeepLink) ? [UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00] : [UIColor blackColor];
	
	_cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
	_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
	_cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[_cameraPreviewView.layer addSublayer:_cameraPreviewLayer];
	[self.view addSubview:_cameraPreviewView];
	
	_finaleTintView = [[UIView alloc] initWithFrame:self.view.frame];
	_finaleTintView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.60];
	_finaleTintView.alpha = 0.0;
	[self.view addSubview:_finaleTintView];
	
	_commentFooterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInputDnBG"]];
	_commentFooterImageView.userInteractionEnabled = YES;
	_commentFooterImageView.frame = CGRectOffset(_commentFooterImageView.frame, 0.0, self.view.frame.size.height - _commentFooterImageView.frame.size.height);
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, _channelHeaderView.frameEdges.bottom, self.view.frame.size.width, self.view.frame.size.height - (_channelHeaderView.frameEdges.bottom + 60.0 + [UIApplication sharedApplication].statusBarFrame.size.height))];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 0.0);
	_scrollView.contentInset = UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - 55.0)), _scrollView.contentInset.left, 10.0, _scrollView.contentInset.right);
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	_animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 206.0) * 0.5, -40.0 + (((self.view.frame.size.height * 1.0000) - 206.0) * 0.5), 206.0, 206.0)];
	_animationImageView.hidden = YES;
	[self.view addSubview:_animationImageView];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicatorView.center = CGPointMake(_animationImageView.bounds.size.width * 0.5, _animationImageView.bounds.size.height * 0.5);
	[activityIndicatorView startAnimating];
	[_animationImageView addSubview:activityIndicatorView];
	
	UILabel *previewLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 31.0, self.view.frame.size.width - 40.0, 20.0)];
	previewLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	previewLabel.backgroundColor = [UIColor clearColor];
	previewLabel.textAlignment = NSTextAlignmentCenter;
	previewLabel.textColor = [UIColor whiteColor];
	previewLabel.text = @"Post Moment";
	[_finaleTintView addSubview:previewLabel];
	
	Button *retakeButton = [Button buttonWithType:UIButtonTypeCustom];
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	retakeButton.frame = CGRectOffset(retakeButton.frame, 0.0, 20.0);
	[retakeButton addTarget:self action:@selector(_goRetake) forControlEvents:UIControlEventTouchUpInside];
	[_finaleTintView addSubview:retakeButton];
	
	_submitButton = [Button buttonWithType:UIButtonTypeCustom];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitCameraButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitCameraButton_Active"] forState:UIControlStateHighlighted];
	_submitButton.frame = CGRectOffset(_submitButton.frame, (self.view.frame.size.width - _submitButton.frame.size.width) - 10.0, 20.0);
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[_finaleTintView addSubview:_submitButton];
	
	_commentToggleButton = [Button buttonWithType:UIButtonTypeCustom];
	_commentToggleButton.frame = self.view.frame;
	[_commentToggleButton addTarget:self action:@selector(_goOpenComment) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_commentToggleButton];
	
	[self.view addSubview:_commentFooterImageView];
	
//	_bubbleView = [[UIView alloc] initWithFrame:CGRectMake(_openCommentButton.frame.origin.x - 1.0, _openCommentButton.frame.origin.y - 3.0, 20.0, 20.0)];
//	_bubbleView.layer.cornerRadius = 10;
//	_bubbleView.backgroundColor = [UIColor redColor];
//	[self.view addSubview:_bubbleView];
	
	_historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 19.0)];
	_historyLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:11];
	_historyLabel.backgroundColor = [UIColor clearColor];
	_historyLabel.textAlignment = NSTextAlignmentCenter;
	_historyLabel.textColor = [UIColor whiteColor];
	_historyLabel.text = @"0";
	[_bubbleView addSubview:_historyLabel];
	
	
	_channelHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIApplication sharedApplication].statusBarFrame.size.height, [UIScreen mainScreen].bounds.size.width, 46.0)];
	[self.view addSubview:_channelHeaderView];
	
	Button *backButton = [Button buttonWithType:UIButtonTypeCustom];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	backButton.frame = CGRectOffset(backButton.frame, 0.0, 0.0);
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_channelHeaderView addSubview:backButton];
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_channelHeaderView.frame.size.width - 250.0) * 0.5, 6.0, 250.0, 16.0)];
	_titleLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textAlignment = NSTextAlignmentCenter;
	_titleLabel.textColor = [UIColor whiteColor];
	_titleLabel.text = [_channelVO.dictionary objectForKey:@"title"];
	[_channelHeaderView addSubview:_titleLabel];
	
	_participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake((_channelHeaderView.frame.size.width - 250.0) * 0.5, 34.0, 250.0, 12.0)];
	_participantsLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
	_participantsLabel.backgroundColor = [UIColor clearColor];
	_participantsLabel.textAlignment = NSTextAlignmentCenter;
	_participantsLabel.textColor = [UIColor greenColor];
	_participantsLabel.text = @"• Online with 0 others";
	[_channelHeaderView addSubview:_participantsLabel];
	
	
	_cancelCameraButton = [Button buttonWithType:UIButtonTypeCustom];
	_cancelCameraButton.frame = CGRectMake(6.0, 26.0, 40.0, 40.0);
	[_cancelCameraButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_cancelCameraButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[_cancelCameraButton addTarget:self action:@selector(_goCancelCamera) forControlEvents:UIControlEventTouchUpInside];
	_cancelCameraButton.hidden = YES;
	[self.view addSubview:_cancelCameraButton];
	
	_messengerButton = [Button buttonWithType:UIButtonTypeCustom];
	_messengerButton.frame = CGRectMake(0.0, 0.0, 72.0, 72.0);
	[_messengerButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateNormal];
	[_messengerButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active"] forState:UIControlStateHighlighted];
	_messengerButton.frame = CGRectOffset(_messengerButton.frame, ((self.view.frame.size.width * 0.5) - _messengerButton.frame.size.width) - 8.0, (self.view.frame.size.height - _messengerButton.frame.size.height) - 55.0);
	[_messengerButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	_messengerButton.enabled = NO;
	//[self.view addSubview:_messengerButton];
	
	
	_likeButton = [Button buttonWithType:UIButtonTypeCustom];
	_likeButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
	_likeButton.frame = CGRectOffset(_likeButton.frame, (self.view.frame.size.width - _likeButton.frame.size.width) - 3.0, (self.view.frame.size.height - _likeButton.frame.size.height) - 40.0);
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	_likeButton.enabled = NO;
	[self.view addSubview:_likeButton];
	
	if (_isChannelOwner) {
		_cameraFlipButton = [Button buttonWithType:UIButtonTypeCustom];
		_cameraFlipButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[_cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[_cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		_cameraFlipButton.frame = CGRectOffset(_cameraFlipButton.frame, (_channelHeaderView.frame.size.width - _cameraFlipButton.frame.size.width) - 2.0, 0.0);
		[_cameraFlipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		_cameraFlipButton.enabled = NO;
		[_channelHeaderView addSubview:_cameraFlipButton];
		
		_takePhotoButton = [Button buttonWithType:UIButtonTypeCustom];
		_takePhotoButton.frame = CGRectMake(0.0, 0.0, 72.0, 72.0);
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
		_takePhotoButton.frame = CGRectOffset(_takePhotoButton.frame, (self.view.frame.size.width - _takePhotoButton.frame.size.width) * 0.5, (self.view.frame.size.height - _takePhotoButton.frame.size.height) - 53.0);
		[_takePhotoButton addTarget:self action:@selector(_goImageComment) forControlEvents:UIControlEventTouchUpInside];
		_takePhotoButton.enabled = NO;
		[self.view addSubview:_takePhotoButton];
	}
	
	_commentsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.frame.size.width, 0.0)];
	[_scrollView addSubview:_commentsHolderView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 8.0, _commentsHolderView.frame.size.width - 100.0, 23.0)];
	_commentTextField.backgroundColor = [UIColor clearColor];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeySend];
	[_commentTextField setTextColor:[UIColor whiteColor]];
	[_commentTextField setTag:1];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_commentTextField.font = [[[FontAllocator sharedInstance] avenirHeavy] fontWithSize:20];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.placeholder = @"";
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_commentFooterImageView addSubview:_commentTextField];
	
	Button *submitCommentButton = [Button buttonWithType:UIButtonTypeCustom];
	[submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	[submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateDisabled];
	submitCommentButton.frame = CGRectOffset(submitCommentButton.frame, (_commentFooterImageView.frame.size.width - submitCommentButton.frame.size.width) - 3.0, 1.0);
	[submitCommentButton addTarget:self action:@selector(_goTextComment) forControlEvents:UIControlEventTouchUpInside];
	[_commentFooterImageView addSubview:submitCommentButton];
	
	float scale = 0.5;
	_previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - (self.view.frame.size.width * scale)) * 0.5, (self.view.frame.size.height - (self.view.frame.size.height * scale)) * 0.5, self.view.frame.size.width * scale, self.view.frame.size.height * scale)];
	_previewImageView.backgroundColor = [UIColor redColor];
	_previewImageView.hidden = YES;
	[self.view addSubview:_previewImageView];
	
	_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, (self.view.frame.size.height * 0.5) - 13.0, self.view.frame.size.width - 50.0, 20.0)];//[[UILabel alloc] initWithFrame:CGRectMake(10.0, (self.view.frame.size.height * 1.0000) - 60.0, self.view.frame.size.width - 20.0, 40.0)];
	_expireLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_expireLabel.backgroundColor = [UIColor clearColor];
	_expireLabel.textAlignment = NSTextAlignmentCenter;
	_expireLabel.textColor = [UIColor whiteColor];
	_expireLabel.text = @"Loading channel…";
	[self.view addSubview:_expireLabel];
	
	_countdownLabel = [[UILabel alloc] initWithFrame:_participantsLabel.frame];
	_countdownLabel.font = _participantsLabel.font;
	_countdownLabel.backgroundColor = [UIColor clearColor];
	_countdownLabel.textAlignment = NSTextAlignmentRight;
	_countdownLabel.textColor = [UIColor whiteColor];
	_countdownLabel.text = @"5";
	_countdownLabel.hidden = YES;
	[_channelHeaderView addSubview:_countdownLabel];
	
	_cameraPreviewView.hidden = NO;
	_commentTextField.hidden = NO;
	_cameraPreviewView.hidden = NO;
	
	_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	_lpGestureRecognizer.minimumPressDuration = 0.25;
	_lpGestureRecognizer.delaysTouchesBegan = YES;
	[self.view addGestureRecognizer:_lpGestureRecognizer];
	
	
	[self _retrieveStream];
	[self _channelSetup];
	[self _setupCamera];
	[[PBJVision sharedInstance] startPreview];
	
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
														  action:@"Loaded"
														   label:[_channelVO.dictionary objectForKey:@"title"]
														   value:@1] build]];

}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self _goOpenComment];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)_goBack {
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
														  action:@"Leave"
														   label:[_channelVO.dictionary objectForKey:@"title"]
														   value:@1] build]];
	
	[_focusTimer invalidate];
	_focusTimer = nil;
	
	[[PBJVision sharedInstance] cancelVideoCapture];
	[[PBJVision sharedInstance] stopPreview];
	[[PBJVision sharedInstance] destroyCamera];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:AVPlayerItemDidPlayToEndTimeNotification
												  object:[_player currentItem]];
	
	
	NSLog(@"CHANNEL_HISTORY:\n%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"channel_history"]);
	
	[[NSUserDefaults standardUserDefaults] setObject:NSStringFromBOOL(NO) forKey:@"chat_share"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[_player setRate:0.0];
	[_player seekToTime:CMTimeMake(0, 1)];
	[_player pause];
	_player = nil;
	
	
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"in_chat"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)_goRetake {
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
														  action:@"Camera Retake"
														   label:[_channelVO.dictionary objectForKey:@"title"]
														   value:@1] build]];
	
	[_player setRate:0.0];
	[_player seekToTime:CMTimeMake(0, 1)];
	[_player pause];
	
	_cancelCameraButton.hidden = NO;
	_takePhotoButton.hidden = NO;
	_previewImageView.hidden = YES;
	
	[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
		_finaleTintView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		_finaleTintView.hidden = YES;
	}];
}

- (void)_goSubmit {
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
														  action:@"Post Camera"
														   label:[_channelVO.dictionary objectForKey:@"title"]
														   value:@1] build]];
	
	[_player setRate:0.0];
	[_player seekToTime:CMTimeMake(0, 1)];
	[_player pause];
	_player = nil;
	
	_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 1.0000, self.view.frame.size.width, self.view.frame.size.height);
	_channelHeaderView.hidden = NO;
	
	[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
		_finaleTintView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		_finaleTintView.hidden = YES;
	}];
	
	_submitButton.hidden = YES;
	_previewImageView.hidden = YES;
	_countdownLabel.text = @"";
	_takePhotoButton.hidden = NO;
	_countdownLabel.hidden = YES;
	_playerLayer.hidden = NO;
	_expireLabel.hidden = NO;
	_bubbleView.hidden = NO;
	_scrollView.hidden = NO;
	_likeButton.hidden = NO;
	_commentFooterImageView.hidden = NO;
	
	_messengerButton.alpha = 1.0;
	_messengerButton.hidden = NO;
	
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	_cancelCameraButton.hidden = YES;
	
//	[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendVideo"] withProperties:@{@"channel"	: _channelName,
//																																  @"file"		: _lastVideo}];
	
	
	[_client publish:[[[_lastVideo componentsSeparatedByString:@"."] firstObject] stringByAppendingFormat:@":%f", _lastDuration] toChannel:_channelName mobilePushPayload:@{@"apns"	: @{@"aps"	: @{@"alert"	: @"Someone has posted a video.",
																																																	@"sound"	: @"selfie_notification.aif",
																																																	@"channel"	: _channelName}}} withCompletion:^(PNPublishStatus *status) {
																																																		NSLog(@"\nSEND");
																																																	}];
}

- (void)_goOpenComment {
	if (![_commentTextField isFirstResponder])
		[_commentTextField becomeFirstResponder];
	
	[_commentToggleButton removeTarget:self action:@selector(_goOpenComment) forControlEvents:UIControlEventTouchUpInside];
	[_commentToggleButton addTarget:self action:@selector(_goCancelComment) forControlEvents:UIControlEventTouchUpInside];

}

- (void)_goCancelComment {
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
	
	_expireLabel.hidden = NO;
	
	_commentTextField.text = @"";
	[_commentToggleButton removeTarget:self action:@selector(_goCancelComment) forControlEvents:UIControlEventTouchUpInside];
	[_commentToggleButton addTarget:self action:@selector(_goOpenComment) forControlEvents:UIControlEventTouchUpInside];
	
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_channelHeaderView.frameEdges.bottom + [UIApplication sharedApplication].statusBarFrame.size.height));
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	_commentFooterImageView.image = [UIImage imageNamed:@"commentInputDnBG"];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_messengerButton.alpha = 1.0;
		_commentFooterImageView.frame = CGRectTranslateY(_commentFooterImageView.frame, self.view.frame.size.height - _commentFooterImageView.frame.size.height);
		_likeButton.frame = CGRectTranslateY(_likeButton.frame, (self.view.frame.size.height - _likeButton.frame.size.height) - 40.0);
		_takePhotoButton.frame = CGRectTranslateY(_takePhotoButton.frame, (self.view.frame.size.height - _takePhotoButton.frame.size.height) - 53.0);
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
	} completion:^(BOOL finished) {
	}];
	
}

- (void)_goFlipCamera {
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
														  action:@"Flip Camera"
														   label:[_channelVO.dictionary objectForKey:@"title"]
														   value:@1] build]];
}

- (void)_goCancelCamera {
	_channelHeaderView.hidden = NO;
	_cancelCameraButton.hidden = YES;
	_previewImageView.hidden = YES;
	_commentToggleButton.enabled = YES;
	_scrollView.hidden = NO;
	_likeButton.hidden = NO;
	_commentFooterImageView.hidden = NO;
	
	[[PBJVision sharedInstance] stopPreview];
	
	_finaleTintView.hidden = NO;
	
	_countdownLabel.text = @"";
	_countdownLabel.hidden = YES;
	_playerLayer.hidden = NO;
	_expireLabel.hidden = NO;
	
	_bubbleView.hidden = NO;
	_messengerButton.alpha = 1.0;
	_messengerButton.hidden = NO;
	
	_expireLabel.text = @"";
	_expireLabel.alpha = 0.0;
	//	_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, self.view.frame.size.height - 40.0);
	
	_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 1.0000, self.view.frame.size.width, self.view.frame.size.height);
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	_cancelCameraButton.hidden = YES;
}

- (void)_goLike {
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
														  action:@"Like"
														   label:[_channelVO.dictionary objectForKey:@"title"]
														   value:@1] build]];
	
	[_client publish:_comment toChannel:@"user has requested you to record a Popup" mobilePushPayload:@{@"apns"	: @{@"aps"	: @{@"alert"	: @"user has requested you to record a Popup",
																																@"sound"	: @"selfie_notification.aif",
																																@"channel"	: _channelName}}} withCompletion:^(PNPublishStatus *status) {
																																	NSLog(@"\nSEND");// MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
																																}];
}

- (void)_goShare {
	
}

- (void)_goImageComment {
	[self _goCancelComment];
	
	_finaleTintView.hidden = YES;
	_channelHeaderView.hidden = YES;
	_animationImageView.hidden = YES;
	_scrollView.hidden = YES;
	_likeButton.hidden = YES;
	_messengerButton.hidden = YES;
	_commentToggleButton.enabled = NO;
	_commentFooterImageView.hidden = YES;
	
	[[PBJVision sharedInstance] startPreview];
	
	_bubbleView.hidden = YES;
	_messengerButton.alpha = 0.0;
	
	_expireLabel.alpha = 1.0;
	_expireLabel.hidden = NO;
	_expireLabel.text = @"Ready…";
	//_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, (self.view.frame.size.height * 0.5) - 10.0);
	
	_playerLayer.hidden = YES;
	
	_cameraPreviewView.frame = self.view.frame;
	_cameraPreviewLayer.frame = CGRectFromSize(_cameraPreviewView.frame.size);
	_cameraPreviewLayer.opacity = 1.0;
	
	_cancelCameraButton.hidden = NO;
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Pressed"] forState:UIControlStateHighlighted];
}

- (void)_goTextComment {
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
														  action:@"Post Comment"
														   label:[_channelVO.dictionary objectForKey:@"title"]
														   value:@1] build]];
	
	_isSubmitting = YES;
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	[self _submitTextComment];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
		
		CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		if (CGRectContainsPoint(_takePhotoButton.frame, touchPoint)) {
			id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
			[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
																  action:@"Start Record"
																   label:[_channelVO.dictionary objectForKey:@"title"]
																   value:@1] build]];
			
			if ([_commentTextField isFirstResponder])
				[_commentTextField resignFirstResponder];
			
			_commentTextField.text = @"";
			
			_channelHeaderView.hidden = YES;
			_animationImageView.hidden = YES;
			_cancelCameraButton.hidden = YES;
			
			_submitButton.hidden = YES;
			_messengerButton.alpha = 0.0;
			
			_finaleTintView.hidden = YES;
			
			_bubbleView.hidden = YES;
			
			_expireLabel.hidden = YES;
			_expireLabel.text = @"";
			
			_playerLayer.hidden = YES;
			
			_cameraPreviewView.frame = self.view.frame;
			_cameraPreviewLayer.frame = CGRectFromSize(_cameraPreviewView.frame.size);
			_cameraPreviewLayer.opacity = 1.0;
			
			_scrollView.hidden = YES;
			
			_commentFooterImageView.frame = CGRectTranslateY(_commentFooterImageView.frame, self.view.frame.size.height - _commentFooterImageView.frame.size.height);
			
			
			_countdown = 5;
			_countdownLabel.text = [NSString stringWithFormat:@":%02d", _countdown];
			_countdownLabel.hidden = NO;
			
			[[PBJVision sharedInstance] startPreview];
			[[PBJVision sharedInstance] startVideoCapture];
			
			_countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.00
															   target:self
															 selector:@selector(_updateCountdown)
															 userInfo:nil repeats:YES];
		}
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendVideo"] withProperties:@{@"channel"	: @(_statusUpdateVO.statusUpdateID)}];
		
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
		
		id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
		[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Channel"
															  action:@"Stop Record"
															   label:[_channelVO.dictionary objectForKey:@"title"]
															   value:@1] build]];
		
		[[PBJVision sharedInstance] endVideoCapture];
		_takePhotoButton.hidden = YES;
		
		_finaleTintView.hidden = NO;
		[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
			_finaleTintView.alpha = 1.0;
			
		} completion:^(BOOL finished) {
		}];
	}
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	_commentFooterImageView.image = [UIImage imageNamed:@"commentInputUpBG"];
	_expireLabel.hidden = YES;
	_scrollView.hidden = NO;
	//_scrollView.backgroundColor = [UIColor blueColor];
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_commentFooterImageView.frame.size.height + 216.0));
	[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:NO];
	
	if (textField.tag == 1) {
		_cameraPreviewView.hidden = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			_cameraPreviewView.hidden = NO;
		});
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"text"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		_scrollView.hidden = NO;
		
	} else {
	}
	
	//if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
	//	[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
		_commentFooterImageView.frame = CGRectTranslateY(_commentFooterImageView.frame, self.view.frame.size.height - (_commentFooterImageView.frame.size.height + 216.0));
		_likeButton.frame = CGRectTranslateY(_likeButton.frame, _likeButton.frame.origin.y - 216.0);
		_takePhotoButton.frame = CGRectTranslateY(_takePhotoButton.frame, _takePhotoButton.frame.origin.y - 216.0);
	} completion:^(BOOL finished) {
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (!_isSubmitting && [textField.text length] > 0 && textField.tag == 1)
		[self _goTextComment];
	
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	//if ([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSet]].location != NSNotFound)
	//	return (NO);
	
	if (textField.tag == 0 && [textField.text isEqualToString:@"What is your name?"])
		textField.text = @"";
	
	return ([textField.text length] <= 200 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}

- (void)_onTextEditingDidEnd:(id)sender {
	//	NSLog(@"[*:*] _onTextEditingDidEnd:[%@]", _commentTextField.text);
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - PBJVisionDelegate
-(UIImage *)_imageFromVideoWithURL:(NSURL *)url atTime:(CGFloat) time {
	//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
	//    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	//    generator.appliesPreferredTrackTransform=TRUE;
	//    CMTime thumbTime = CMTimeMakeWithSeconds(0, 1);
	//
	//    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
	//        if (result != AVAssetImageGeneratorSucceeded) {
	//            NSLog(@"couldn't generate thumbnail, error:%@", error);
	//        }
	//
	//        UIImage *thumbImg = [UIImage imageWithCGImage:im];
	//    };
	//
	//    CGSize maxSize = CGSizeMake(320, 180);
	//    generator.maximumSize = maxSize;
	//    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
	//
	
	
	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
	AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	gen.appliesPreferredTrackTransform = YES;
	NSError *error = nil;
	
	CMTime actualTime;
	CMTime frameTime = CMTimeMakeWithSeconds(time, 1.0);
	
	CGImageRef image = [gen copyCGImageAtTime:frameTime actualTime:&actualTime error:&error];
	UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
	CGImageRelease(image);
	
	return (thumb);
}

// session
- (void)visionSessionWillStart:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionWillStart [*:*]");
}

- (void)visionSessionDidStart:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStart [*:*]");
}

- (void)visionSessionDidStop:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStop [*:*]");
}

// preview
- (void)visionSessionDidStartPreview:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStartPreview [*:*]");
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStopPreview [*:*]");
}

// device
- (void)visionCameraDeviceWillChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionCameraDeviceWillChange [*:*]");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionCameraDeviceDidChange [*:*]");
}

// mode
- (void)visionCameraModeWillChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionCameraModeWillChange [*:*]");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionCameraModeDidChange [*:*]");
}

// format
- (void)visionOutputFormatWillChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionOutputFormatWillChange [*:*]");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionOutputFormatDidChange [*:*]");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture {
	NSLog(@"[*:*] vision:didChangeCleanAperture:[%@] [*:*]", NSStringFromCGRect(cleanAperture));
}

// flash
// photo
- (void)visionWillCapturePhoto:(PBJVision *)vision {
	NSLog(@"[*:*] visionWillCapturePhoto [*:*]");
}

- (void)visionDidCapturePhoto:(PBJVision *)vision {
	NSLog(@"[*:*] visionDidCapturePhoto [*:*]");
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error {
	NSLog(@"[*:*] vision:capturedPhoto:[%lu] error:[%@] [*:*]", (unsigned long)[[photoDict objectForKey:PBJVisionPhotoMetadataKey] count], error);
	
	[[PBJVision sharedInstance] stopPreview];
	//
	if (error != nil) {
		[[[UIAlertView alloc] initWithTitle:@"Error taking photo!"
									message:nil
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else {
//		[self _uploadPhoto:[photoDict objectForKey:PBJVisionPhotoImageKey]];
	}
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
	NSLog(@"[*:*] vision:capturedVideo:[%@] [*:*]", videoDict);
	
	_countdownLabel.text = @"";
	_countdownLabel.hidden = YES;
	[_imageView stopAnimating];
	
	NSString *videoPath = [videoDict objectForKey:PBJVisionVideoPathKey];
	NSString *videoName = [[[videoPath pathComponents] lastObject] stringByReplacingOccurrencesOfString:@"video" withString:@"pic"];
	NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:videoPath];
	
	_lastDuration = [[videoDict objectForKey:PBJVisionVideoCapturedDurationKey] floatValue];
	_lastVideo = videoName;
	
	NSMutableArray *cachedVideos = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cached"] mutableCopy];
	[cachedVideos addObject:videoPath];
	[[NSUserDefaults standardUserDefaults] setObject:[cachedVideos copy] forKey:@"cached"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSMutableArray *frames = [NSMutableArray arrayWithArray:[videoDict objectForKey:PBJVisionVideoThumbnailArrayKey]];
	//NSArray *frames2 = [self _generateImageFromFilePath:videoPath atTime:0.0];
	
	
	
	NSLog(@"FRAMES:[%d] %f", [frames count], [[videoDict objectForKey:PBJVisionVideoCapturedDurationKey] floatValue]);
	
	_previewImageView.animationImages = frames;
	_previewImageView.animationDuration = [[videoDict objectForKey:PBJVisionVideoCapturedDurationKey] floatValue];
	_previewImageView.hidden = NO;
	[_previewImageView startAnimating];
	
	UILabel *uploadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (_previewImageView.frame.size.height - 20.0) * 0.5, _previewImageView.frame.size.width, 20.0)];
	uploadLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	uploadLabel.backgroundColor = [UIColor clearColor];
	uploadLabel.textAlignment = NSTextAlignmentCenter;
	uploadLabel.textColor = [UIColor whiteColor];
	uploadLabel.text = @"Uploading…";
	[_previewImageView addSubview:uploadLabel];
	
	
	AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
	
	__block int tot = 0;
	for (int i=0; i<[frames count]; i++) {
		NSString *imageName = [NSString stringWithFormat:@"%@_%02d.jpg", [[videoName componentsSeparatedByString:@"."] firstObject], i];
		NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:imageName];
		
		[UIImageJPEGRepresentation([frames objectAtIndex:i], 0.50) writeToFile:imagePath atomically:YES];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		NSLog(@"UPLOADING...");
		for (int i=0; i<[frames count]; i++) {
			NSLog(@"UPLOADING:[%d]", i);
			NSString *imageName = [NSString stringWithFormat:@"%@_%02d.jpg", [[videoName componentsSeparatedByString:@"."] firstObject], i];
			NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:imageName];
			NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
			
			AWSS3TransferManagerUploadRequest *imageUploadRequest = [AWSS3TransferManagerUploadRequest new];
			imageUploadRequest.bucket = @"popup-thumbs";
			imageUploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
			imageUploadRequest.key = imageName;
			imageUploadRequest.body = imageURL;
			imageUploadRequest.contentType = @"image/jpeg";
			
			
			[[transferManager upload:imageUploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
			//[[transferManager upload:imageUploadRequest] continueWithBlock:^id(AWSTask *task) {
				if (task.error) {
					if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
						switch (task.error.code) {
							case AWSS3TransferManagerErrorCancelled:
							case AWSS3TransferManagerErrorPaused:
							{
								dispatch_async(dispatch_get_main_queue(), ^{
									NSLog(@"AWSS3TransferManager: **ERROR** [%@]", task.error);
								});
							}
								break;
								
							default:
								NSLog(@"Upload failed: [%@]", task.error);
								break;
						}
					} else {
						NSLog(@"Upload failed: [%@]", task.error);
					}
				}
				
				if (task.result) {
					dispatch_async(dispatch_get_main_queue(), ^{
						NSLog(@"AWSS3TransferManager: !!SUCCESS!! [https://s3.amazonaws.com/popup-thumbs/%@]", imageName);
						if (++tot == [frames count]) {
							[uploadLabel removeFromSuperview];
							_submitButton.hidden = NO;
						}
					});
				}
				
				return (nil);
			}];
		}
	});
	
	
	
	AVMutableComposition *composition = [AVMutableComposition composition];
	AVURLAsset *sourceAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
	AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	
	BOOL ok = NO;
	AVAssetTrack *sourceAudioTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
	CMTimeRange x = CMTimeRangeMake(kCMTimeZero, [sourceAsset duration]);
	ok = [compositionAudioTrack insertTimeRange:x ofTrack:sourceAudioTrack atTime:kCMTimeZero error:nil];
	
	
	NSString *audioName = [[[videoPath pathComponents] lastObject] stringByReplacingOccurrencesOfString:@"video" withString:@"audio"];
	NSString *audioPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:audioName];
	NSURL *audioURL = [[NSURL alloc] initFileURLWithPath:audioPath];
	
	AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
	exporter.outputURL = audioURL;
	
	NSLog(@"AVAssetExportSession - supportedFileTypes:\n%@", [exporter supportedFileTypes]);
	exporter.outputFileType = @"com.apple.quicktime-movie";
	[exporter exportAsynchronouslyWithCompletionHandler:^{
		NSLog(@"AVExporter DONE:[%@]", audioURL);
		
		AWSS3TransferManagerUploadRequest *audioUploadRequest = [AWSS3TransferManagerUploadRequest new];
		audioUploadRequest.bucket = @"popup-vids";
		audioUploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
		audioUploadRequest.key = audioName;
		audioUploadRequest.body = audioURL;
		audioUploadRequest.contentType = @"video/mp4";
		
		[[transferManager upload:audioUploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
			if (task.error) {
				if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
					switch (task.error.code) {
						case AWSS3TransferManagerErrorCancelled:
						case AWSS3TransferManagerErrorPaused:
						{
							dispatch_async(dispatch_get_main_queue(), ^{
								NSLog(@"AWSS3TransferManager: **ERROR** [%@]", task.error);
							});
						}
							break;
							
						default:
							NSLog(@"Upload failed: [%@]", task.error);
							break;
					}
				} else {
					NSLog(@"Upload failed: [%@]", task.error);
				}
			}
			
			if (task.result) {
				dispatch_async(dispatch_get_main_queue(), ^{
					NSLog(@"AWSS3TransferManager: !!SUCCESS!! [https://s3.amazonaws.com/popup-vids/%@]", audioName);
				});
			}
			
			return (nil);
		}];
		
		_player = [AVPlayer playerWithURL:audioURL];
		[_player play];
	}];
	
	
	
	
	//	AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
	//	uploadRequest.bucket = @"popup-vids";
	//	uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
	//	uploadRequest.key = videoName;
	//	uploadRequest.contentType = @"video/mp4";
	//	uploadRequest.body = videoURL;
	//
	//	[[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
	//		if (task.error) {
	//			NSLog(@"AWSS3TransferManager: **ERROR** [%@]", task.error);
	//
	//		} else {
	//			NSLog(@"AWSS3TransferManager: !!SUCCESS!! [%@]", task.error);
	//			[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendVideo"] withProperties:@{@"channel"	: _channelName,
	//																																		  @"file"		: videoName}];
	//
	//
	//			[_client publish:videoName toChannel:_channelName mobilePushPayload:@{@"apns"	: @{@"aps"	: @{@"alert"	: @"Someone has posted a video.",
	//																											@"sound"	: @"selfie_notification.aif",
	//																											@"channel"	: _channelName}}} withCompletion:^(PNPublishStatus *status) {
	//																												NSLog(@"\nSEND");
	//																											}];
	//		}
	//
	//		return (nil);
	//	}];
	//
	//
	//	_isPlaying = NO;
	//	_moviePlayer.contentURL = videoURL;
	//--	[_moviePlayer play];
}


// progress
- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureVideoSampleBuffer:[%.04f] [*:*]", vision.capturedVideoSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureAudioSample:[%.04f] [*:*]", vision.capturedAudioSeconds);
}



#pragma mark - AlertView Deleagets
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == ChannelAlertViewTypeInvite) {
		if (buttonIndex == 0) {
			[self _goShare];
		}
	}
}


@end
