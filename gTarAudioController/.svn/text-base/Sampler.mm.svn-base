//
//  Sampler.m
//  gTarAudioController
//
//  Created by Franco Cedano on 1/10/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "Sampler.h"
#import <dispatch/dispatch.h>

@implementation Sampler

@synthesize monoStreamFormat;
@synthesize stereoStreamFormat;
@synthesize m_samplePackName;
@synthesize m_firstNoteMidiNum;
@synthesize m_numberOfSamples;
@synthesize m_tuning;
@synthesize m_standardTunning;
@synthesize m_instruments;
@synthesize m_currentSamplePackIndex;

-(id) init
{
    return [self initWithSampleRate:44100 AndSamplePack:nil];
}

- (id) initWithSampleRate:(int)sampleRate AndSamplePack:(NSString *)name
{
    self = [super init];
    
    if(self)
    {
        m_currentSamplePackIndex = -1;
        
        m_sampleRate = sampleRate;
        
        m_standardTunning = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:5],
                             [NSNumber numberWithInt:10],
                             [NSNumber numberWithInt:15],
                             [NSNumber numberWithInt:19],
                             [NSNumber numberWithInt:24],
                             nil];
        
        if (![self loadInstrumentArray])
        {
            NSLog(@"loadInstrumentArray failed to load instrument array from instrument.plist");
            [self release];
            return nil;
        }
        
        [self setupMonoStreamFormat];
        [self setupStereoStreamFormat];
        
        if (![self loadSamplerWithName:name])
        {
            NSLog(@"Sampler initialization failed");
            [self release];
            return nil;
        }
    }
    
    return self;
}

// Extract the array of instrument data in instrument.plist
- (bool) loadInstrumentArray
{
    // load the plist file
    NSError *error = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"instruments.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"instruments" ofType:@"plist"];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"instruments" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];

    NSDictionary *plistDict = (NSDictionary *) [NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    
    if (!plistDict)
    {
        NSLog(@"Error reading plist: %@, format: %d", [error localizedDescription], format);
        [error release];
        return false;
    }
    
    [error release];
    
    // get sample pack info from plist
    self.m_instruments = [plistDict objectForKey:@"instruments"];
    return true;
    
}

// Initialize the sampler with data from the sample pack with the given name.
// *currently there this synchronous version of 'load sampler by name' is needed
// only on init, there are some issues with instantiating a Sampler object in
// an asynchronous fasion, in general an asynchronous constructor presents a few problems,
// we should revisit this in the future.
- (bool) loadSamplerWithName:(NSString*)name
{
    int samplePackNum = [self getSamplePackNumFromName:name];
    if (-1 == samplePackNum)
    {
        // No match found, use default (whatever is at index 0)
        NSLog(@"No sample pack found with name %@. Using default sample pack", name);
        samplePackNum = 0;
    }
    
    if (m_currentSamplePackIndex == samplePackNum)
    {
        // this sample pack is already loaded
        NSLog(@"The sample pack is already loaded");
        return true;
    }
    
    if (![self loadSamplerWithIndex:samplePackNum])
    {
        NSLog(@"loadSamplerWithIndex failed for instrumentNum:%d", samplePackNum);
        return false;   
    };
    
    return true;
}

// Initialize the sampler with data from the sample pack at the given index
- (bool) loadSamplerWithIndex:(int)index
{
    m_currentSamplePackIndex = index;
    
    [self releaseAudioData];
    
    if (![self loadSamplePackMetaData:index])
    {
        NSLog(@"loadSamplePackMetaData failed for instrumentNum:%d", index);
        return false;
    }
    
    [self obtainSoundFileURLs];
    
    if (![self readAudioFilesIntoMemory])
    {
        NSLog(@"readAudioFilesIntoMemory failed");
        return false;
    }
    
    [self setupMappingArray];
    
    return true;
}

// Asynchronously loads the sampler with the given name. The name can be the sampler name or it's
// 'friendly name', and the name match will happen in that order.
- (void) asynchLoadSamplerWithName:(NSString*)name withSelector:(SEL)aSelector andOwner:(NSObject*)parent
{
    int samplePackNum = [self getSamplePackNumFromName:name];
    if (-1 == samplePackNum)
    {
        // No match found
        NSLog(@"No sample pack found with name %@.", name);
        // Although the load was technically not successful, return true so that the
        // caller can stop waiting for a new load to happen and can restart use of the
        // AudioController
        [self finishedLoadingSamplePack:true withSelector:aSelector andOwner:parent];
        return;
    }
    
    [self asynchLoadSamplerWithIndex:samplePackNum withSelector:aSelector andOwner:parent];
}

- (void) asynchLoadSamplerWithIndex:(int)index withSelector:(SEL)aSelector andOwner:(NSObject*)parent
{
    NSLog(@"Asynchronously loading sample pack at index: %d", index);
    
    if (m_currentSamplePackIndex == index)
    {
        // This sample pack is already loaded
        [self finishedLoadingSamplePack:true withSelector:aSelector andOwner:parent];
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("com.incident.app",NULL);
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        m_pendingLoads++;
        @synchronized(self)
        {
            m_pendingLoads--;
            BOOL result = [self loadSamplerWithIndex:index] ? YES : NO;
            
            dispatch_async(main, ^{
                [self finishedLoadingSamplePack:result withSelector:aSelector andOwner:parent];
            });
        }
    });
}

