//
//  KeysMath.h
//  keysPlay
//
//  Created by Kate Schnippering on 11/18/14.
//
//

#import "AppCore.h"
#import "NSNoteFrame.h"
#import "NSNote.h"

#define DEFAULT_CAMERA_SCALE 1.0
#define MAX_CAMERA_SCALE 2.0
#define FRAME_LOOKAHEAD 5
#define FRAME_LOOKBACK 5

#define SONG_BEATS_PER_SCREEN_VERTICAL 1.5
#define SONG_BEATS_PER_SCREEN_HORIZONTAL 4.0
#define SONG_BEAT_OFFSET_VERTICAL 0.5
#define SONG_BEAT_OFFSET_HORIZONTAL 4.0

#define GL_SCREEN_TOP_BUFFER 46.0
#define GL_SCREEN_RIGHT_BUFFER 20.0
#define GL_SEEK_LINE_Y 56.0
#define GL_SEEK_LINE_X 65.0
#define GL_EDGE_X 30.0
#define GL_TOUCH_AREA_HEIGHT 100.0

#define GL_NOTE_HEIGHT 38.0 //( GL_SCREEN_HEIGHT / 7.0 )
#define GL_STRING_WIDTH ( GL_SCREEN_HEIGHT / 60.0 )

#define GL_SHEET_MUSIC_LEFT_OFFSET 0.0

#define KEYS_TOTAL_WHITE_KEY_COUNT 74

#define KEYS_OCTAVE_COUNT 12
#define KEYS_DISPLAYED_NOTES_COUNT 24
#define KEYS_WHITE_KEY_DISPLAY_COUNT 14
#define KEYS_BLACK_KEY_DISPLAY_COUNT 10

#define KEYS_WHITE_KEY_HARD_COUNT 7
#define KEYS_BLACK_KEY_HARD_COUNT 5
#define KEYS_WHITE_KEY_MED_COUNT 5
#define KEYS_BLACK_KEY_MED_COUNT 3
#define KEYS_WHITE_KEY_EASY_COUNT 3
#define KEYS_BLACK_KEY_EASY_COUNT 2

#define KEYS_SHEET_MUSIC_MIN 36 // Low C
#define KEYS_SHEET_MUSIC_LEDGER_MIN 40 // Low E
#define KEYS_SHEET_MIDDLE_C 60 // Middle C
#define KEYS_SHEET_MIDDLE_C_SHARP 61 // Middle C Sharp
#define KEYS_SHEET_MUSIC_LEDGER_MAX 81 // High A
#define KEYS_SHEET_MUSIC_MAX 83 // High B
#define KEYS_SHEET_MUSIC_NUM_WHITE_KEYS 28

#define DEFAULT_BLACK_KEY_PROPORTION 0.6

enum PlayViewControllerDifficulty
{
    PlayViewControllerDifficultyEasy,
    PlayViewControllerDifficultyMedium,
    PlayViewControllerDifficultyHard
};

extern KeysController * g_keysController;


@protocol KeysMathDelegate <NSObject>

- (void)displayKeyboardRangeChanged;
- (void)refreshKeyboardToKey:(KeyPosition)key;

@end

@interface KeysMath : NSObject
{
    
}

@property (weak, nonatomic) id<KeysMathDelegate>delegate;

@property (nonatomic, assign) double cameraScale;

@property (nonatomic, assign) BOOL isStandalone;
@property (nonatomic, assign) BOOL isSheetMusic;
@property (nonatomic, assign) PlayViewControllerDifficulty difficulty;

@property (nonatomic, assign) KeyPosition songRangeKeyMin;
@property (nonatomic, assign) KeyPosition songRangeKeyMax;
@property (nonatomic, assign) KeyPosition keyboardPositionKey;
@property (nonatomic, assign) int songRangeKeySize;
@property (nonatomic, assign) int songRangeNumberOfWhiteKeys;

@property (nonatomic, readonly) float glScreenWidth;
@property (nonatomic, readonly) float glScreenHeight;

// Song control
- (void)setSongRangeFromMin:(KeyPosition)keyMin andMax:(KeyPosition)keyMax;

// Song math
//- (double)convertTimeToCoordSpace:(double)delta;
- (double)convertBeatToCoordSpace:(double)beat;
- (double)convertCoordSpaceToBeat:(double)coord;
- (double)convertKeyToCoordSpace:(NSInteger)key;
- (double)calculateMaxShiftCoordSpace:(double)currentBeat lengthBeats:(double)lengthBeats;

// Key mapping math
- (int)getStandaloneKeyFromKey:(int)key;
- (BOOL)isKeyBlackKey:(int)key;
- (int)getMappedKeyFromKey:(int)key;
- (int)getNthKeyForWhiteKey:(int)whiteKey;
- (int)countWhiteKeysFromMin:(int)keyMin toMax:(int)keyMax;
- (int)getWhiteKeyFromNthKey:(int)nthKey;
- (CGSize)getWhiteKeyFrameSize:(int)numberOfWhiteKeys inSize:(CGSize)size;
- (CGSize)getBlackKeyFrameSize:(int)numberOfWhiteKeys inSize:(CGSize)size;
- (double)getNoteWidthForNoteDuration:(double)duration;

// Sheet Music
- (NSArray *)getLedgerLines;
- (BOOL)noteFacesUp:(KeyPosition)key;

// Drawing
- (void)drawKeyboardInFrame:(UIImageView *)frameView fromKeyMin:(int)keyMin withNumberOfKeys:(int)numberOfKeys andNumberOfWhiteKeys:(int)numberOfWhiteKeys invertColors:(BOOL)invertColors colorActive:(BOOL)colorActive;

// Zoom and position keyboard, note range checks
- (BOOL)allNotesOutOfRangeForFrame:(NSNoteFrame *)noteFrame;
- (BOOL)noteOutOfRange:(KeyPosition)key;
- (void)expandCameraToMin:(KeyPosition)keyMin andMax:(KeyPosition)keyMax forceRefresh:(BOOL)forceRefresh;
- (void)resetCameraScale;

@end
