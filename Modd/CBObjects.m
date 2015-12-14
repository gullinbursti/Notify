//
//  CBObjects.m
//  Modd
//
//  Created on 11/28/15.
//  Copyright © 2015. All rights reserved.
//

#import "CBObjects.h"

@implementation CBObjects
+ (instancetype)sharedInstance {
	static dispatch_once_t once;
	static id sharedInstance;
	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (id)init {
	self = [super init];
	if (self) {
		NSError *error;
		self.manager = [CBLManager sharedInstance];
		if (!self.manager) {
			NSLog(@"Cannot create shared instance of CBLManager");
			return nil;
		}
		self.database = [self.manager databaseNamed:@"couchbaseevents" error:&error];
		if (!self.database) {
			NSLog(@"Cannot create database. Error message: %@", error.localizedDescription);
			return nil;
		}
	}
	return self;
}

@end