- (void) finishedLoadingSamplePack:(BOOL)result withSelector:(SEL)aSelector andOwner:(NSObject*)parent
{
    [parent performSelector:aSelector withObject:[NSNumber numberWithBool:result]];    
}

// Finds the index of the sample pack in m_instruments array matching the
// given name. First we try to match the 'name' key of the instrument, if
// that fails we try to match the 'friendly name' key if it exist.
// return - The index in m_instruments array or -1 on error or no match.
- (int) getSamplePackNumFromName:(NSString*)name
{
    if (nil == name)
    {
        return -1;
    }
    
    for (int i = 0; i < m_instruments.count; i++)
    {
        if ([name caseInsensitiveCompare:[[m_instruments objectAtIndex:i] objectForKey:@"Name"]] == NSOrderedSame)
        {
            return i;
        }
        else if ([name caseInsensitiveCompare:[[m_instruments objectAtIndex:i] objectForKey:@"FriendlyName"]] == NSOrderedSame)
        {
            return i;
        }
    }
    
    // Could not find a matching instrument name
    return -1;
}

// Loads parameters from instruments.plist needed to load samples and init the sampler.
// instrumentNum is the 0 based position of the instrument to be loaded as arranged in
// the plist file.
- (bool) loadSamplePackMetaData:(int)samplePackNum
{
    NSDictionary *selectedInstrument = [m_instruments objectAtIndex:samplePackNum];
    self.m_samplePackName = [selectedInstrument objectForKey:@"Name"];
    if (nil == m_samplePackName)
    {
        NSLog(@"Error: could not find objectForKey:'Name' for instrument #:%d", samplePackNum);
        return false;
    }
    m_firstNoteMidiNum = [[selectedInstrument objectForKey:@"FirstNoteMidiNum"] intValue];
    m_numberOfSamples = [[selectedInstrument objectForKey:@"NumNotes"] intValue];
    m_tuning = [selectedInstrument objectForKey:@"Tuning"];
    if (nil == m_tuning)
    {
        self.m_tuning = m_standardTunning;
    }
    
    m_sampleNameArray = new CFURLRef[m_numberOfSamples];
    m_soundStructArray = new soundStruct[m_numberOfSamples];
    
    for (int i= 0; i <  m_numberOfSamples; i++)
    {
        m_soundStructArray[i].audioDataLeft = NULL;
        m_soundStructArray[i].audioDataRight = NULL;
    }
    
    return true;
}

