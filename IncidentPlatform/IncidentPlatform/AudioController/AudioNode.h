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
#include "dss_list.h"

#define DEFAULT_SAMPLE_RATE 44100.0f

using namespace dss;

class AudioNode {
    
public:
    AudioNode();
    int SetChannelCount(int channel_n);
    
    RESULT AddInputNode(AudioNode *inputNode);
    RESULT AddOutputNode(AudioNode *outputNode);
    
    virtual float GetNextSample(unsigned long int timestamp);
        
public:
    int m_SampleRate;
    
private:
    int m_channel_n;
    
    list<AudioNode*> m_inputNodes;
    list<AudioNode*> m_outputNodes;
    
    // Make it possible to search for nodes by id or name
    char *m_pszName;
    int m_id;
};

RESULT ConnectNodes(AudioNode *inputNode, AudioNode *outputNode);

#endif /* defined(__AudioController__AudioNode__) */
