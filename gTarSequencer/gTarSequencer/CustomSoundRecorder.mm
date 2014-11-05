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

- (id)init
{
    self = [super init];
    if (self)
    {
        defaultFilename = @"CustomSoundPlaceholder.wav";
        
        NSArray * pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], defaultFilename, nil];
        
        NSURL * outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        DLog(@"Output file URL is %@",outputFileURL);
        
        // Setup audio session
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        // Define recorder setting
        NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
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
        
        DLog(@"Recording began");
        
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        
    }else{
        
        DLog(@"Recording paused");
        
        // Pause recording
        [recorder pause];
    }
}

-(void)stopRecord
{
    
    DLog(@"Recording stopped");
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
        DLog(@"Recording finished with success");
    }else{
        DLog(@"Recording finished with no success");
    }
}

#pragma mark - Playback

-(void)startPlayback
{
    if(!recorder.recording){
        
        DLog(@"Playback started");
        
        m_sampleBankNode->TriggerSample(0);
    }
}

-(void)pausePlayback:(float)ms
{
    DLog(@"Pause playback at %f",ms);
    timePaused = ms;
    m_sampNode->Stop();
}

-(void)unpausePlayback
{
    DLog(@"Unpause playback from %f",timePaused);
    m_sampNode->Resume();
}

#pragma mark - File System

- (void)saveRecordingToFilename:(NSString *)filename
{
    DLog(@"Save Recording to Filename %@",filename);
    
    BOOL useBundle = TRUE;
    NSString * newPath;
    
    if(useBundle){
        
        // *** Save Bundle Sound To File
        
        newPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"wav"];
        
        DLog(@"Using Main Bundle Filepath %@",newPath);
        
    }else{
        
        // **** Save Recorded Sound To File
        
        // Save editing changes to file (CustomSoundPlaceholder.wav)
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * path = [paths objectAtIndex:0];
        newPath = [path stringByAppendingPathComponent:defaultFilename];
        
        DLog(@"Using Custom Sound Filepath %@",newPath);
        
        char * pathName = (char *)malloc(sizeof(char) * [newPath length]);
        pathName = (char *) [newPath UTF8String];
        
        m_sampNode->SaveToFile(pathName, YES);
        
    }
    
    // Then get data and upload

    
    NSSample * xmpSample = [[NSSample alloc] initWithName:[NSString stringWithFormat:@"%@.wav", filename] custom:YES value:@"0" xmpFileId:0];
    
    [g_ophoMaster saveSample:xmpSample withFile:data];
    
    // Delete after recording
    [self deleteRecordingFilename:defaultFilename];
    
    // Still need this?
    [self releaseAudioBank];
}

- (void)deleteRecordingFilename:(NSString *)filename
{
    if(filename != nil && [filename length] > 0){
        
        // Create a subfolder Samples/{Category} if it doesn't exist yet
        DLog(@"Deleting file %@.wav",filename);
        
        NSString * newFilename = filename;
        //newFilename = [@"Samples/Custom_" stringByAppendingString:filename];
        //newFilename = [newFilename stringByAppendingString:@".wav"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSError * err = NULL;
        NSFileManager * fm = [[NSFileManager alloc] init];
        
        NSString * newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:newFilename];
        
        BOOL result = [fm removeItemAtPath:newPath error:&err];
        
        if(!result)
            DLog(@"Error deleting");
        
    }else{
        
        DLog(@"Trying to delete a nil file");
        
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
    
    DLog(@"sampleRelativeLength is now %f with sampleEnd %f and sampleStart %f",sampleRelativeLength,sampleEnd,sampleStart);
    
    if(sampleRelativeLength <= 0){
        return [self getSampleLength]-sampleStart;
    }else{
        return sampleRelativeLength;
    }    
}


@end