- (void) obtainSoundFileURLs
{
    // Create the URLs for the source audio files.
    for (int noteNum = m_firstNoteMidiNum; noteNum < m_firstNoteMidiNum + m_numberOfSamples; noteNum++)
    {
        
        NSString *filename = [NSString stringWithFormat:@"%@ %d", m_samplePackName, noteNum];
        
        NSURL *url = [[NSBundle mainBundle] URLForResource: filename
                                             withExtension: @"mp3"];

        
        m_sampleNameArray[noteNum - m_firstNoteMidiNum] = (CFURLRef) [url retain];
    }
}

- (void) setupMonoStreamFormat
{
    // The AudioSampleType data type is the recommended type for sample data input.
    // This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioSampleType);
    
    // Fill the application audio format struct's fields to define a linear PCM, 
    //        stereo, noninterleaved stream at the hardware sample rate.
    monoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    monoStreamFormat.mFormatFlags       = kLinearPCMFormatFlagIsSignedInteger;
    monoStreamFormat.mBytesPerPacket    = bytesPerSample;
    monoStreamFormat.mFramesPerPacket   = 1;
    monoStreamFormat.mBytesPerFrame     = bytesPerSample;
    monoStreamFormat.mChannelsPerFrame  = 1;                  // 1 indicates mono
    monoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    monoStreamFormat.mSampleRate        = m_sampleRate;
}

- (void) setupStereoStreamFormat
{
    // The AudioSampleType data type is the recommended type for sample data input
    // This obtains the byte size of the type for use in filling in the ASBD.
    
    // Fill the application audio format struct's fields to define a linear PCM, 
    //        stereo, noninterleaved stream at the hardware sample rate.
    stereoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags       = kLinearPCMFormatFlagIsSignedInteger;
    stereoStreamFormat.mChannelsPerFrame  = 2;                    // 2 indicates stereo
    stereoStreamFormat.mFramesPerPacket   = stereoStreamFormat.mChannelsPerFrame;
    stereoStreamFormat.mBytesPerPacket    = 2 * stereoStreamFormat.mChannelsPerFrame;
    stereoStreamFormat.mBytesPerFrame     = 2 * stereoStreamFormat.mChannelsPerFrame;
    stereoStreamFormat.mBitsPerChannel    = 16;
    stereoStreamFormat.mSampleRate        = m_sampleRate;
}

