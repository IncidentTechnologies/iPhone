//
//  AudioNode.h
//  AudioController
//
//  Created by Idan Beck on 2/13/14.
//
//

#ifndef __AudioController__AudioNode__
#define __AudioController__AudioNode__

#include <iostream>

#define DEFAULT_SAMPLE_RATE 44100.0f

class AudioNode {
    
public:
    AudioNode();
    int SetChannelCount(int channel_n);
    
public:
    int m_SampleRate;
    
private:
    int m_channel_n;
};

#endif /* defined(__AudioController__AudioNode__) */
