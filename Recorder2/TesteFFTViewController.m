//
//  TesteFFTViewController.m
//  Recorder2
//
//  Created by Fernando Donini Ramos on 12/02/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import "TesteFFTViewController.h"


@interface TesteFFTViewController ()

@end

@implementation TesteFFTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    
//    vDSP_fft_zrip(setupReal, &A, stride, log2n, FFT_FORWARD);
//    vDSP_fft_zrip(setupReal, &A, stride, log2n, FFT_INVERSE);
}

- (OSStatus) initialize: (double) _sampleRate withBuffer: (uint16_t) _bufferSize
{
    AVAudioRecorder *recorder;
    FFTSetup fftSetup;
    
    /* It's a kind of magic... */
    static DSPDoubleSplitComplex A;
    
    static double *magnitudes;
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryAudioProcessing error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    // Set the audio file == queria um jeito de substituir isso aqui
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"sampleFFT.m4a", nil];
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    
    [recorder prepareToRecord];
    [recorder recordForDuration:1024/(44.1*1024)];
    
    double sampleRate = _sampleRate;
    uint16_t bufferSize = _bufferSize;
    NSInteger peakIndex = 0;
    float frequency = 0.f;
    uint32_t maxFrames = getMaxFramesPerSlice(); // funfa?
    float *displayData = (float*)malloc(maxFrames*sizeof(float));
    bzero(displayData, maxFrames*sizeof(float));
    float log2n = log2f(maxFrames);
    int n = 1 < log2n;
    
    assert(n == maxFrames);
    
    float nOver2 = maxFrames/2;
    
    A.realp = (double*) malloc(nOver2 * sizeof(double));
    A.imagp = (double*) malloc(nOver2 * sizeof(double));
    
    fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    
    magnitudes = (double *)malloc(64 * sizeof(double));
    
    vDSP_fft_zrip(fftSetup, &A, /*stride*/ 1, log2n, FFT_FORWARD);
    
    return noErr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