- (bool) readAudioFilesIntoMemory
{
    for (int noteNum=0; noteNum < m_numberOfSamples; noteNum++)
    {
        if (m_pendingLoads > 0)
        {
            // A new more recent sample pack load has been requested. 
            // Bail out of the current load, no need to clean up allocated
            // sample data here, each thread cleans up odl data
            // before loading new data
            NSLog(@"bailing readAudioFilesIntoMemory on noteNum:%d", noteNum);
            return false;
        }
        
        // Instantiate an extended audio file object.
        ExtAudioFileRef audioFileObject = 0;
        
        NSLog(@"Opening URL: %@", m_sampleNameArray[noteNum]);
        
        // Open an audio file and associate it with the extended audio file objects;
        OSStatus result = ExtAudioFileOpenURL(m_sampleNameArray[noteNum], &audioFileObject);
        
        if (noErr != result || NULL == audioFileObject) {[self printErrorMessage: @"ExtAudioFileOpenURL" withStatus: result]; return false;}
        
        // Get the audio file's length in frames.
        UInt64 totalFramesInFile = 0;
        UInt32 frameLengthPropertySize = sizeof (totalFramesInFile);
        
        result =    ExtAudioFileGetProperty (
                                             audioFileObject,
                                             kExtAudioFileProperty_FileLengthFrames,
                                             &frameLengthPropertySize,
                                             &totalFramesInFile
                                             );
        
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileGetProperty (audio file length in frames)" withStatus: result]; return false;}
        
        // Assign the frame count to the soundStructArray instance variable
        m_soundStructArray[noteNum].frameCount = totalFramesInFile;
        
        // Get the audio file's number of channels.
        AudioStreamBasicDescription fileAudioFormat = {0};
        UInt32 formatPropertySize = sizeof (fileAudioFormat);
        
        result =    ExtAudioFileGetProperty (
                                             audioFileObject,
                                             kExtAudioFileProperty_FileDataFormat,
                                             &formatPropertySize,
                                             &fileAudioFormat
                                             );
        
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileGetProperty (file audio format)" withStatus: result]; return false;}
        
        // Force mono for now, TODO test ability to read stereo
        UInt32 channelCount = 1;//fileAudioFormat.mChannelsPerFrame;
        
        // Allocate memory in the soundStructArray instance variable to hold the left channel, 
        //    or mono, audio data
        m_soundStructArray[noteNum].audioDataLeft =
        (AudioSampleType *) calloc (totalFramesInFile, sizeof (AudioSampleType));
        
        AudioStreamBasicDescription importFormat = {0};
        
        m_soundStructArray[noteNum].audioDataRight = NULL;
        if (2 == channelCount)
        {
            
            m_soundStructArray[noteNum].isStereo = YES;
            // Sound is stereo, so allocate memory in the soundStructArray instance variable to  
            //    hold the right channel audio data
            m_soundStructArray[noteNum].audioDataRight =
            (AudioSampleType *) calloc (totalFramesInFile, sizeof (AudioSampleType));
            importFormat = stereoStreamFormat;
            
        }
        else if (1 == channelCount)
        {
            importFormat = monoStreamFormat;
            m_soundStructArray[noteNum].audioDataRight = NULL;
        }
        else
        {
            NSLog (@"*** WARNING: File format not supported - wrong number of channels");
            ExtAudioFileDispose (audioFileObject);
            return false;
        }
        
        // Assign the appropriate mixer input bus stream data format to the extended audio 
        //        file object. This is the format used for the audio data placed into the audio 
        //        buffer in the SoundStruct data structure, which is in turn used in the 
        //        inputRenderCallback callback function.
        
        result =    ExtAudioFileSetProperty (
                                             audioFileObject,
                                             kExtAudioFileProperty_ClientDataFormat,
                                             sizeof (importFormat),
                                             &importFormat
                                             );
        
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileSetProperty (client data format)" withStatus: result]; return false;}
        
        // Set up an AudioBufferList struct, which has two roles:
        //
        //        1. It gives the ExtAudioFileRead function the configuration it 
        //            needs to correctly provide the data to the buffer.
        //
        //        2. It points to the soundStructArray[audioFile].audioDataLeft buffer, so 
        //            that audio data obtained from disk using the ExtAudioFileRead function
        //            goes to that buffer
        
        // Allocate memory for the buffer list struct according to the number of 
        //    channels it represents.
        AudioBufferList *bufferList;
        
        bufferList = (AudioBufferList *) malloc (
                                                 sizeof (AudioBufferList) + sizeof (AudioBuffer) * (channelCount - 1)
                                                 );
        
        if (NULL == bufferList) {NSLog (@"*** malloc failure for allocating bufferList memory"); return false;}
        
        // initialize the mNumberBuffers member
        bufferList->mNumberBuffers = channelCount;
        
        // initialize the mBuffers member to 0
        AudioBuffer emptyBuffer = {0};
        size_t arrayIndex;
        for (arrayIndex = 0; arrayIndex < channelCount; arrayIndex++)
        {
            bufferList->mBuffers[arrayIndex] = emptyBuffer;
        }
        
        // set up the AudioBuffer structs in the buffer list
        bufferList->mBuffers[0].mNumberChannels  = 1;
        bufferList->mBuffers[0].mDataByteSize    = totalFramesInFile * sizeof (AudioSampleType);
        bufferList->mBuffers[0].mData            = m_soundStructArray[noteNum].audioDataLeft;
        
        if (2 == channelCount)
        {
            bufferList->mBuffers[1].mNumberChannels  = 1;
            bufferList->mBuffers[1].mDataByteSize    = totalFramesInFile * sizeof (AudioSampleType);
            bufferList->mBuffers[1].mData            = m_soundStructArray[noteNum].audioDataRight;
        }
        
        // Perform a synchronous, sequential read of the audio data out of the file and
        //    into the soundStructArray[audioFile].audioDataLeft and (if stereo) .audioDataRight members.
        UInt32 numberOfPacketsToRead = (UInt32) totalFramesInFile;
        
        result = ExtAudioFileRead (
                                   audioFileObject,
                                   &numberOfPacketsToRead,
                                   bufferList
                                   );
        
        free (bufferList);
        
        if (noErr != result)
        {
            [self printErrorMessage: @"ExtAudioFileRead failure - " withStatus: result];
            
            // If reading from the file failed, then free the memory for the sound buffer.
            free (m_soundStructArray[noteNum].audioDataLeft);
            m_soundStructArray[noteNum].audioDataLeft = NULL;
            
            if (2 == channelCount) {
                free (m_soundStructArray[noteNum].audioDataRight);
                m_soundStructArray[noteNum].audioDataRight = NULL;
            }
            
            ExtAudioFileDispose (audioFileObject);            
            return false;
        }
        
        //NSLog (@"Finished reading file for note number:%i into memory", noteNum);
        
        // Dispose of the extended audio file object, which also closes the associated file.
        ExtAudioFileDispose (audioFileObject);
    }
    
    return true;
}

