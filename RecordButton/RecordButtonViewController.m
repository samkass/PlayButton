//
//  RecordButtonViewController.m
//  RecordButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011 Aardustry LLC. All rights reserved.
//

#import <MediaPlayer/MPMediaPickerController.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AudioToolbox/AudioServices.h"
#import "RecordButtonViewController.h"

@interface RecordButtonViewController ()

@property (nonatomic) BOOL recording;
@property (nonatomic) BOOL playing;
@property (nonatomic) BOOL stopping;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;	

@property (nonatomic) BOOL playAfterStop;
@property (nonatomic) BOOL recordAfterStop;

@property (strong, nonatomic) NSDate *timeThatRecordWasPressed;

@property (assign) BOOL playRecordedAudio;
@property (strong, nonatomic) NSURL *audioAssetUrl;

-(void)configureButtonState;
-(NSString*)recordSoundPath;
-(NSString*)playSoundPath;
- (void)resetAfterRecord;

- (void) initializeAudioSession;
- (void) initializePlaying;
- (void) initializeRecording;

- (void) startRecording;
- (void) stopRecording;
- (void) startPlaying;
- (void) stopPlaying;

@end

@implementation RecordButtonViewController
@synthesize playButton;
@synthesize recordButton, recordButton2;
@synthesize locked, playAfterStop, recordAfterStop;
@synthesize recording, recorder, player, playing;
@synthesize timeThatRecordWasPressed;
@synthesize playRecordedAudio;
@synthesize audioAssetUrl;
@synthesize stopping;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  
  playAfterStop = NO;
  recordAfterStop = NO;
  [self stopPlaying];
  [self stopRecording];
  
  player = nil;
  recorder = nil;
  playing = NO;
  recording = NO;
  stopping = NO;
  
  [self configureButtonState];
}

-(void)viewDidLoad
{
  playRecordedAudio = YES;
  audioAssetUrl = nil;
  
  [self initializeAudioSession];
  [self initializePlaying];
  [self initializeRecording];

  [self configureButtonState];
}

-(void)configureButtonState
{
  [playButton setEnabled:YES];
  [recordButton setEnabled:YES];
  [recordButton2 setEnabled:YES];

  if (self.playing)
  {
    [playButton setImage:[UIImage imageNamed:@"playHighlighted.png"] forState:UIControlStateNormal];
    [recordButton setEnabled:NO];
    [recordButton2 setEnabled:NO];
  }
  else
  {
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [recordButton setEnabled:YES];
    [recordButton2 setEnabled:YES];
  }

  if (self.recording)
  {
    [recordButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"stopHighlighted.png"] forState:UIControlStateHighlighted];
    [recordButton2 setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    [recordButton2 setImage:[UIImage imageNamed:@"stopHighlighted.png"] forState:UIControlStateHighlighted];
  }
  else
  {
    [recordButton setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"recordHighlighted.png"] forState:UIControlStateHighlighted];
    [recordButton2 setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
    [recordButton2 setImage:[UIImage imageNamed:@"recordHighlighted.png"] forState:UIControlStateHighlighted];
  }

  [recordButton setHidden:locked];
  [recordButton2 setHidden:locked];
  
  [playButton setEnabled:[[NSFileManager defaultManager] fileExistsAtPath:[self playSoundPath]]];

}

