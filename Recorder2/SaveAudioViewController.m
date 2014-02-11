//
//  Salvar_Audio.m
//  Recorder2
//
//  Created by Matheus Cardoso on 2/10/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import "SaveAudioViewController.h"

@interface SaveAudioViewController(){

}
@property NSMutableArray *directoryContents;
@end

@implementation SaveAudioViewController


- (void)viewDidLoad
{
    
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSError *error;
    NSArray *aux = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    _directoryContents = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (NSString *dir in aux) {
        if (![dir hasPrefix:@"."]) {
            [_directoryContents addObject:dir];
        }
    }
    //NSLog(@"Arquivos: %d", _directoryContents.count);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end

