//
//  AudioNode.cpp
//  AudioController
//
//  Created by Idan Beck on 2/13/14.
//
//

#include "AudioNode.h"
#include <math.h>

AudioNode::AudioNode() :
    m_channel_n(0),
    m_SampleRate(DEFAULT_SAMPLE_RATE)
{
    /* empty stub */
}

float AudioNode::GetNextSample(unsigned long int timestamp) {
    float retVal = 0.0f;
    
    for(list<AudioNode*>::iterator it = m_inputNodes.First(); it != NULL; it++)
        retVal += (*it)->GetNextSample(timestamp);
    
    return retVal;
}

int AudioNode::SetChannelCount(int channel_n) {
    m_channel_n = channel_n;
    return m_channel_n;
}

RESULT AudioNode::AddInputNode(AudioNode *inputNode) {
    RESULT r = R_SUCCESS;
 
    CR(m_inputNodes.Push(inputNode));

Error:
    return r;
}

RESULT AudioNode::AddOutputNode(AudioNode *outputNode) {
    RESULT r = R_SUCCESS;
    
    CR(m_outputNodes.Push(outputNode));
    
Error:
    return r;
}

RESULT ConnectNodes(AudioNode *inputNode, AudioNode *outputNode) {
    RESULT r = R_SUCCESS;
    
    CR(outputNode->AddInputNode(inputNode));
    CR(inputNode->AddOutputNode(outputNode));

Error:
    return r;
}