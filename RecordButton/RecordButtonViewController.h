//
//  RecordButtonViewController.h
//  RecordButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011 Aardustry LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordButtonViewController : UIViewController
            <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
  UIButton *playButton;
  UIButton *recordButton;
  UIButton *recordButton2;
}

@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton2;

@property (nonatomic) BOOL locked;

-(IBAction)togglePlayButton:(id)sender;
-(IBAction)toggleRecordButton:(id)sender;

@end

