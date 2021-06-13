//
//  PlayButtonAppDelegate.h
//  PlayButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011-2021 Sam Kass. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayButtonViewController;

@interface PlayButtonAppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) IBOutlet PlayButtonViewController *viewController;

@end
