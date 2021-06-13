//
//  RecordButtonViewController.h
//  RecordButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011-2021 Sam Kass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMediaPickerController.h>

@interface PlayButtonViewController : UIViewController
            <AVAudioRecorderDelegate, AVAudioPlayerDelegate, MPMediaPickerControllerDelegate>
{
  UIButton *playButton;
  UIButton *recordButton;
  UIButton *recordButton2;
}

@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton2;

@property (nonatomic) BOOL locked;

-(IBAction)pressPlayButton:(id)sender;
-(IBAction)pressRecordButton:(id)sender;
-(IBAction)chooseSoundFromLibrary:(id)sender;
-(IBAction)stopRecordingIfHeldAndReleased:(id)sender;

- (void) stopRecording;
- (void) stopPlaying;
- (void) pausePlaying;
- (void) resumePlaying;
- (void) configureButtonState;

@end

