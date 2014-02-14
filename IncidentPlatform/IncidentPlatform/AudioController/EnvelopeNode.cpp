//
//  EnvelopeNode.m
//  AudioController
//
//  Created by Idan Beck on 2/12/14.
//
//

#include "EnvelopeNode.h"

EnvelopeNode::EnvelopeNode() :
    AudioNode(),
    m_msAttack(0.0f),
    m_AttackLevel(1.0f),
    m_msDecay(0.0f),
    m_SustainLevel(0.5f),
    m_msRelease(0.0f),
    m_CLK(0.0f),
    m_releaseCLK(0.0f)
{
    m_msCLKIncrement = 1.0f / m_SampleRate;
}

void EnvelopeNode::NoteOn() {
    m_CLK = 0;
    m_fNoteOn = true;
}

void EnvelopeNode::NoteOff() {
    m_fNoteOn = false;
    m_releaseCLK = m_msRelease;
}

float EnvelopeNode::GetNextSample(unsigned long int timestamp) {
    float retVal = AudioNode::GetNextSample(timestamp); // first get inputs
    float scaleFactor = 0.0f;
    
    if(m_fNoteOn) {
        if(m_CLK < m_msAttack) {
            
        }
        else if((m_CLK - m_msAttack) < m_msDecay) {
            
        }
        else {
            scaleFactor = m_SustainLevel;
        }
    }
    else {
        if(m_releaseCLK > 0)
            scaleFactor = (m_releaseCLK / m_msRelease);
    }
    
    retVal *= scaleFactor;
    
    return retVal;
}