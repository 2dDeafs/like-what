//
//  Salvar_Audio.m
//  Recorder2
//
//  Created by Matheus Cardoso on 2/10/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import "SaveAudioViewController.h"

@interface SaveAudioViewController(){
    AVAudioRecorder *recorder;
}

- (IBAction)adicionar:(id)sender;

@property NSMutableArray *directoryContents;

@property (weak, nonatomic) IBOutlet UITextField *lbNomeAudio;
@property (weak, nonatomic) IBOutlet UILabel *lbInstruction;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btRec;
@property (weak, nonatomic) IBOutlet UIButton *btStop;

@end


@implementation SaveAudioViewController

- (void)viewDidLoad
{
    [self btStop].hidden = YES;
    
    if ([self view].tag == 1) {
        [[self navigationItem] setHidesBackButton:YES];
    }
    
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSError *error;
    NSArray *aux = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    _directoryContents = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (NSString *dir in aux) {
        if (![dir hasPrefix:@"."] && [dir hasSuffix:@".m4a"]) {
            [_directoryContents addObject:dir];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)adicionar:(id)sender
{
    if (sender != nil) {
        [self performSegueWithIdentifier:@"saveAudioSegue" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"tableAudioSegue" sender:nil];
    }
}


- (IBAction)Gravar:(id)sender {
    if([_lbNomeAudio.text isEqualToString:@""]){
        [self lbInstruction].text = @"Preencha o nome!";
        [self fadeOut:@"Preencha o nome e clique para gravar"];
    } else {
        
        NSString *nomeAudio = [_lbNomeAudio.text stringByAppendingString:@".m4a"];
        
        if(!recorder.recording){
            
            [self flipImageAndButtons];
            
            [self lbNomeAudio].enabled = NO;
            
            [self lbInstruction].text = @"Clique para parar e salvar";
            
            NSArray *pathComponents = [NSArray arrayWithObjects:
                                       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                       nomeAudio, nil];
            
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

            [recorder prepareToRecord];
            [recorder record];
        }
        else{
            
            [recorder stop];
            
            [self flipImageAndButtons];
            
//            [self lbInstruction].text = @"Arquivo salvo com sucesso!";
        
            [[self directoryContents] addObject: nomeAudio];
            [[self tbAudio] reloadData];
            
            [[self lbNomeAudio] resignFirstResponder];
            [self lbNomeAudio].text = @"";
            [self lbNomeAudio].enabled = YES;
            
//            [self fadeOut:@"Clique para gravar"];
            
            [self adicionar:nil];
        }
    }
}


//  Efeito de "transicao" e inversao de botoes
- (void) flipImageAndButtons
{
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:[[self imageView] image]];
    
    backImageView.center = [self imageView].center;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.65];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:[self imageView]
                             cache:YES];
    
    [backImageView removeFromSuperview];
    [[self imageView] addSubview:backImageView];
    
    [UIView commitAnimations];
    
    [self btRec].hidden = ![self btRec].hidden;
    [self btStop].hidden = ![self btStop].hidden;
}


//  Fadeout texto e fadein outro texto
-(void)fadeOut: (NSString*) texto
{
    [UIView animateWithDuration:1.4 animations:^{
        [self lbInstruction].alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self lbInstruction].text = texto;
        [UIView animateWithDuration:0.5 animations:^{
            [self lbInstruction].alpha = 1.0f;
        } completion:^(BOOL finished) {}];
    }];
}


//  Table view stuffs
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return(@"Lista de sons");
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _directoryContents.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *audiocell = [tableView dequeueReusableCellWithIdentifier:@"celAudio" forIndexPath:indexPath];
    
    UILabel *lblTitle = (UILabel *) [audiocell viewWithTag: 1];
    
    lblTitle.text = [NSString stringWithFormat:@"%@", [_directoryContents objectAtIndex: indexPath.row]];
    
    UISwitch *isOn = [[UISwitch alloc] initWithFrame:CGRectMake(251, 4, 51, 51)];

    [isOn setOnTintColor:[UIColor colorWithRed:0.26 green:0.66 blue:1 alpha:0.75]];
    
    if ([[_directoryContents objectAtIndex:indexPath.row] isEqualToString:@"Default Sounds.m4a"]) {
        [isOn setOn:YES];
    }
    
    [audiocell addSubview:isOn];
    
    return audiocell;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self lbNomeAudio] resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end

