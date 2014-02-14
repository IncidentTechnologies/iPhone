//
//  AudioNode.cpp
//  AudioController
//
//  Created by Idan Beck on 2/13/14.
//
//

#include "AudioNode.h"

AudioNode::AudioNode() :
    m_channel_n(0)
{
    /* empty stub */
}

int AudioNode::SetChannelCount(int channel_n) {
    m_channel_n = channel_n;
    return m_channel_n;
}