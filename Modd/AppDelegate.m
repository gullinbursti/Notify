//
//  AppDelegate.m
//  Modd
//
//  Created on 11/18/15.
//  Copyright © 2015. All rights reserved.
//

#import <AWSiOSSDKv2/AWSCore.h>

#import "AFNetworking.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "CouchbaseEvents.h"

NSString * const kPubNubConfigDomain = @"pubsub.pubnub.com";
NSString * const kPubNubPublishKey = @"pub-c-e7f51bf7-cf68-4167-9173-4a26589160e3";//pub-c-a4abb7b2-2e28-43c4-b8f1-b2de162a79c3";
NSString * const kPubNubSubscribeKey = @"sub-c-0d5cf1e6-9186-11e5-b829-02ee2ddab7fe";//sub-c-ed10ba66-c9b8-11e4-bf07-0619f8945a4f";
NSString * const kPubNubSecretKey = @"sec-c-YjE3MDczN2ItYTAyYS00MTAwLWI1N2ItZjY1NDFhODdmMzhm";//sec-c-OTI3ZWQ4NWYtZDRkNi00OGFjLTgxMjctZDkwYzRlN2NkNDgy";

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (UIViewController *)appNavController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController);
}

+ (UINavigationController *)rootNavController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController.navigationController);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	
	AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:@"AKIAJH4DRAN5YPWCOCUA"
																									 secretKey:@"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"];
	
	AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
																		  credentialsProvider:credentialsProvider];
	
	[AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
	
	
	id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"tracker"
														trackingId:@"UA-71163202-1"];
	
	
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"in_chat"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
	[builder set:@"start" forKey:kGAISessionControl];
	[tracker set:kGAIScreenName value:@"Launch"];
	[tracker send:[builder build]];
	
	
	tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"App"
														  action:@"Boot"
														   label:@""
														   value:@1] build]];
	
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = navigationController;
	[self.window makeKeyAndVisible];
	
	
//	CouchbaseEvents *cbevents = [[CouchbaseEvents alloc] init];
//	[cbevents helloCBL];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"App"
														  action:@"Enter Background"
														   label:@""
														   value:@1] build]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"App"
														  action:@"Leave Background"
														   label:@""
														   value:@1] build]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_LEAVING_BACKGROUND" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.builtinmenlo.Modd" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Modd" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Modd.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
