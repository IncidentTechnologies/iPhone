//
//  AudioNode.cpp
//  AudioController
//
//  Created by Idan Beck on 2/13/14.
//
//

#include "AudioNode.h"
#include <math.h>

/******************************************************/
// AudioNodeConnection
/******************************************************/

AudioNodeConnection::AudioNodeConnection() {

}

AudioNodeConnection::~AudioNodeConnection() {
    
}

RESULT AudioNodeConnection::Disconnect(AudioNodeConnection* audioConn) {
    RESULT r = R_SUCCESS;
    
    // Remove from connection list
    CR(m_connections.Remove((void*)(audioConn), GET_BY_ITEM));
    
Error:
    return r;
}

RESULT AudioNodeConnection::Disconnect() {
    RESULT r = R_SUCCESS;
    
    // Remove from all connections
    for(list<AudioNodeConnection*>::iterator it = m_connections.First(); it != NULL; it++) {
        CR((*it)->Disconnect(this));
    }
    
Error:
    return r;
}

RESULT AudioNodeConnection::Connect(AudioNodeConnection* audioConn) {
    RESULT r = R_SUCCESS;
    
    CR(m_connections.Push(audioConn));
    
Error:
    return r;
}

float AudioNodeConnection::GetNextSample(unsigned long int timestamp) {
    float retVal = 0;
    
    for(list<AudioNodeConnection*>::iterator it = m_connections.First(); it != NULL; it++) {
        retVal += (*it)->m_node->GetNextSample(timestamp);
    }
    
    // apply gain and return
    return (retVal * m_gain);
}


/******************************************************/
// Audio Node
/******************************************************/
AudioNode::AudioNode() :
    m_channel_n(0),
    m_SampleRate(DEFAULT_SAMPLE_RATE),
    m_inputs(NULL),
    m_outputs(NULL)
{
    /* empty stub */
}

float AudioNode::GetNextSample(unsigned long int timestamp) {
    float retVal = 0.0f;
    
    for(int i = 0; i < m_channel_n; i++) {
        retVal += m_inputs[i].GetNextSample(timestamp);
    }
    
    return retVal;
}


// Setting the channel will disconnect all current connections
RESULT AudioNode::SetChannelCount(int channel_n, CONN_TYPE type) {
    RESULT r = R_SUCCESS;
    AudioNodeConnection* connList = ((type == CONN_IN) ? m_inputs : m_outputs);
    
    CBRM((type < CONN_INV), "Only input and output allowed connection types");
    
    if(connList != NULL) {
        for(int i = 0; i < m_channel_n; i++)
            connList[i].Disconnect();
        
        delete [] connList;
        connList = NULL;
    }
    
    if(type == CONN_IN) {
        m_inputs = new AudioNodeConnection[channel_n];
        connList = m_inputs;
    }
    else if(type == CONN_OUT) {
        m_outputs = new AudioNodeConnection[channel_n];
        connList = m_outputs;
    }
    else
        return R_ERROR;
    
    m_channel_n = channel_n;
    
    // Set everything to zero, provide channel id
    for(int i = 0; i < channel_n; i++) {
        memset(&(connList[i]), 0, sizeof(AudioNodeConnection));
        connList[i].m_channel = i;
        connList[i].m_node = this;
        connList[i].m_gain = 1.0f;
    }
       
Error:
    return r;
}

AudioNodeConnection* AudioNode::GetChannel(int chan, CONN_TYPE type) {
    if(chan >= m_channel_n)
        return NULL;
    
    if(type == CONN_OUT)
        return &(m_outputs[chan]);
    else if(type == CONN_IN)
        return &(m_inputs[chan]);
    else
        return NULL;
}

RESULT AudioNode::ConnectInput(int inputChannel, AudioNode *inputNode, int outputChannel) {
    RESULT r = R_SUCCESS;
    
    AudioNodeConnection *inConn = GetChannel(inputChannel, CONN_IN);
    AudioNodeConnection *outConn = inputNode->GetChannel(outputChannel, CONN_OUT);
    
    CBRM((inConn != NULL), "AudioNode: Input channel not found");
    CBRM((outConn != NULL), "AudioNode: Output channel not found");
    
    return inConn->Connect(outConn);
    
Error:
    return r;
}
