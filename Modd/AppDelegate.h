//
//  AppDelegate.h
//  Modd
//
//  Created on 11/18/15.
//  Copyright © 2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

extern NSString * const kPubNubConfigDomain;
extern NSString * const kPubNubPublishKey;
extern NSString * const kPubNubSubscribeKey;
extern NSString * const kPubNubSecretKey;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (UINavigationController *)rootNavController;
+ (UIViewController *)appNavController;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

