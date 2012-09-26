//
//  FirstOrderFilter.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#ifndef gTarAudioController_FirstOrderFilter_h
#define gTarAudioController_FirstOrderFilter_h

#include "Effect.h"

/*
 A simple filter that feeds back the previous sample times
 a feedback factor and adds it to the current sample.
 */
class FirstOrderFilter :
public Effect
{
public:
    FirstOrderFilter(double feedback, double wet, double SamplingFrequency) :
    Effect("1st order filter", wet, SamplingFrequency),
    m_previousSample(0),
    m_feedback(feedback)
    {
        
    }
    
    inline double InputSample(double sample)
    {
        double retVal = 0;
        
        if(m_fPassThrough)
            return sample;
        
        double output = sample + m_feedback * m_previousSample;
        m_previousSample = output;
        
        retVal = (1 - m_pWet->getValue()) * sample + m_pWet->getValue() * output;
        return retVal;
    }
    
    bool SetFeedback(double feedback)
    {
        m_feedback = feedback;
        return true;
    }
    
private:
    double m_previousSample;
    double m_feedback;
};

#endif
