//
//  Salvar_Audio.h
//  Recorder2
//
//  Created by Matheus Cardoso on 2/10/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface SaveAudioViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbAudio;
@property (weak, nonatomic) IBOutlet UIButton *btAddAudio;

@end
