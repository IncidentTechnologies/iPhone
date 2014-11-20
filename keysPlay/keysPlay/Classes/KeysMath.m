//
//  KeysMath.m
//  keysPlay
//
//  Created by Kate Schnippering on 11/18/14.
//
//

#import "KeysMath.h"
#import "FrameGenerator.h"

@implementation KeysMath

@synthesize isStandalone;
@synthesize difficulty;
@synthesize songRangeKeyMin;
@synthesize songRangeKeyMax;
@synthesize songRangeKeySize;
@synthesize songRangeNumberOfWhiteKeys;
@synthesize delegate;
@synthesize glScreenWidth;
@synthesize glScreenHeight;

- (id)init
{
    
    self = [super init];
    
    if ( self )
    {
        FrameGenerator * fg = [[FrameGenerator alloc] init];
        
        glScreenHeight = [fg getFullscreenHeight] - GL_SCREEN_TOP_BUFFER;
        glScreenWidth = [fg getFullscreenWidth] - GL_SCREEN_RIGHT_BUFFER;
        
        [self setSongRangeFromMin:0 andMax:KEYS_KEY_COUNT];
        
    }
    
    return self;
    
}

- (void)setSongRangeFromMin:(KeyPosition)keyMin andMax:(KeyPosition)keyMax
{
    
    songRangeKeyMin = MIN(keyMin,[g_keysController range].keyMin);
    songRangeKeyMax = MAX(MAX(keyMin+KEYS_DISPLAYED_NOTES_COUNT,keyMax),[g_keysController range].keyMax);
    songRangeKeySize = songRangeKeyMax-songRangeKeyMin+1;
    songRangeNumberOfWhiteKeys = [self countWhiteKeysFromMin:songRangeKeyMin toMax:songRangeKeyMax];
    
    DLog(@"Setting actual to %i, %i",songRangeKeyMin,songRangeKeyMax);
    
    [delegate displayKeyboardRangeChanged];
    
}

// To adjust key coloring, refer to this mapping function and g_standaloneKeyColors
- (int)getStandaloneKeyFromKey:(int)key
{
    return [self getMappedKeyFromKey:key];
}

-(int)getMappedKeyFromKey:(int)key
{
    if(!isStandalone){
        return key;
    }else if(difficulty == PlayViewControllerDifficultyHard){
        return key % KEYS_OCTAVE_COUNT;
    }else if(difficulty == PlayViewControllerDifficultyMedium){
        return key % 8;
    }else{
        return key % 5;
    }
}

-(int)getNthKeyForWhiteKey:(int)whiteKey
{
    // First determine how many octaves
    int nthKey = floor(whiteKey / KEYS_WHITE_KEY_HARD_COUNT) * KEYS_OCTAVE_COUNT;
    
    int offset = whiteKey % KEYS_WHITE_KEY_HARD_COUNT;
    
    if(offset < 3){
        nthKey += 2*offset;
    }else{
        nthKey += 2*(offset-1)+1;
    }
    
    //DLog(@"white key %i maps to %i",whiteKey,nthKey);
    
    return nthKey;
}

-(int)getWhiteKeyFromNthKey:(int)nthKey
{
    int whiteKey = floor(nthKey / KEYS_OCTAVE_COUNT) * KEYS_WHITE_KEY_HARD_COUNT;
    
    int offset = nthKey % KEYS_OCTAVE_COUNT;
    
    if(offset < 5){
        whiteKey += ceil(offset/2.0);
    }else{
        whiteKey += floor(offset/2.0)+1;
    }
    
    return whiteKey;
}

- (int)countWhiteKeysFromMin:(int)keyMin toMax:(int)keyMax
{
    int whiteKeys = 0;
    
    for(int k = keyMin; k <= keyMax; k++){
        if(![self isKeyBlackKey:k]){
            whiteKeys++;
        }
    }
    
    return whiteKeys;
}


-(BOOL)isKeyBlackKey:(int)key
{
    int mappedKey = (isStandalone) ? [self getMappedKeyFromKey:key] : key%KEYS_OCTAVE_COUNT;
    
    if((mappedKey < 5 && mappedKey%2==0) || (mappedKey >= 5 && mappedKey%2==1)){
        return NO;
    }
    
    return YES;
}

- (CGSize)getWhiteKeyFrameSize:(int)numberOfWhiteKeys inSize:(CGSize)size
{
    float keyGap = 1.0f;
    float whiteKeyFrameWidth = (size.width - (keyGap * (numberOfWhiteKeys - 1))) / numberOfWhiteKeys;
    
    return CGSizeMake(whiteKeyFrameWidth,size.height);
}

- (CGSize)getBlackKeyFrameSize:(int)numberOfWhiteKeys inSize:(CGSize)size
{
    CGSize whiteKeyFrameSize = [self getWhiteKeyFrameSize:numberOfWhiteKeys inSize:size];
    
    return CGSizeMake(DEFAULT_BLACK_KEY_PROPORTION * whiteKeyFrameSize.width, DEFAULT_BLACK_KEY_PROPORTION * whiteKeyFrameSize.height);
}


