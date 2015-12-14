//
//  TableViewCell.h
//  Modd
//
//  Created on 11/17/15.
//  Copyright © 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TableViewCell;
@protocol TableViewCellDelegate <NSObject>
@optional
@end

@interface TableViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifer;
- (BOOL)isFirstCellInSection;
- (BOOL)isLastCellinSection;

@property (nonatomic, assign) id<TableViewCellDelegate> delegate;

@property (nonatomic) CGSize size;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger rowIndex;

@end
