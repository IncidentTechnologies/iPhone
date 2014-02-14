//
//  WavetableOscillatorNode.m
//  AudioController
//
//  Created by Idan Beck on 2/12/14.
//
//

#include "WavetableNode.h"

WavetableNode::WavetableNode() :
    GeneratorNode(),
    m_frequency(440.0f),
    m_phase(0.0f),
    m_theta(0.0f),
    m_type(WAVETABLE_SINE)
{
    SetChannelCount(1);
}

float WavetableNode::GetNextSample(unsigned long int timestamp) {
    float retVal = 0.0f;
    float radianValue = (m_theta + m_phase) * m_frequency;
    
    switch(m_type) {
        case WAVETABLE_SINE: {
            retVal = sin(radianValue);
        } break;
            
        case WAVETABLE_SQUARE: {
            if( (int)(radianValue / M_PI) % 2 == 0)
                retVal = -1.0f;
            else
                retVal = 1.0f;
        } break;
            
        case WAVETABLE_SAW: {
            retVal = ((radianValue / (2.0f * M_PI)) - 0.5f) * 2.0f;
        } break;
            
        case WAVETABLE_TRIANGLE: {
            if( (int)(radianValue / M_PI) % 2 == 0)
                retVal = radianValue / M_PI;
            else
                retVal = ((2.0f * M_PI) - radianValue) / M_PI;
        } break;
        
        default: {
            retVal = 0.0f;
        }
    }
    
    m_theta += ((2.0f * M_PI) / m_SampleRate);
    if(m_theta >= 2.0f * M_PI)
        m_theta -= 2.0f * M_PI;
    
    return retVal;
}
