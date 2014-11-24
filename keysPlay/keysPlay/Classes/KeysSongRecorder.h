//
//  KeysSongRecorder.h
//  keysPlay
//
//  Created by Kate Schnippering on 11/24/14.
//
//

#import "AppCore.h"
#import "NSSong.h"
#import "NSMeasure.h"
#import "NSNote.h"

@class NSSong;

// Prevent abuse and other oddities.
// 10 mins
#define MAX_RECORDING_LENGTH 1200

static const int StringToMidiMap[6] = { 52, 57, 62, 67, 71, 76 };
static const int MidiBaseValue = 12; // C0 note
static const char NoteNumberToNoteNameMap[12][3] =
{
    { "C" },  // 12
    { "C#" }, // 13
    { "D" },  // 14
    { "D#" }, // 15
    { "E" },  // 16
    { "F" },  // 17
    { "F#" }, // 18
    { "G" },  // 19
    { "G#" }, // 20
    { "A" },  // 21
    { "A#" }, // 22
    { "B" }   // 23
};

@interface KeysSongRecorder : NSObject
{
    
    double m_tempo;
    double m_currentBeat;
    double m_currentTime;
    
    bool m_isRecording;
    
    NSSong * m_song;
    
    NSMutableArray * m_notes;
}


@property (nonatomic, readonly) NSSong * m_song;
@property (nonatomic, readonly) bool m_isRecording;
@property (nonatomic, readonly) double m_currentTime;

- (KeysSongRecorder*)init;
- (KeysSongRecorder*)initWithTempo:(double)tempo;

- (void)beginSong;
- (void)pauseRecording;
- (void)continueRecording;
- (void)finishSong;
- (void)advanceRecordingByTimeDelta:(double)delta;
- (void)advanceRecordingToTime:(double)time;
- (void)pressKey:(KeyPosition)key;
- (double)convertTimeToBeat:(double)time;
- (void)convertNoteValueString:(char)str andFret:(char)fret inValue:(char*)value;

@end