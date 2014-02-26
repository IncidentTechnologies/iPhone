//
//  CustomSoundRecorder.m
//  Sequence
//
//  Created by Kate Schnippering on 2/7/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomSoundRecorder.h"

@implementation CustomSoundRecorder

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self)
    {
        
        defaultFilename = @"CustomSoundPlaceholder.m4a";
        
        //NSArray * pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], defaultFilename, nil];
        
        NSArray * pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], defaultFilename, nil];
        
        //NSArray * pathComponent = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES)] count:defaultFilename, nil];
        
        
        NSURL * outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        NSLog(@"Output file URL is %@",outputFileURL);
        
        // Setup audio session
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        // Define recorder setting
        NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];
        
        // Initiate and prepare the recorder
        recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
    }
    return self;
}

#pragma mark - Recording

-(void)startRecord
{
    
    if(!recorder.recording){
        
        NSLog(@"Recording began");
        
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
    }else{
        
        NSLog(@"Recording paused");
        
        // Pause recording
        [recorder pause];
    }
}

-(void)stopRecord
{
    
    NSLog(@"Recording stopped");
    
    [recorder stop];
    
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}

#pragma mark - Audio Recorder Delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if(flag){
        NSLog(@"Recording finished with success");
    }else{
        NSLog(@"Recording finished with no success");
    }
}

#pragma mark - Playback

-(void)startPlayback
{
    if(!recorder.recording){
        
        NSLog(@"Playback started");
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

-(void)pausePlayback
{
    NSLog(@"Pause playback");
    [player pause];
}

-(void)unpausePlayback
{
    NSLog(@"Unpause playback");
    [player play];
}

#pragma mark - Audio Player Delegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Playback finished");
    [delegate playbackDidEnd];
}

#pragma mark - File System
- (void)renameRecordingToFilename:(NSString *)filename;
{
    // Create a subfolder Samples/{Category} if it doesn't exist yet
    NSLog(@"Moving file from %@ to %@.m4a",defaultFilename,filename);
    
    NSString * newFilename = filename;
    newFilename = [@"Samples/" stringByAppendingString:filename];
    newFilename = [newFilename stringByAppendingString:@".m4a"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Samples"];
    
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSString * currentPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:defaultFilename];
    NSString * newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:newFilename];
    
    BOOL result = [fm moveItemAtPath:currentPath toPath:newPath error:&err];
    
    if(!result)
        NSLog(@"Error moving");
}

- (void)deleteRecordingFilename:(NSString *)filename
{
    
    // Create a subfolder Samples/{Category} if it doesn't exist yet
    NSLog(@"Deleting file %@.m4a",filename);
    
    NSString * newFilename = filename;
    newFilename = [@"Samples/" stringByAppendingString:filename];
    newFilename = [newFilename stringByAppendingString:@".m4a"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    NSString * newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:newFilename];
    
    BOOL result = [fm removeItemAtPath:newPath error:&err];
    
    if(!result)
        NSLog(@"Error deleting");

}

@end
