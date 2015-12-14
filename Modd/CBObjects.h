//
//  CBObjects.h
//  Modd
//
//  Created on 11/28/15.
//  Copyright © 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface CBObjects : NSObject
+ (CBObjects*)sharedInstance;

@property (nonatomic, strong) CBLDatabase *database;
@property (nonatomic, strong) CBLManager *manager;
@end
