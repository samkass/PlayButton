//
//  RecordButtonAppDelegate.h
//  RecordButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011-2021 Sam Kass. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecordButtonViewController;

@interface RecordButtonAppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) IBOutlet RecordButtonViewController *viewController;

@end
