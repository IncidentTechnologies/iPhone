//
//  CustomSoundRecorder.h
//  Sequence
//
//  Created by Kate Schnippering on 2/7/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <AVFoundation/AVFoundation.h>
#import "NSSample.h"

@protocol CustomSoundDelegate <NSObject>

- (void)playbackDidEnd;

@end

@interface CustomSoundRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    NSString * defaultFilename;
    
    float timePaused;
    float sampleStart;
    float sampleEnd;
}

- (id)init;
- (void)startRecord;
- (void)stopRecord;
- (void)clearRecord;
- (BOOL)isRecording;
- (void)startPlayback;
- (void)pausePlayback:(float)ms;
- (void)unpausePlayback;
- (void)saveRecordingToFilename:(NSString *)filename;
- (void)deleteRecordingFilename:(NSString *)filename;
- (void)initAudioForSample;
- (unsigned long int)fetchAudioBufferSize;
- (float *)fetchAudioBuffer;
- (float)getSampleLength;
- (float)fetchSampleRate;
- (float)getSampleRelativeLength;
- (void)setSampleStart:(float)ms;
- (void)setSampleEnd:(float)ms;
- (void)releaseAudio;

@property (weak, nonatomic) id<CustomSoundDelegate> delegate;
@property (retain) AVAudioRecorder * recorder;
@property (retain) AVAudioPlayer * player;


@end
