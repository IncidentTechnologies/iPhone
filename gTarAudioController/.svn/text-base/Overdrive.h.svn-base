//
//  Overdrive.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//
//  Simple overdrive effect. Multiplies the input signal by a gain factor.

#ifndef gTarAudioController_Overdrive_h
#define gTarAudioController_Overdrive_h

#include "Effect.h"

class Overdrive :
public Effect
{
public:
    Overdrive(double gain, double wet, double SamplingFrequency) :
    Effect("Overdrive", wet, SamplingFrequency),
    m_gain(gain)
    {
        if(m_gain < 1.0) m_gain = 1.0f;
    }
    
    bool SetGain(double gain)
    {
        if(gain < 1.0f) return false;        
        m_gain = gain;
        return true;
    }
    
    inline double InputSample(double sample)
    {
        if(m_fPassThrough)
            return sample;
        
        double retVal = 0;        
        retVal = (1.0f - m_pWet->getValue()) * (sample) + (m_pWet->getValue()) * (sample * m_gain);        
        return retVal;
    }
    
    ~Overdrive()
    {
        /* empty stub */
    }
    
private:
    double m_gain;
};

#endif
