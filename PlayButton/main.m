//
//  main.m
//  RecordButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011 Aardustry LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PlayButtonAppDelegate.h"

int main(int argc, char * argv[]) {
  NSString * appDelegateClassName;
  @autoreleasepool {
      // Setup code that might create autoreleased objects goes here.
      appDelegateClassName = NSStringFromClass([PlayButtonAppDelegate class]);
  }
  return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