// Set up the mapping from the m_soundMappingArray representing each fret position on a 
// guitar to the note/sample on a sample board (keyboard) it should play.
- (void) setupMappingArray
{
    for (int string = 0; string < 6; string++)
    {
        for (int fret = 0; fret <= 16; fret++)
        {
            int noteNum = [[m_tuning objectAtIndex:string] intValue] + fret;
            m_soundMappingArray[string][fret] = &m_soundStructArray[noteNum];
        }
        
        // turn off all channels (strings on a guitar) initially
        m_channelOn[string] = false;
        // turn on the 0 position (open string) for each channel
        m_channelPositions[string][0] = true;
        // Set the sample index to zero, so that playback starts at the 
        // beginning of the sound.
        m_sampleNumber[string] = 0;
        // initialize the volume and attenuation
        m_volume[string] = 1;
        m_attenuation[string] = 0;
    }
}

- (void) PluckString:(int)string atFret:(int)fret
{
    // turn on this channel (string) and reset the sample number
    m_channelOn[string] = true;
    m_sampleNumber[string] = 0;
    m_channelPositions[string][fret] = true;
    // clear out any fret down bools for positions higher than 'fret'
    for (int i = fret + 1; i <= 16; i++)
    {
        m_channelPositions[string][i] = false;
    }
}

- (void) PluckMutedString:(int)string
{
    if (string < 3)
    {
        m_attenuation[string] = 0.0007;
    }
    else
    {
        m_attenuation[string] = 0.00082;
    }
    
    [self PluckString:string atFret:0];
    m_sampleNumber[string] = 5512;
}

