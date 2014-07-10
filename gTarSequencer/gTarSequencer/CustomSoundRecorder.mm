//
//  CustomSoundRecorder.m
//  Sequence
//
//  Created by Kate Schnippering on 2/7/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomSoundRecorder.h"
#import "SoundMaster_.mm"

@interface CustomSoundRecorder(){

    SoundMaster * soundMaster;
    
    SamplerBankNode * m_sampleBankNode;
    SampleNode * m_sampNode;
    
    int bankCount;
}

@end

@implementation CustomSoundRecorder

@synthesize delegate;
@synthesize recorder;
@synthesize player;

- (id)init
{
    self = [super init];
    if (self)
    {
        defaultFilename = @"CustomSoundPlaceholder.m4a";
        
        NSArray * pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], defaultFilename, nil];
        
        NSURL * outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        NSLog(@"Output file URL is %@",outputFileURL);
        
        // Setup audio session
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        // Define recorder setting
        NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        
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

-(BOOL)isRecording
{
    return recorder.recording;
}

-(void)clearRecord
{
    if(sampleStart > 0 || sampleEnd > 0){
        //[self setSampleStart:0];
        //[self setSampleEnd:0];
        sampleStart = 0;
        sampleEnd = 0;
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
        
        m_sampleBankNode->TriggerSample(0);
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
    //NSLog(@"Playback finished");
    //[delegate playbackDidEnd];
}

#pragma mark - File System
- (void)renameRecordingToFilename:(NSString *)filename;
{
    // Create a subfolder Samples/{Category} if it doesn't exist yet
    NSLog(@"Moving file from %@ to %@.m4a",defaultFilename,filename);
    
    NSString * newFilename = filename;
    newFilename = [@"Samples/Custom_" stringByAppendingString:filename];
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
    
    [self releaseAudioBank];
}

- (void)saveRecordingToFilename:(NSString *)filename
{
    NSString * newFilename = filename;
    newFilename = [@"Samples/Custom_" stringByAppendingString:filename];
    newFilename = [newFilename stringByAppendingString:@".m4a"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Samples"];
    
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];

    NSString * newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:newFilename];
    
    char * pathName = (char *)malloc(sizeof(char) * [newPath length]);
    pathName = (char *) [newPath UTF8String];
    
    NSLog(@"Save path is %@",newPath);
    
    m_sampNode->SaveToFile(pathName, YES);
    
    // Print directory
    
    NSArray * contents = [fm contentsOfDirectoryAtPath:directory error:&err];
    
    for(int i = 0; i < [contents count]; i++){
        NSLog(@"%@",contents[i]);
    }
    
    [self releaseAudioBank];
}

- (void)deleteRecordingFilename:(NSString *)filename
{
    if(filename != nil && [filename length] > 0){
        
        // Create a subfolder Samples/{Category} if it doesn't exist yet
        NSLog(@"Deleting file %@.m4a",filename);
        
        NSString * newFilename = filename;
        newFilename = [@"Samples/Custom_" stringByAppendingString:filename];
        newFilename = [newFilename stringByAppendingString:@".m4a"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSError * err = NULL;
        NSFileManager * fm = [[NSFileManager alloc] init];
        
        NSString * newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:newFilename];
        
        BOOL result = [fm removeItemAtPath:newPath error:&err];
        
        if(!result)
            NSLog(@"Error deleting");
            
    }else{
        
        NSLog(@"Trying to delete a nil file");
        
    }

}

#pragma mark - Audio Controller Sampler

- (void)initAudioForSample
{
    if(!soundMaster){
        soundMaster = [[SoundMaster alloc] init];
    }else{
        // clean up recording
        [self releaseAudioBank];
    }
    
    m_sampleBankNode = [soundMaster generateBank];
    
    // Reload sound into bank after new record
    char * filepath = (char *)malloc(sizeof(char) * 1024);
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [paths objectAtIndex:0];
    NSString * sampleFilename = [path stringByAppendingPathComponent:defaultFilename];
    
    filepath = (char *) [sampleFilename UTF8String];
    
    m_sampleBankNode->LoadSampleIntoBank(filepath, m_sampNode);
    
    [soundMaster reset];
}

-(void)finishAudioInitAfterBufferFlush
{
    

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

-(void)releaseAudio
{
    if(soundMaster){
        [soundMaster releaseBankAndDisconnect:m_sampleBankNode];
    }
}

- (void)releaseAudioBank
{
    if(soundMaster){
        [soundMaster releaseBank:m_sampleBankNode];
    }
}

- (float)getSampleRelativeLength
{
    
    float sampleRelativeLength = sampleEnd - sampleStart;
    
    NSLog(@"sampleRelativeLength is now %f with sampleEnd %f and sampleStart %f",sampleRelativeLength,sampleEnd,sampleStart);
    
    if(sampleRelativeLength <= 0){
        return [self getSampleLength]-sampleStart;
    }else{
        return sampleRelativeLength;
    }
    
    
}


@end
