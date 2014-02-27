//
//  CustomSoundRecorder.h
//  Sequence
//
//  Created by Kate Schnippering on 2/7/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CustomSoundDelegate <NSObject>

- (void)playbackDidEnd;

@end

@interface CustomSoundRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder * recorder;
    AVAudioPlayer * player;
    
    NSString * defaultFilename;
}

- (id)init;
- (void)startRecord;
- (void)stopRecord;
- (void)startPlayback;
- (void)pausePlayback;
- (void)unpausePlayback;
- (void)renameRecordingToFilename:(NSString *)filename;
- (void)deleteRecordingFilename:(NSString *)filename;
- (void)initAudioForSample;
- (unsigned long int)fetchAudioBufferSize;
- (float *)fetchAudioBuffer;
- (float)getSampleLength;
- (void)setSampleStart:(float)ms;
- (void)setSampleEnd:(float)ms;

@property (weak, nonatomic) id<CustomSoundDelegate> delegate;



@end
