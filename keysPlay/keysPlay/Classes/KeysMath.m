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

@synthesize cameraScale;
@synthesize isStandalone;
@synthesize difficulty;
@synthesize songRangeKeyMin;
@synthesize songRangeKeyMax;
@synthesize songRangeKeySize;
@synthesize songRangeNumberOfWhiteKeys;
@synthesize keyboardPositionKey;
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
        
        [self resetCameraScale];
        
    }
    
    return self;
    
}


- (void)setSongRangeFromMin:(KeyPosition)keyMin andMax:(KeyPosition)keyMax
{
    // Ensure keyMin is a white key
    if([self isKeyBlackKey:keyMin]){
        keyMin--;
    }
    
    // Ensure key range bottom key is a white key
    KeyPosition keyRangeMax = [g_keysController range].keyMax;
    KeyPosition keyRangeMin = [g_keysController range].keyMin;
    if([self isKeyBlackKey:keyRangeMin]){
        keyRangeMin--;
    }
    
    songRangeKeyMin = MIN(keyMin,keyRangeMin);
    songRangeKeyMax = MAX(MAX(keyMin+KEYS_DISPLAYED_NOTES_COUNT,keyMax),keyRangeMax);
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
        keyMin = keyMin-1;
        numberOfKeys++;
    }
    
    // Is next key black key?
    if([self isKeyBlackKey:keyMin+numberOfKeys]){
        numberOfKeys++;
    }
    
    DLog(@"Number of keys is %i, number of white keys is %i",numberOfKeys,numberOfWhiteKeys);
    
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

#pragma mark - Note range and keyboard adjustments

- (BOOL)allNotesOutOfRangeForFrame:(NSNoteFrame *)noteFrame
{
    // TODO: maybe this should go in song model?
    
    KeyPosition noteMin = [g_keysController range].keyMin;
    KeyPosition noteMax = [g_keysController range].keyMax;
    
    for(NSNote * note in noteFrame.m_notes){
        if(note.m_key >= noteMin && note.m_key <= noteMax){
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)noteOutOfRange:(KeyPosition)key
{
    KeyPosition noteMin = [g_keysController range].keyMin;
    KeyPosition noteMax = [g_keysController range].keyMax;
    
    if(key < noteMin || key > noteMax){
        return YES;
    }
    return NO;
}

- (void)expandCameraToMin:(KeyPosition)keyMin andMax:(KeyPosition)keyMax
{
    KeyPosition cameraMin = keyboardPositionKey;
    KeyPosition cameraMax = [self getNthKeyForWhiteKey:[self getWhiteKeyFromNthKey:keyboardPositionKey]+cameraScale*(KEYS_WHITE_KEY_DISPLAY_COUNT)];
    
    if(keyMax != cameraMax || keyMin != cameraMin){
        
        double diff = [self getWhiteKeyFromNthKey:keyMax]-[self getWhiteKeyFromNthKey:cameraMax]+[self getWhiteKeyFromNthKey:cameraMin]-[self getWhiteKeyFromNthKey:keyMin];
        
        double newCameraScale = MIN(MAX_CAMERA_SCALE,MAX(DEFAULT_CAMERA_SCALE,(diff/(double)KEYS_WHITE_KEY_DISPLAY_COUNT)+1));
        
        if(newCameraScale != cameraScale){
            
            DLog(@"Key: %i to %i, camera: %i to %i",keyMin,keyMax,cameraMin,cameraMax);
            
            DLog(@"New camera scale is %f vs %f",newCameraScale,cameraScale);
            
            DLog(@"Updating camera scale to %f = %i-%i/14",cameraScale,[self getWhiteKeyFromNthKey:keyMax],[self getWhiteKeyFromNthKey:cameraMax]);
            
        }
        
        [self animateRefreshKeyboardToKey:keyMin updateCameraScale:newCameraScale];
    }
}

- (void)animateRefreshKeyboardToKey:(int)newKey updateCameraScale:(double)newCameraScale
{
    //cameraScale = newCameraScale;
    
    //[delegate refreshKeyboardToKey:newKey];
    
    int diff = newKey - keyboardPositionKey;
    
    for(int i = 0; i < abs(diff); i++){
        [NSTimer scheduledTimerWithTimeInterval:(i*0.01) target:self selector:@selector(refreshKeyboardAndCamera:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(diff/abs(diff))],@"KeyboardIncrement",[NSNumber numberWithDouble:(newCameraScale-cameraScale)/fabs(diff)],@"CameraIncrement", nil] repeats:NO];
    }
    
}

- (void)refreshKeyboardAndCamera:(NSTimer *)timer
{
    if(timer == nil || [timer userInfo] == nil){
        return;
    }
    
    NSDictionary * userInfo = (NSDictionary *)[timer userInfo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int keyIncrement = [[userInfo objectForKey:@"KeyboardIncrement"] intValue];
        double cameraScaleIncrement = [[userInfo objectForKey:@"CameraIncrement"] doubleValue];
        
        cameraScale += cameraScaleIncrement;
        
        [delegate refreshKeyboardToKey:(keyboardPositionKey+keyIncrement)];
    });
}


- (void)resetCameraScale
{
    cameraScale = DEFAULT_CAMERA_SCALE;
}

@end
