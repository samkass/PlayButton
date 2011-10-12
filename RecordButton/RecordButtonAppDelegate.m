//
//  RecordButtonAppDelegate.m
//  RecordButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011 Aardustry LLC. All rights reserved.
//

#import "RecordButtonAppDelegate.h"

#import "RecordButtonViewController.h"

NSString *kRecordingLockedKey        = @"recordingLockedKey";

@implementation RecordButtonAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

-(void)applySettings
{
  NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kRecordingLockedKey];
	if (testValue == nil)
	{
		// no default values have been set, create them here based on what's in our Settings bundle info
		//
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
    
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    
		id recordLockedDefault = nil;
		
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray)
		{
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			
			if ([keyValueStr isEqualToString:kRecordingLockedKey])
			{
				recordLockedDefault = [prefItem objectForKey:@"DefaultValue"];
			}
		}
    
		// since no default values have been set (i.e. no preferences file created), create it here		
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 recordLockedDefault, kRecordingLockedKey,
                                 nil];
    
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	// we're ready to go, so lastly set the key preference values
	BOOL recordLocked = [[[NSUserDefaults standardUserDefaults] objectForKey:kRecordingLockedKey] boolValue];
  [self.viewController setLocked:recordLocked];
}

- (void)defaultsChanged:(NSNotification *)notification
{
  [self applySettings];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
  {
      self.viewController = [[RecordButtonViewController alloc] initWithNibName:@"RecordButtonViewController_iPhone" bundle:nil]; 
  }
  else
  {
      self.viewController = [[RecordButtonViewController alloc] initWithNibName:@"RecordButtonViewController_iPad" bundle:nil]; 
  }
  self.window.rootViewController = self.viewController;
  
  // listen for changes to our preferences when the Settings app does so,
  // when we are resumed from the backround, this will give us a chance to update our UI
  //
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(defaultsChanged:)
                                               name:NSUserDefaultsDidChangeNotification
                                             object:nil];

  [self applySettings];

  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

@end
