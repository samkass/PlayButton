//
//  main.m
//  RecordButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011 Aardustry LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RecordButtonAppDelegate.h"

int main(int argc, char * argv[]) {
  NSString * appDelegateClassName;
  @autoreleasepool {
      // Setup code that might create autoreleased objects goes here.
      appDelegateClassName = NSStringFromClass([RecordButtonAppDelegate class]);
  }
  return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