- (UIImage*)imageWithImage:(UIImage*)image
     scaledToSizeOfControl:(UIControl*)control
{
  CGSize newSize = control.bounds.size;
  UIGraphicsBeginImageContext( newSize );
  CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
  [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}

-(void)setLocked:(BOOL)newLocked
{
  locked = newLocked;
  [self configureButtonState];
}

-(IBAction)pressPlayButton:(id)sender
{
  if (!playing)
  {
    [self startPlaying];
    [self configureButtonState];
  }
}

-(IBAction)pressRecordButton:(id)sender
{
  timeThatRecordWasPressed = [NSDate date];
  if (!playing)
  {
    if (recording)
    {
      [self stopRecording];
    }
    else
    {
      [self startRecording];
    }
    [self configureButtonState];
  }
}

-(IBAction)chooseSoundFromLibrary:(id)sender
{
  MPMediaPickerController *picker =
  [[MPMediaPickerController alloc]
   initWithMediaTypes: MPMediaTypeAnyAudio];
  
  [picker setDelegate: self];
  [picker setAllowsPickingMultipleItems: NO];
  picker.prompt =
  NSLocalizedString (@"Select audio to play",
                     "Prompt in media item picker");
  
  [self presentModalViewController: picker animated: YES];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection
{  
  [self dismissModalViewControllerAnimated: YES];
  playRecordedAudio = NO;
  audioAssetUrl = [collection.representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
  self.player = nil;
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{  
  [self dismissModalViewControllerAnimated: YES];
}

-(IBAction)stopPlayingIfHeldAndReleased:(id)sender
{
}

-(IBAction)stopRecordingIfHeldAndReleased:(id)sender
{
  NSDate *now = [NSDate date];
  if (recording && !stopping && [now timeIntervalSinceDate:timeThatRecordWasPressed] > 0.5)
  {
    [self stopRecording];
  }
}

-(NSString*)recordSoundPath
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                       NSUserDomainMask, 
                                                       YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:
          [NSString stringWithFormat:@"RECORD.caf"]];
}

-(NSString*)playSoundPath
{
  if (playRecordedAudio)
  {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, 
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:
            [NSString stringWithFormat:@"PLAY.caf"]];
  }
  else
  {
    return [audioAssetUrl absoluteString];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)viewDidUnload
{
  [self setPlayButton:nil];
  [self setRecordButton:nil];
  [self setRecordButton2:nil];
  [super viewDidUnload];
}

- (void) startRecording
{
  if (playing)
  {
    recordAfterStop = YES;
    [self.player stop];
  }
  else
  {
    if (!recording)
    {
      self.recording = YES;
      if (self.recorder == nil)
      {
        [self initializeRecording];
      }
      [self.recorder record];
    }
  }
}

- (void) stopRecording
{
  stopping = YES;
  [self.recorder stop];
  playRecordedAudio = YES;
}

- (void) startPlaying
{
  if (recording)
  {
    playAfterStop = YES;
    [self.recorder stop];
  }
  else
  {
    if (!playing)
    {
      playing = YES;
      if (self.player == nil)
      {
        [self initializePlaying];
      }
      [self.player play];
    }
  }
}

- (void) stopPlaying
{
  [self.player stop];
}

- (void) initializeAudioSession
{
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  NSError *err = nil;
  [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
  if (err)
  {
    NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    return;
  }
  [audioSession setActive:YES error:&err];
  err = nil;
  if (err)
  {
    NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    return;
  }
  
  UInt32 doChangeDefaultRoute = 1;  
  AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                           sizeof (doChangeDefaultRoute),
                           &doChangeDefaultRoute);
  
  BOOL audioHWAvailable = audioSession.inputIsAvailable;
  if (! audioHWAvailable) {
    UIAlertView *cantRecordAlert =
    [[UIAlertView alloc] initWithTitle: @"Warning"
                               message: @"Audio input hardware not available"
                              delegate: nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [cantRecordAlert show];
    return;
  }
  
}

- (void) initializePlaying
{
  NSURL *url = [NSURL fileURLWithPath:[self playSoundPath]];
  NSError *err = nil;
  self.player = [[ AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
  if (err != nil)
  {
    NSLog(@"Play sound file missing!");
    return;
  }
  [self.player setDelegate:self];
  [self.player setVolume:1.0];
//  [self.player setMeteringEnabled:YES];
}

- (void) initializeRecording
{
  NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
  
  [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
  [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
  [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
  
  [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
  [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
  [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
  
  NSURL *url = [NSURL fileURLWithPath:[self recordSoundPath]];
  NSError *err = nil;
  self.recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
  if (!self.recorder)
  {
    NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle: @"Warning"
                               message: [err localizedDescription]
                              delegate: nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  //prepare to record
  [self.recorder setDelegate:self];
  [self.recorder setMeteringEnabled:YES];
  [self.recorder prepareToRecord];
}

- (void)resetAfterRecord
{
  NSError *err = nil;
  if ([[NSFileManager defaultManager] fileExistsAtPath:[self recordSoundPath]])
  {
    if (![[NSFileManager defaultManager] removeItemAtPath:[self playSoundPath] error:&err])
    {
      NSLog(@"Failed to remove old play sound.");
      NSLog(@"%@", err.description);
    }
    if (![[NSFileManager defaultManager] moveItemAtPath:[self recordSoundPath]
                                                 toPath:[self playSoundPath] error:&err])
    {
      NSLog(@"Failed to move record sound to play sound.");
      NSLog(@"%@", err.description);
    }
  }
  [self initializePlaying];
  [self initializeRecording];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
  NSLog (@"audioRecorderDidFinishRecording:successfully:");
  self.recording = NO;
  self.stopping = NO;
  [self resetAfterRecord];
  
  if (playAfterStop)
  {
    playAfterStop = NO;
    [self startPlaying];
  }

  [self configureButtonState];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
  NSLog (@"audioPlayerDidFinishPlaying:successfully:");
  self.playing = NO;
  
  if (recordAfterStop)
  {
    recordAfterStop = NO;
    [self startRecording];
  }
  [self configureButtonState];
}


@end
