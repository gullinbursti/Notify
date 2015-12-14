//
//  NSDictionary+Modd.h
//  Modd
//
//  Created on 10/30/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDictionary (Modd)
//- (id)objectForKeyPathArray:(NSArray *)keyPathArray;
//- (id)objectForKeyPath:(NSString *)keyPath;

- (id)defaultValue:(id)object forKey:(NSString *)key;
- (BOOL)hasObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)replaceObject:(id)object forKey:(NSString *)key;
- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB;
@end



@interface NSMutableDictionary (Modd)
//- (void)setObject:(id)value forKeyPath:(NSString *)keyPath;
//- (void)setObject:(id)value forKeyPathArray:(NSArray *)keyPathArray;

- (id)defaultValue:(id)object forKey:(NSString *)key;
- (BOOL)hasObjectForKey:(NSString *)key;
//- (id)objectForKeyPath:(NSString *)keyPath;
//- (id)objectForKeyPathArray:(NSArray *)keyPathArray;
- (void)removeObjectForKey:(NSString *)key;
- (void)replaceObject:(id)object forKey:(NSString *)key;
- (void)swapObjectForKey:(NSString *)keyA withObjectForKey:(NSString *)keyB;
- (void)addObjects:(NSArray *)objects withKeys:(NSArray *)keys;
- (void)purgeObjectsWithKeys:(NSArray *)keys;
- (void)replaceObjects:(NSArray *)objects withKeys:(NSArray *)keys;
@end


@interface NSUserDefaults (Modd)
//- (void)setObject:(id)value forKeyPath:(NSString *)keyPath;
//- (void)setObject:(id)value forKeyPathArray:(NSArray *)keyPathArray;

- (id)defaultValue:(id)object forKey:(NSString *)key;
- (BOOL)hasObjectForKey:(NSString *)key;
- (void)purgeObjectForKey:(NSString *)key;
- (void)replaceObject:(id)object forKey:(NSString *)key;
- (void)swapObjectForKey:(NSString *)keyA withObjectForKey:(NSString *)keyB;
- (void)addObjects:(NSArray *)objects withKeys:(NSArray *)keys;
- (void)purgeObjectsWithKeys:(NSArray *)keys;
- (void)replaceObjects:(NSArray *)objects withKeys:(NSArray *)keys;
@end

