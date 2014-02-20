//
//  AudioNodeNetwork.cpp
//  IncidentPlatform
//
//  Created by Idan Beck on 2/18/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#include "AudioNodeNetwork.h"

AudioNodeNetwork::AudioNodeNetwork() :
    m_inputNode(NULL),
    m_outputNode(NULL),
    m_cursorNode(NULL)
{
    // Create output node with one output channel and one input channel
    m_outputNode = new AudioNode();
    m_outputNode->SetChannelCount(1, CONN_OUT);
    //m_outputNode->SetChannelCount(1, CONN_IN);    // let children do this
}

// Ping output node to get the next sample
float AudioNodeNetwork::GetNextSample(unsigned long int timestamp) {
    return m_outputNode->GetNextSample(timestamp);
}