- (float) getNextSample
{
    float retSample = 0.0;
    for (int string = 0; string < 6; string++)
    {
        if (m_channelOn[string])
        {
            int fret = -1;
            // find the highest 'active' position (fret) on the current channel,
            // this will be the one to play
            for (int i = 16; i >= 0; i--)
            {
                if (m_channelPositions[string][i])
                {
                    fret = i;
                    break;
                }
            }
            
            if (fret == -1)
            {
                NSLog(@"Did not find active fret for channel:%d", string);
                return 0;
            }
            
            // Get the sample number, as an index into the sound stored in memory,
            //    to start reading data from.
            UInt32 sampleNumber = m_sampleNumber[string]++;
            
            AudioSampleType *audioData = (AudioSampleType *)m_soundMappingArray[string][fret]->audioDataLeft;
            if (NULL == audioData)
            {
                NSLog(@"Null audioData in sample for string:%d, fret:%d", string, fret);
                return retSample;
            }
            
            // We do the conversion from SInt16 to float for every sample here. We previously did the
            // conversion once and stored audio data as a float to avoid doing the conversion everytime
            // and save on CPU cycles. However, storing the data as a float requires 2x the size
            // (float is 32bits vs SInt16 is 16bit), and for sample packs of ~100Mb uncompressed in memory,
            // this put us close to the apps memory limits.
            retSample += ((float)audioData[sampleNumber]/32767.0f) * m_volume[string];
            
            m_volume[string] -= m_attenuation[string];
            
            // After reaching the end of the sound stored in memory--that is, after
            //    (frameTotalForSound / inNumberFrames) invocations of this callback--loop back to the 
            //    start of the sound so playback resumes from there.
            if (sampleNumber >= m_soundMappingArray[string][fret]->frameCount)
            {
                m_sampleNumber[string] = 0;
                m_channelPositions[string][fret] = false;
                m_channelOn[string] = false;
            }
            else if (0.01 >= m_volume[string])
            {
                m_sampleNumber[string] = 0;
                m_channelPositions[string][fret] = false;
                m_channelOn[string] = false;
                m_volume[string] = 1;
                m_attenuation[string] = 0;
            }
        }
    }
    
    return retSample;
}

- (void) Reset
{
    // reset the sample position for all samples to 0 and turn off all channels
    memset(m_sampleNumber, 0, sizeof(m_sampleNumber[0]) * 6);
    memset(m_channelOn, false, sizeof(m_channelOn));
}

- (void) FretDown:(int)fret onString:(int)string
{
    m_channelPositions[string][fret] = true;
}

- (void) FretUp:(int)fret onString:(int)string
{
    m_channelPositions[string][fret] = false;
}

// Stop playing the note indicated by the string and fret position
- (void) noteOffAtString:(int)string andFret:(int)fret
{
    m_attenuation[string] = 0.0003;
}

- (int) getCurrentSamplePackIndex
{
    return m_currentSamplePackIndex;
}

// Returns an array of NSStrings containing the name of each sample instrument.
// If the instrumetn contains a Friendly Name it will return that, otherwise
// the main name will be used.
- (NSArray*) getInstrumentNames
{
    NSMutableArray *instrumentNames = [[NSMutableArray alloc] init];
    for (NSDictionary *instrument in m_instruments) 
    {
        NSString *name = [instrument objectForKey:@"FriendlyName"];
        if (nil == name)
        {
            name = [instrument objectForKey:@"Name"];
        }
        [instrumentNames addObject:name];
    }
    
    return [instrumentNames autorelease];
}

- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result
{
    char resultString[5];
    UInt32 swappedResult = CFSwapInt32HostToBig (result);
    bcopy (&swappedResult, resultString, 4);
    resultString[4] = '\0';
    
    NSError * error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                          code:result
                                      userInfo:nil];
    
    NSLog(@"err issss OSStatus: %@", [error description]);
    
    NSLog (
           @"*** %@ error: %d %08X %4.4s\n",
           errorString,
           (char*) &resultString
           );
}

- (void) releaseAudioData
{
    for (int noteNum = 0; noteNum < m_numberOfSamples; noteNum++)
    {  
        if (m_sampleNameArray[noteNum] != NULL)
        {
            //[(NSURL *)m_sampleNameArray[noteNum] release];
            CFRelease (m_sampleNameArray[noteNum]);
        }
        
        if (m_soundStructArray[noteNum].audioDataLeft != NULL)
        {
            free (m_soundStructArray[noteNum].audioDataLeft);
            m_soundStructArray[noteNum].audioDataLeft = NULL;
        }
        
        if (m_soundStructArray[noteNum].audioDataRight != NULL)
        {
            free (m_soundStructArray[noteNum].audioDataRight);
            m_soundStructArray[noteNum].audioDataRight = NULL;
        }
    }
    
    delete[] m_sampleNameArray;
    delete[] m_soundStructArray;
}

-(void) dealloc
{
    [self releaseAudioData];
    [m_tuning release];
    [m_standardTunning release];
    
    [super dealloc];
}

@end
