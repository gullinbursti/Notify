//
//  CommentVO.m
//  Modd
//
//  Created on 11/18/15.
//  Copyright © 2015. All rights reserved.
//

#import "CommentVO.h"

#import "NSDate+Modd.h"
#import "NSDictionary+Modd.h"
#import "NSString+Modd.h"

@implementation CommentVO
+ (CommentVO *)commentWithDictionary:(NSDictionary *)dictionary {
	CommentVO *vo = [[CommentVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.commentID = [[dictionary objectForKey:@"id"] intValue];
	vo.messageID = ([dictionary objectForKey:@"msg_id"] != nil) ? [dictionary objectForKey:@"msg_id"] : [dictionary objectForKey:@"id"];
	vo.userID = ([dictionary objectForKey:@"owner_member"] != nil) ? [[[dictionary objectForKey:@"owner_member"] objectForKey:@"id"] intValue] : [[dictionary objectForKey:@"user_id"] intValue];
	vo.username = ([dictionary objectForKey:@"owner_member"] != nil) ? [[dictionary objectForKey:@"owner_member"] objectForKey:@"name"] : [dictionary objectForKey:@"username"];
	vo.textContent = ([[dictionary objectForKey:@"text"] length] > 0) ? [dictionary objectForKey:@"text"] : @"";
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	return (vo);
}

@end
