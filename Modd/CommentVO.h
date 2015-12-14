//
//  CommentVO.h
//  Modd
//
//  Created on 11/18/15.
//  Copyright © 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentVO : NSObject
+ (CommentVO *)commentWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int commentID;
@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *messageID;
@property (nonatomic, retain) NSString *textContent;
@property (nonatomic, retain) NSDate *addedDate;
@end
