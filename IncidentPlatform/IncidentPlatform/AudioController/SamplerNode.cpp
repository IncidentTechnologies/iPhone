//
//  SamplerNode.cpp
//  IncidentPlatform
//
//  Created by Idan Beck on 2/19/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#include "SamplerNode.h"
#include "SampleNode.h"

/******************************/
// Sampler Bank Node
/******************************/

SamplerBankNode::SamplerBankNode() :
    AudioNodeNetwork()
{
    
}

SamplerBankNode::~SamplerBankNode() {
    
}

RESULT SamplerBankNode::TriggerSample(int sample) {
    RESULT r = R_SUCCESS;
    
    CBRM(sample < m_samples.length(), "SamplerBankNode: Not that many samples!");
    m_samples[sample]->Trigger();
    
Error:
    return r;
}

RESULT SamplerBankNode::LoadSampleIntoBank(char *pszFilepath) {
    RESULT r = R_SUCCESS;
    
    SampleNode *newSample = new SampleNode(pszFilepath);
    
    // Check, connect, and push the new sample
    CNRM(newSample, "SamplerBankNode: Failed to create sample");
    CRM(m_outputNode->ConnectInput(0, newSample, 0), "SamplerBankNode: Failed to connect new sample node to output");
    CRM(m_samples.Push(newSample), "SamplerBankNode: Failed to add sample to bank");
    
    return r;
    
Error:
    
    // Gotta watch fails hard here (big memory leaks possible)
    if(newSample != NULL) {
        delete newSample;
        newSample = NULL;
    }
    return r;
}

float SamplerBankNode::GetNextSample(unsigned long int timestamp) {
    float retVal = 0.0f;
    
    return retVal;
}

SampleNode* SamplerBankNode::operator[](const int& i) {
    if(i < m_samples.length())
        return m_samples[i];
    else
        return NULL;
}

/******************************/
// Sampler Node
/******************************/

SamplerNode::SamplerNode() :
    AudioNodeNetwork()
{
    
}

SamplerNode::~SamplerNode() {
    
}

RESULT SamplerNode::CreateNewBank(SamplerBankNode *outBank){
    RESULT r = R_SUCCESS;
    
    SamplerBankNode *newBank = new SamplerBankNode();
    CNRM(newBank, "SamplerNode: Failed to allocate new bank");
    CNRM(m_outputNode->ConnectInput(0, newBank, 0), "SamplerNode: Failed to connect bank output to Sampler output");
    
Error:
    return r;
}

RESULT SamplerNode::TriggerBankSample(int bank, int sample) {
    RESULT r = R_SUCCESS;
    
    
    
Error:
    return r;
}

float SamplerNode::GetNextSample(unsigned long int timestamp) {
    float retVal = 0.0f;
    
    return retVal;
}