/*- (double)convertTimeToCoordSpace:(double)delta
{
    return [self convertBeatToCoordSpace:(m_songModel.m_beatsPerSecond * delta)];
}*/

- (double)convertBeatToCoordSpace:(double)beat
{
    double beatsPerScreen = SONG_BEATS_PER_SCREEN;
    
    return -(glScreenHeight - (beat/(GLfloat)beatsPerScreen) * glScreenHeight);
}

- (double)convertCoordSpaceToBeat:(double)coord
{
    return 1 - (coord * (GLfloat)SONG_BEATS_PER_SCREEN) / glScreenHeight;
}

- (double)convertKeyToCoordSpace:(NSInteger)key
{
    int mappedKey = [self getMappedKeyFromKey:key];
    
    // WHITE KEYS
    float numWhiteKeys = KEYS_WHITE_KEY_DISPLAY_COUNT;
    
    if(isStandalone && difficulty == PlayViewControllerDifficultyHard) numWhiteKeys = KEYS_WHITE_KEY_HARD_COUNT;
    if(isStandalone && difficulty == PlayViewControllerDifficultyMedium) numWhiteKeys = KEYS_WHITE_KEY_MED_COUNT;
    if(isStandalone && difficulty == PlayViewControllerDifficultyEasy) numWhiteKeys = KEYS_WHITE_KEY_EASY_COUNT;
    
    GLfloat effectiveScreenWidth = glScreenWidth;
    GLfloat widthPerWhiteKey = effectiveScreenWidth / ((GLfloat)numWhiteKeys);
    
    if(!isStandalone){
        
        int mappedKeyInDisplay = mappedKey % KEYS_DISPLAYED_NOTES_COUNT;
        
        double octaveOffset = floorf(mappedKey / (KEYS_DISPLAYED_NOTES_COUNT)) * numWhiteKeys * widthPerWhiteKey;
        
        int whiteKeys[KEYS_WHITE_KEY_DISPLAY_COUNT] = {0,2,4,5,7,9,11,12,14,16,17,19,21,23};
        int blackKeys[KEYS_BLACK_KEY_DISPLAY_COUNT] = {1,3,6,8,10,13,15,18,20,22};
        int blackKeyPositions[KEYS_BLACK_KEY_DISPLAY_COUNT] = {1,2,4,5,6,8,9,11,12,13};
        
        for(int k = 0; k < KEYS_WHITE_KEY_DISPLAY_COUNT; k++){
            if(whiteKeys[k] == mappedKeyInDisplay){
                return octaveOffset + (k * widthPerWhiteKey) + widthPerWhiteKey/2.0;
            }
        }
        
        for (int j = 0; j < KEYS_BLACK_KEY_DISPLAY_COUNT; j++){
            if(blackKeys[j] == mappedKeyInDisplay){
                return octaveOffset + blackKeyPositions[j] * widthPerWhiteKey;
            }
        }
        
    }else if(difficulty == PlayViewControllerDifficultyHard){
        
        int whiteKeys[KEYS_WHITE_KEY_HARD_COUNT] = {0,2,4,5,7,9,11};
        int blackKeys[KEYS_BLACK_KEY_HARD_COUNT] = {1,3,6,8,10};
        int blackKeyPositions[KEYS_BLACK_KEY_HARD_COUNT] = {1,2,4,5,6};
        
        for(int k = 0; k < KEYS_WHITE_KEY_HARD_COUNT; k++){
            if(whiteKeys[k] == mappedKey){
                return (k * widthPerWhiteKey) + widthPerWhiteKey/2.0;
            }
        }
        
        for (int j = 0; j < KEYS_BLACK_KEY_HARD_COUNT; j++){
            if(blackKeys[j] == mappedKey){
                return blackKeyPositions[j] * widthPerWhiteKey;
            }
        }
        
    }else if(difficulty == PlayViewControllerDifficultyMedium){
        
        int whiteKeys[KEYS_WHITE_KEY_MED_COUNT] = {0,2,4,5,7};
        int blackKeys[KEYS_BLACK_KEY_MED_COUNT] = {1,3,6};
        int blackKeyPositions[KEYS_BLACK_KEY_MED_COUNT] = {1,2,4};
        
        for(int k = 0; k < KEYS_WHITE_KEY_MED_COUNT; k++){
            if(whiteKeys[k] == mappedKey){
                return (k * widthPerWhiteKey) + widthPerWhiteKey/2.0;
            }
        }
        
        for (int j = 0; j < KEYS_BLACK_KEY_MED_COUNT; j++){
            if(blackKeys[j] == mappedKey){
                return blackKeyPositions[j] * widthPerWhiteKey;
            }
        }
        
    }else{
        
        int whiteKeys[KEYS_WHITE_KEY_EASY_COUNT] = {0,2,4};
        int blackKeys[KEYS_BLACK_KEY_EASY_COUNT] = {1,3};
        int blackKeyPositions[KEYS_BLACK_KEY_EASY_COUNT] = {1,2};
        
        for(int k = 0; k < KEYS_WHITE_KEY_EASY_COUNT; k++){
            if(whiteKeys[k] == mappedKey){
                return (k * widthPerWhiteKey) + widthPerWhiteKey/2.0;
            }
        }
        
        for (int j = 0; j < KEYS_BLACK_KEY_EASY_COUNT; j++){
            if(blackKeys[j] == mappedKey){
                return blackKeyPositions[j] * widthPerWhiteKey;
            }
        }
        
    }
    
    // Error!
    return 0;
}

