//
//  ViewController.m
//  Recorder2
//
//  Created by Matheus Cardoso on 2/4/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}
@property (weak, nonatomic) IBOutlet UIButton *btRec;
@property (weak, nonatomic) IBOutlet UIButton *btStop;
@property (weak, nonatomic) IBOutlet UIButton *btPlay;
@property (weak, nonatomic) IBOutlet UIButton *btAnalyze;
@property (weak, nonatomic) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disable Stop/Play button when application launches
    _btPlay.enabled = NO;
    _btStop.enabled = NO;
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a", nil];
   
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    
    [recorder prepareToRecord];
    
}


- (IBAction)RecordStop:(id)sender {
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        recorder.meteringEnabled = YES;
        [recorder record];
        [_btRec setTitle:@"Pause" forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(printAveragePower) userInfo:nil repeats:YES];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [_btRec setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    
    
    _btStop.enabled = YES;
    _btPlay.enabled = NO;
}

- (IBAction)StopRec:(id)sender {
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [_btRec setTitle:@"Record" forState:UIControlStateNormal];
    
    _btRec.enabled = YES;
    _btPlay.enabled = YES;
    _btStop.enabled = NO;

}

- (IBAction)Playing:(id)sender {
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        
        [player play];
        
        _btRec.enabled = YES;
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)Analyze:(UIButton *)sender {
    
}

-(void) printAveragePower {
    [recorder updateMeters];
    NSLog(@"Channel #1: %.5f Peak: %.5f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
