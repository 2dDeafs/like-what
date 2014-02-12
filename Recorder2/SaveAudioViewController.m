//
//  Salvar_Audio.m
//  Recorder2
//
//  Created by Matheus Cardoso on 2/10/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import "SaveAudioViewController.h"
#import "ViewController.h"

@interface SaveAudioViewController(){
    AVAudioRecorder *recorder;
}

- (IBAction)adicionar:(id)sender;

@property NSMutableArray *directoryContents;
@property BOOL isAdding;
@property (weak, nonatomic) IBOutlet UITextField *lbNomeAudio;
@property (weak, nonatomic) IBOutlet UIButton *btGravarAudio;

@end


@implementation SaveAudioViewController

- (void)viewDidLoad
{
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


- (IBAction)adicionar:(id)sender {
    [self performSegueWithIdentifier:@"saveAudioSegue" sender:nil];
}


- (IBAction)Gravar:(id)sender {
    if([_lbNomeAudio.text isEqualToString:@""]){
        UIAlertView *alerta = [[UIAlertView alloc] initWithTitle: @"Aviso!" message:@"Você deve informar um nome para o áudio." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alerta show];
    }
    
    else{
        
        NSString *nomeAudio = [_lbNomeAudio.text stringByAppendingString:@".m4a"];
        if(!recorder.recording){
            
            [_btGravarAudio setTitle:@"Parar e Salvar" forState:UIControlStateNormal];
            
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
            
            UIAlertView *alerta = [[UIAlertView alloc] initWithTitle: @"Salvo" message:@"O Arquivo foi salvo com sucesso" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alerta show];
        
            [[self directoryContents] addObject: nomeAudio];
            [[self tbAudio] reloadData];
            [[self lbNomeAudio] resignFirstResponder];
            [_btGravarAudio setTitle:@"Iniciar Gravação" forState:UIControlStateNormal];
            [self adicionar:nil];
        }

    }
    
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
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
    
    NSLog(@"%d", indexPath.row);
    
    return audiocell;

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender
{
    if([[segue identifier] isEqualToString:@"saveAudioSegue"])
    {
        ViewController *svad = (ViewController *)segue.destinationViewController;
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self lbNomeAudio] resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end

