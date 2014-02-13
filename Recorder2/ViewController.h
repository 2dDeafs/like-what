//
//  ViewController.h
//  Recorder2
//
//  Created by Matheus Cardoso on 2/4/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>   //  AudioSession
#import <AudioToolbox/AudioToolbox.h>   //  Vibra iPhone/Vibrate iPhone
#import <sys/utsname.h>                 //  Nome do dispositivo/Name of device
#import <Accelerate/Accelerate.h>

@interface ViewController : UIViewController <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@end
