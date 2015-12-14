//
//  TableViewCell.m
//  Modd
//
//  Created on 11/17/15.
//  Copyright © 2015. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell()
@end


@implementation TableViewCell
@synthesize size = _size;
@synthesize rowIndex = _rowIndex;
@synthesize indexPath = _indexPath;


+ (NSString *)cellReuseIdentifer {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		//self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]];
	}
	
	return (self);
}

- (BOOL)isFirstCellInSection {
	return (self.indexPath.row == 0);
}

- (BOOL)isLastCellinSection {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_indexPath.row + 1
												inSection:_indexPath.section];
	
	return (indexPath != nil);
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
	_indexPath = indexPath;
}

- (void)setRowIndex:(NSInteger)rowIndex {
	_rowIndex = rowIndex;
}

- (void)setSize:(CGSize)size {
	_size = size;
	
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _size.width, _size.height);
	self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, _size.width, _size.height);
}

@end
