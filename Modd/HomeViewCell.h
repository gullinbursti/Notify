//
//  HomeViewCell.h
//  Modd
//
//  Created on 7/29/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "TableViewCell.h"
#import "ChannelVO.h"

@class HomeViewCell;
@protocol HomeViewCellDelegate <TableViewCellDelegate>
@optional
- (void)homeViewCell:(HomeViewCell *)cell didSelectSubscribe:(ChannelVO *)channelVO;
@end

@interface HomeViewCell : TableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)populateFields:(NSDictionary *)dictionary;

@property (nonatomic, strong) ChannelVO *channelVO;
@property (nonatomic, assign) id <HomeViewCellDelegate> delegate;

@end
