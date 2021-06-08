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

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *recordSoundPath;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *playSoundPath;
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
  [super viewDidLoad];
  
  playRecordedAudio = YES;
  audioAssetUrl = nil;
  
  [self initializeAudioSession];
  [self initializePlaying];
  [self initializeRecording];

  [self configureButtonState];
}

-(void)dealloc {
  playAfterStop = NO;
  recordAfterStop = NO;
  [self stopPlaying];
  [self stopRecording];
  
  player = nil;
  recorder = nil;
  playing = NO;
  recording = NO;
  stopping = NO;
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

  recordButton.hidden = locked;
  recordButton2.hidden = locked;
  
  playButton.enabled = [[NSFileManager defaultManager] fileExistsAtPath:self.playSoundPath];
  bool recordButtonEnabled = self.recorder != nil;
  
  recordButton.enabled = recordButtonEnabled;
  recordButton2.enabled = recordButtonEnabled;
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
  
  picker.delegate = self;
  [picker setAllowsPickingMultipleItems: NO];
  picker.prompt =
  NSLocalizedString (@"Select audio to play",
                     "Prompt in media item picker");
  
  [self presentViewController: picker animated: YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection
{  
  [self dismissViewControllerAnimated: YES completion:nil];
  playRecordedAudio = NO;
  audioAssetUrl = [collection.representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
  self.player = nil;
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{  
  [self dismissViewControllerAnimated: YES completion:nil];
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
  NSString *documentsDirectory = paths[0];
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
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:
            [NSString stringWithFormat:@"PLAY.caf"]];
  }
  else
  {
    return audioAssetUrl.absoluteString;
  }
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
      if (self.recorder == nil)
      {
        [self initializeRecording];
      }
      self.recording = [self.recorder record];
    }
  }
}

- (void) stopRecording
{
  if (recording)
  {
    stopping = YES;
    [self.recorder stop];
    playRecordedAudio = YES;
  }
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
      if (self.player == nil)
      {
        [self initializePlaying];
      }
      playing = [self.player play];
    }
  }
}

- (void) stopPlaying
{
  if (playing)
  {
    [self.player stop];
  }
}

- (void) pausePlaying
{
  if (playing)
  {
    [self.player pause];
  }
}


- (void) resumePlaying
{
  if (playing)
  {
    playing = [self.player play];
  }
}


- (void) initializeAudioSession
{
  switch ([[AVAudioSession sharedInstance] recordPermission]) {
    case AVAudioSessionRecordPermissionGranted:
      // Cool.
      break;
    case AVAudioSessionRecordPermissionDenied:
      // Bummer. (self.recorder will eventually be nil and disable the button.)
      break;
    case AVAudioSessionRecordPermissionUndetermined:
      if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
         [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                      if (granted) {
                        // Microphone enabled code. Cool.
                      }
                      else {
                        // Microphone disabled code. We'll find out the bad news later.
                      }
                   }];
      }
      break;
    default:
      break;
  }
  
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  NSError *err = nil;
  [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                withOptions:AVAudioSessionCategoryOptionAllowBluetooth |
                              AVAudioSessionCategoryOptionDefaultToSpeaker
                      error:&err];
  if (err)
  {
    NSLog(@"audioSession: %@ %ld %@", err.domain, (long)err.code, err.userInfo.description);
    return;
  }
  [audioSession setActive:YES error:&err];
  err = nil;
  if (err)
  {
    NSLog(@"audioSession: %@ %ld %@", err.domain, (long)err.code, err.userInfo.description);
    return;
  }
  
  if (! audioSession.inputAvailable) {

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Warning"
                                  message:@"Audio input hardware not available"
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                       actionWithTitle:@"OK"
                       style:UIAlertActionStyleDefault
                       handler:^(UIAlertAction * action)
                       {
                         //Do some thing here
                         [alert dismissViewControllerAnimated:YES completion:nil];
                         
                       }];
    [alert addAction:ok]; // add action to uialertcontroller
    [self presentViewController:alert animated:YES completion:nil];

    return;
  }
  
}

- (void) initializePlaying
{
  NSURL *url = [NSURL fileURLWithPath:self.playSoundPath];
  NSError *err = nil;
  self.player = [[ AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
  if (err != nil)
  {
    NSLog(@"Play sound file missing!");
    return;
  }
  (self.player).delegate = self;
  (self.player).volume = 1.0;
//  [self.player setMeteringEnabled:YES];
}

- (void) initializeRecording
{
  NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
  
  [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
  [recordSetting setValue:@1 forKey:AVNumberOfChannelsKey];
  [recordSetting setValue :@16 forKey:AVLinearPCMBitDepthKey];
  
  NSURL *url = [NSURL fileURLWithPath:self.recordSoundPath];
  NSError *err = nil;
  self.recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
  if (!self.recorder)
  {
    NSLog(@"recorder: %@ %ld %@", err.domain, (long)err.code, err.userInfo.description);
    
    NSString *errorMessage = err.localizedDescription ? err.localizedDescription : @"Unknown Error";
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Warning"
                                  message:errorMessage
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                           [alert dismissViewControllerAnimated:YES completion:nil];
                           
                         }];
    [alert addAction:ok]; // add action to uialertcontroller
    [self presentViewController:alert animated:YES completion:nil];
    return;
  }
  
  //prepare to record
  (self.recorder).delegate = self;
//  [self.recorder setMeteringEnabled:YES];
  [self.recorder prepareToRecord];
}

- (void)resetAfterRecord
{
  NSError *err = nil;
  if ([[NSFileManager defaultManager] fileExistsAtPath:self.recordSoundPath])
  {
    if (![[NSFileManager defaultManager] removeItemAtPath:self.playSoundPath error:&err])
    {
      NSLog(@"Failed to remove old play sound.");
      NSLog(@"%@", err.description);
    }
    if (![[NSFileManager defaultManager] moveItemAtPath:self.recordSoundPath
                                                 toPath:self.playSoundPath error:&err])
    {
      NSLog(@"Failed to move record sound to play sound.");
      NSLog(@"%@", err.description);
    }
  }
  [self initializePlaying];
  [self initializeRecording];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)successful
{
  if (!recording)
  {
    return;
  }
  NSLog (@"audioRecorderDidFinishRecording:successfully:");
  self.recording = NO;
  self.stopping = NO;
  if (successful)
  {
    [self resetAfterRecord];
  }
  
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