- (double)calculateMaxShiftCoordSpace:(double)currentBeat lengthBeats:(double)lengthBeats
{
    double beatsToShift = ceil(lengthBeats) - currentBeat + SONG_BEATS_PER_SCREEN;
    
    double end = [self convertBeatToCoordSpace:MAX(beatsToShift,0)];
    
    if(lengthBeats - currentBeat <= SONG_BEATS_PER_SCREEN){
        return end;
    }else{
        return end+glScreenHeight;
    }
}

#pragma mark - Drawing

- (void)drawKeyboardInFrame:(UIImageView *)frameView fromKeyMin:(int)keyMin withNumberOfKeys:(int)numberOfKeys andNumberOfWhiteKeys:(int)numberOfWhiteKeys invertColors:(BOOL)invertColors
{
    //int numberOfKeys = KEYS_DISPLAYED_NOTES_COUNT;
    
    // Is key before black key?
    if([self isKeyBlackKey:(keyMin+KEYS_OCTAVE_COUNT-1)]){
        keyMin -= 1;
        numberOfKeys++;
    }
    
    // Always display 2 octaves, from the first note
    //int numberOfWhiteKeys = KEYS_WHITE_KEY_DISPLAY_COUNT;
    
    int keyGap = 1.0;
    
    CGSize size = CGSizeMake(frameView.frame.size.width, frameView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGLayerRef whiteKeyLayer = CGLayerCreateWithContext(context, size, NULL);
    CGLayerRef blackKeyLayer = CGLayerCreateWithContext(context, size, NULL);
    
    CGContextRef whiteKeyContext = CGLayerGetContext(whiteKeyLayer);
    CGContextRef blackKeyContext = CGLayerGetContext(blackKeyLayer);
    
    if(invertColors){
        CGContextSetFillColorWithColor(blackKeyContext, [UIColor colorWithRed:33/255.0 green:45/255.0 blue:49/255.0 alpha:1.0].CGColor);
        CGContextSetFillColorWithColor(whiteKeyContext, [UIColor colorWithRed:70/255.0 green:98/255.0 blue:158/255.0 alpha:1.0].CGColor);
    }else{
        CGContextSetFillColorWithColor(whiteKeyContext, [UIColor whiteColor].CGColor);
        CGContextSetFillColorWithColor(blackKeyContext, [UIColor colorWithRed:70/255.0 green:98/255.0 blue:158/255.0 alpha:1.0].CGColor);
    }
    
    CGSize whiteKeyFrameSize = [self getWhiteKeyFrameSize:numberOfWhiteKeys inSize:size];
    CGSize blackKeyFrameSize = [self getBlackKeyFrameSize:numberOfWhiteKeys inSize:size];
    
    // W tracks the number of white notes being draw
    for (int k = 0, w = 0; k < numberOfKeys; k++)
    {
        // Determine which note is being drawn
        int key = keyMin+k;
        
        if(![self isKeyBlackKey:key]){
            
            // White key, draw and increment white keys
            CGRect keyFrame = CGRectMake(w*whiteKeyFrameSize.width+w*keyGap,0,whiteKeyFrameSize.width,whiteKeyFrameSize.height);
            
            CGContextFillRect(whiteKeyContext, keyFrame);
            
            w++;
            
        }else{
            // Black key, draw between white keys
            
            CGRect keyFrame = CGRectMake(w*whiteKeyFrameSize.width+w*keyGap-blackKeyFrameSize.width/2.0,0,blackKeyFrameSize.width,blackKeyFrameSize.height);
            CGContextFillRect(blackKeyContext, keyFrame);
        }
        
    }
    
    CGContextDrawLayerAtPoint(context, CGPointZero, whiteKeyLayer);
    CGContextDrawLayerAtPoint(context, CGPointZero, blackKeyLayer);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    frameView.image = newImage;
    
    CGLayerRelease(whiteKeyLayer);
    CGLayerRelease(blackKeyLayer);
    UIGraphicsEndImageContext();
    
}


@end
