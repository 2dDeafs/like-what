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
@property (weak, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *lbInstruction;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disable Stop/Play button when application launches
    [self btPlay].enabled = NO;
    [self btStop].hidden = YES;
    
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
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(printAveragePower) userInfo:nil repeats:YES];
        
        [self flipImage:[self imageView] Horizontal:YES];
    }
    
    [self displayInverse];
    [self lbInstruction].text = @"Clique para pausar leituras";
}

- (IBAction)StopRec:(id)sender {
    [recorder stop];
    [[self timer] invalidate];
    
    [self displayInverse];
    [self btPlay].enabled = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [self lbInstruction].text = @"Leitura em pausa";
    
    [self flipImage:[self imageView] Horizontal:YES];
    
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [_btRec setTitle:@"Record" forState:UIControlStateNormal];

}

- (IBAction)Playing:(id)sender {
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        
        [player play];
        
    }
}

- (UIImageView *) flipImage:(UIImageView *)originalImage Horizontal:(BOOL)flipHorizontal {
    if (flipHorizontal) {
        
        originalImage.transform = CGAffineTransformMake(originalImage.transform.a * -1, 0, 0, 1, originalImage.transform.tx, 0);
    }else {
        
        originalImage.transform = CGAffineTransformMake(1, 0, 0, originalImage.transform.d * -1, 0, originalImage.transform.ty);
    }    
    return originalImage; }

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
}


-(void) printAveragePower {
    [recorder updateMeters];
    NSLog(@"Channel #1: %.5f Peak: %.5f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0]);
}

- (void)displayInverse {
    [self btRec].hidden = ![self btRec].hidden;
    [self btStop].hidden = ![self btStop].hidden;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
