//
//  ViewController.m
//  Recorder2
//
//  Created by Matheus Cardoso on 2/4/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import "ViewController.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

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

@property (weak, nonatomic) IBOutlet UIImageView *pizzaView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Botao Play oculto
    _btPlay.enabled = NO;
    _btPlay.hidden = YES;
    _btStop.layer.opacity = 0.0;
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"Default Sounds.m4a", nil];
   
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidLoad];
//    
//    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState |  UIViewAnimationOptionRepeat animations:^{
//        _pizzaView.transform = CGAffineTransformMakeRotation(M_PI);
//    } completion:^(BOOL finished){
//        [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//            _pizzaView.transform = CGAffineTransformMakeRotation(0);
//        } completion:nil];
//        
//    }];
}

- (void) startRotationWithDuration: (float) duration
{
	CABasicAnimation *rotation;
	rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotation.fromValue = [NSNumber numberWithFloat:0];
	rotation.toValue = [NSNumber numberWithFloat:((360 * M_PI) / 180)];
	rotation.duration = duration;
	rotation.repeatCount = MAXFLOAT;

	[_btRec.layer addAnimation:rotation forKey:@"360"];
}

- (void) stopRotation
{
    [self changeSize:1.0];
    
    [UIView animateWithDuration:0.5 animations:^{
        _btRec.layer.opacity = 0.0;
        _btStop.layer.opacity = 1.0;
    } completion:^(BOOL finished){
        
        [_btRec.layer removeAnimationForKey:@"360"];
        
        [UIView animateWithDuration:0.5 animations:^{                    _btRec.layer.opacity = 1.0;
            _btStop.layer.opacity = 0.0;
        } completion:^(BOOL finished){
        }];
    }];
}

- (void) changeSize: (float) mult
{
    mult = (mult/100)+1;
    
    [UIView animateWithDuration:0.1 animations:^{
        _btRec.transform = CGAffineTransformMakeScale(mult, mult);
        _btRec.center = _imageView.center;
    }];
}

- (IBAction)RecordStop:(id)sender
{
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        recorder.meteringEnabled = YES;
        [recorder record];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerCicle) userInfo:nil repeats:YES];
        
        [self lbInstruction].text = @"Clique para pausar leitura";
        
        [self startRotationWithDuration:2.0];
        
    } else {
    
        [recorder stop];
        [[self timer] invalidate];
    
        [self btPlay].enabled = YES;
    
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
    
        [self lbInstruction].text = @"Leitura em pausa";
        
        [self stopRotation];
    }
    
}


- (IBAction)StopRec:(id)sender
{
    [recorder stop];
    [[self timer] invalidate];
    
    [self btPlay].enabled = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [self lbInstruction].text = @"Leitura em pausa";
    
}


- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    [_btRec setTitle:@"Record" forState:UIControlStateNormal];

}


- (IBAction)Playing:(id)sender
{
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        
        [player play];
    }
}


-(void) timerCicle
{
    [recorder updateMeters];

    [self changeSize:[recorder peakPowerForChannel:0]];
    
    if ([recorder peakPowerForChannel:0] >= 0.0) {

        //  Identifica se dispositivo é um iPod
        if (![[[self deviceName] substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"iPho"]) {
//            UIAlertView *alerta = [[UIAlertView alloc] initWithTitle: @"Aviso!" message:@"O seu dispositivo está vibrando! Só que não :(." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            
//            [alerta show];
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
    }
    
    
//    NSLog(@"Channel #1: %.5f Peak: %.5f", [self getDecibels:[recorder averagePowerForChannel:0]], [self getDecibels:[recorder peakPowerForChannel:0]]);
    NSLog(@"Channel #1: %.5f Peak: %.5f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0]);
}


//  Efeito de "transicao" e inversao de botoes
- (void) flipImageAndButtons
{
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:[[self imageView] image]];
    
    backImageView.center = [self imageView].center;
    
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:[self imageView]
                             cache:YES];
    
    [backImageView removeFromSuperview];
    [[self imageView] addSubview:backImageView];
    
    [UIView commitAnimations];
    
    [self btRec].hidden = ![self btRec].hidden;
    [self btStop].hidden = ![self btStop].hidden;
}


//  Nome do dispositivo
- (NSString*) deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}


-(float) getDecibels: (float) appleValue
{
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    
    if (appleValue < minDecibels)
    {
        level = 0.0f;
    }
    else if (appleValue >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * appleValue);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    return level;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
