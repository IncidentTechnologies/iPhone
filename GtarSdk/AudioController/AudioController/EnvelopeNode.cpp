//
//  EnvelopeNode.m
//  AudioController
//
//  Created by Idan Beck on 2/12/14.
//
//

#include "EnvelopeNode.h"

EnvelopeNode::EnvelopeNode() :
    AudioNode()
{
    /* empty stub */
}


/*
// Audio Render Callback Procedure
// Don't allocate memory, don't take any locks, don't waste time
// TODO: Should put into the pertinent places
static OSStatus renderEnvInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    
	EnvelopeNode *envNode = (EnvelopeNode*)(inRefCon);
	AudioSampleType *outA = (AudioSampleType*)ioData->mBuffers[0].mData;
    
	for(UInt32 i = 0; i < inNumberFrames; i++) {
        outA[i] = (outA[i] / 10); //(SInt16)([genNode GetNextSample] * 32767.0f);
        outA[i] = 0.0f;
    }
    
    NSLog(@"hi");
	
	return noErr;
}

- (void) NoteOn {
    m_CLK = 0.0f;
    m_fNoteOn = true;
}
- (void) NoteOff {
    m_CLK = 0.0f;
    m_fNoteOn = false;
}


-(OSStatus) InitializeChannels {
    OSStatus status;
    
    AudioUnit generatorAudioUnit;
    status = AUGraphNodeInfo(*(m_pAUGraph), m_node, NULL, &generatorAudioUnit);
    NSLog(@"GetGeneratorAudioUnit: %s", CAX4CCString(status).get());
    
    // Set up the render callback struct
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = &renderEnvInput;
    renderCallbackStruct.inputProcRefCon = self;
    
    // Set a callback for the specified node's specified output
    status = AUGraphSetNodeInputCallback(*(m_pAUGraph), m_node, 0, &renderCallbackStruct);
    NSLog(@"Generator: Set Input Callback chn: %d: %s", 0, CAX4CCString(status).get());
    
    printf("Mixer File Format:");
    m_StreamDescription.Print();
    
    // Apply the modified CAStreamBasicDescription to the mixer output bus
    status = AudioUnitSetProperty(generatorAudioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &m_StreamDescription,
                                  sizeof(m_StreamDescription));
    
    NSLog(@"Generator: Set Stream Intput Format chn: %d: %s", 0, CAX4CCString(status).get());
    
    // Apply the modified CAStreamBasicDescription to the mixer output bus
    status = AudioUnitSetProperty(generatorAudioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &m_StreamDescription,
                                  sizeof(m_StreamDescription));
    
    
    NSLog(@"Generator: Set Stream Output Format chn: %d: %s", 0, CAX4CCString(status).get());
    
    
    return status;
}
 */
