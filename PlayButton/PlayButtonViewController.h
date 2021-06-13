/*
 * This file is part of the PlayButton distribution (https://github.com/samkass/PlayButton).
 * Copyright (c) 2011-2021 Sam Kass.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Non-Copyleft licenses are also available from the Copyright holder.
 */

//  Created by Sam Kass on 6/24/11.


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

