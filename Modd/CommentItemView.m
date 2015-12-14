//
//  CommentView.m
//  Modd
//
//  Created on 11/22/15.
//  Copyright © 2015. All rights reserved.
//

#import "NSDate+Modd.h"
#import "UILabel+Modd.h"
#import "UIView+Modd.h"

#import "FontAllocator.h"
#import "StaticInlines.h"

#import "CommentItemView.h"

@interface CommentItemView()
@property (nonatomic, strong) UILabel *captionLabel;
@end

@implementation CommentItemView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.frame.size.width - 74.0, 20.0)];
		_captionLabel.font = [[[FontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor lightGrayColor];
		_captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
		[self addSubview:_captionLabel];
	}
	
	return (self);
}

#pragma mark - Public APIs
- (void)setCommentVO:(CommentVO *)commentVO {
	_commentVO = commentVO;
	
	NSString *caption = [NSString stringWithFormat:@"%@ %@", _commentVO.username, _commentVO.textContent];
	_captionLabel.attributedText = [[NSAttributedString alloc] initWithString:caption attributes:@{NSParagraphStyleAttributeName	: [[FontAllocator sharedInstance] forceLineSpacingParagraphStyle:-10.0 forFont:[[[FontAllocator sharedInstance] avenirHeavy] fontWithSize:20]]}];
	_captionLabel.numberOfLines = [_captionLabel numberOfLinesNeeded];
	[_captionLabel setFont:[[[FontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:16] range:[_captionLabel.text rangeOfString:_commentVO.username]];
	[_captionLabel setTextColor:[UIColor whiteColor] range:[_captionLabel.text rangeOfString:_commentVO.username]];
	NSLog(@"SIZE:[%@] -=- %d", NSStringFromCGSize([_captionLabel sizeForText]), [_captionLabel numberOfLinesNeeded]);
	[_captionLabel resizeFrameForText];
	
	self.frame = CGRectResizeWidth(self.frame, MIN(_captionLabel.frameEdges.right, self.frame.size.width - 20.0));
	self.frame = CGRectResizeHeight(self.frame, _captionLabel.frame.size.height + 10.0);
	
	NSLog(@"FRAMES -- SELF:[%@] CAPTION:[%@]", NSStringFromCGRect(self.frame), NSStringFromCGRect(_captionLabel.frame));
}

@end
