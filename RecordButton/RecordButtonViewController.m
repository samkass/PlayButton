//
//  RecordButtonViewController.m
//  RecordButton
//
//  Created by Sam Kass on 6/24/11.
//  Copyright 2011 Aardustry LLC. All rights reserved.
//

#import "RecordButtonViewController.h"

@interface RecordButtonViewController ()

@property (nonatomic) BOOL recording;
@property (nonatomic) BOOL playing;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;

@property (nonatomic) BOOL playAfterStop;
@property (nonatomic) BOOL recordAfterStop;

-(void)configureButtonState;
-(NSString*)recordSoundPath;
-(NSString*)playSoundPath;
- (void)resetAfterRecord;

- (void) initializeAudioSession;
- (void) initializePlaying;
- (void) initializeRecording;

@end

@implementation RecordButtonViewController
@synthesize playButton;
@synthesize recordButton, recordButton2;
@synthesize locked, playAfterStop, recordAfterStop;
@synthesize recording, recorder, player, playing;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  
  [self.player stop];
  
  player = nil;
  recorder = nil;
  
  playing = NO;
  recording = NO;
  playAfterStop = NO;
  recordAfterStop = NO;
}

-(void)viewDidLoad
{
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
  }
  else
  {
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
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
}

-(void)setLocked:(BOOL)newLocked
{
  locked = newLocked;
  [self configureButtonState];
}

-(IBAction)togglePlayButton:(id)sender
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
      [self.player play];
    }
    [self configureButtonState];
  }
}

-(IBAction)toggleRecordButton:(id)sender
{
  if (playing)
  {
    recordAfterStop = YES;
    [self.player stop];
  }
  else
  {
    if (recording)
    {
      [self.recorder stop];
    }
    else
    {
      self.recording = YES;
      [self.recorder record];
    }
    [self configureButtonState];
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
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                       NSUserDomainMask, 
                                                       YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:
          [NSString stringWithFormat:@"PLAY.caf"]];
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
  [self.player setDelegate:self];
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
  [[NSFileManager defaultManager] removeItemAtPath:[self playSoundPath] error:&err];
  [[NSFileManager defaultManager] moveItemAtPath:[self recordSoundPath] 
                                          toPath:[self playSoundPath] error:&err];
  [self initializePlaying];
  [self initializeRecording];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
  NSLog (@"audioRecorderDidFinishRecording:successfully:");
  self.recording = false;
  [self resetAfterRecord];
  
  if (playAfterStop)
  {
    playAfterStop = NO;
    playing = YES;
    [self.player play];
  }

  [self configureButtonState];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
  NSLog (@"audioPlayerDidFinishPlaying:successfully:");
  self.playing = false;
  
  if (recordAfterStop)
  {
    recordAfterStop = NO;
    recording = YES;
    [self.recorder record];
  }
  [self configureButtonState];
}

@end
