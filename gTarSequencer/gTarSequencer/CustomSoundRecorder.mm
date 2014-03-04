//
//  CustomSoundRecorder.m
//  Sequence
//
//  Created by Kate Schnippering on 2/7/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomSoundRecorder.h"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

@interface CustomSoundRecorder(){

    AudioController * audioController;
    AudioNode * root;
    
    SampleNode * m_sampNode;
    SamplerNode * m_samplerNode;

    int bankCount;
}

@end

@implementation CustomSoundRecorder

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self)
    {
        
        audioController = nil;
        root = nil;
        m_samplerNode = nil;
        bankCount = -1;
        
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
    if(recorder.recording){
        [recorder stop];
        
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
    }
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
        
        //player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        //[player setDelegate:self];
        //[player play];
        
        NSLog(@"Play audio for sample at %i with length %f",bankCount,m_sampNode->GetLength());
        m_samplerNode->TriggerBankSample(bankCount, 0);
    }
}

-(void)pausePlayback:(float)ms
{
    NSLog(@"Pause playback at %f",ms);
    timePaused = ms;
    m_sampNode->Stop();
}

-(void)unpausePlayback
{
    NSLog(@"Unpause playback from %f",timePaused);
    m_sampNode->Resume();
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

#pragma mark - Audio Controller Sampler

- (void)initAudioForSample
{
    BOOL init = NO;
    
    if(!audioController){
        audioController = [AudioController sharedAudioController];
        root = [[audioController GetNodeNetwork] GetRootNode];
        m_samplerNode = new SamplerNode();
        init=YES;
    }
    
    SamplerBankNode * newBank = NULL;
    
    m_samplerNode->CreateNewBank(newBank);
    
    // Reload sound into bank after new record
    char * filepath = (char *)malloc(sizeof(char) * 1024);
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [paths objectAtIndex:0];
    NSString * filename = [path stringByAppendingPathComponent:defaultFilename];
    
    filepath = (char *) [filename UTF8String];
    
    m_samplerNode->LoadSampleIntoBank(++bankCount, filepath, m_sampNode);
    
    NSLog(@"Init audio for sample at %i",bankCount);
    
    if(init){
        root->ConnectInput(0, m_samplerNode, 0);
        [audioController startAUGraph];
    }
}

- (unsigned long int)fetchAudioBufferSize
{
    return m_sampNode->GetSampleBuffer()->GetByteSize();
}

- (float)fetchSampleRate
{
    return m_sampNode->GetSampleBuffer()->GetSampleRate();
}

- (float *)fetchAudioBuffer
{
    return (float *)m_sampNode->GetSampleBuffer()->GetBufferArray();
}

- (void)setSampleStart:(float)ms
{
    sampleStart = ms;
    m_sampNode->SetStart(ms);
}

- (void)setSampleEnd:(float)ms
{
    sampleEnd = ms;
    m_sampNode->SetEnd(ms);
}

- (float)getSampleLength
{
    return m_sampNode->GetLength();
}

- (float)getSampleRelativeLength
{
    
    float sampleRelativeLength = sampleEnd - sampleStart;
    
    NSLog(@"sampleRelativeLength is now %f",sampleRelativeLength);
    
    if(sampleRelativeLength <= 0){
        return [self getSampleLength]-sampleStart;
    }else{
        return sampleRelativeLength;
    }
    
    
}


@end
