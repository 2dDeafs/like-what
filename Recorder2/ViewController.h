//
//  ViewController.h
//  Recorder2
//
//  Created by Matheus Cardoso on 2/4/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController : UIViewController <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@end
