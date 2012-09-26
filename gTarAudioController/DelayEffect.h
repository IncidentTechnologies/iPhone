//
//  DelayEffect.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#ifndef gTarAudioController_DelayEffect_h
#define gTarAudioController_DelayEffect_h

#include "Effect.h"

#define DELAY_EFFECT_MAX_MS_DELAY 1000

class DelayEffect :
public Effect
{
public:
    DelayEffect(double msDelayTime, double feedback, double wet, double SamplingFrequency) :
    Effect("Echo", wet, SamplingFrequency),
    m_pDelayLine_n(0),
    m_pDelayLine(NULL)
    {
        m_pDelayTime = new Parameter(msDelayTime, 0.0, DELAY_EFFECT_MAX_MS_DELAY, "Delay");
        m_pFeedback = new Parameter(feedback, 0.0, 0.999, "Feedback");
        
        m_pDelayLine_n = (int)(((double) DELAY_EFFECT_MAX_MS_DELAY / 1000.0f) * m_SamplingFrequency);
        m_pDelayLine = new double[m_pDelayLine_n];
        memset(m_pDelayLine, 0, sizeof(double) * m_pDelayLine_n);
        
        m_pDelayLine_l = (int)((m_pDelayTime->getValue() / 1000.f) * m_SamplingFrequency);
        m_pDelayLine_c = 0;
    }
    
    inline double InputSample(double sample)
    {
        double retVal = 0;
        
        if(m_fPassThrough)
            return sample;
        
        long feedBackSampleIndex = m_pDelayLine_c - m_pDelayLine_l;
        if(feedBackSampleIndex < 0)
            feedBackSampleIndex = (m_pDelayLine_c - m_pDelayLine_l) + m_pDelayLine_n;
        float feedBackSample = m_pDelayLine[feedBackSampleIndex];
        
        float newVal = sample + m_pFeedback->getValue() * feedBackSample;
        retVal = (1.0f - m_pWet->getValue()) * sample + m_pWet->getValue() * newVal;
        
        // place the new sample into the circular buffer
        m_pDelayLine[m_pDelayLine_c] = newVal;
        
        m_pDelayLine_c++;
        if(m_pDelayLine_c >= m_pDelayLine_n)
            m_pDelayLine_c = 0;
        
        return retVal;
    }
    
    bool SetFeedback(double feedback)
    {
        return m_pFeedback->setValue(feedback);
    }
    
    Parameter& getPrimaryParam()
    {
        return *m_pDelayTime;
    }
    
    bool setPrimaryParam(float value)
    {
        if (!m_pDelayTime->setValue(value))
        {
            return false;
        }
        m_pDelayLine_l = (int)((m_pDelayTime->getValue() / 1000.f) * m_SamplingFrequency);
        m_pDelayLine_c = 0;
        return true;
    }
    
    Parameter& getSecondaryParam()
    {
        return *m_pFeedback;
    }
    
    bool setSecondaryParam(float value)
    {
        return SetFeedback(value);
    }
    
    void Reset()
    {
        Effect::Reset();
        memset(m_pDelayLine, 0, sizeof(double) * m_pDelayLine_n);
        setPrimaryParam(25); //delay
        SetFeedback(0.5);
    }
    
    ~DelayEffect()
    {
        delete [] m_pDelayLine;
        m_pDelayLine = NULL;
        
        delete m_pDelayTime;
        m_pDelayTime = NULL;
        
        delete m_pFeedback;
        m_pFeedback = NULL;
    }
    
protected:
    
    Parameter *m_pDelayTime;
    Parameter *m_pFeedback;
    
    long m_pDelayLine_n;
    double *m_pDelayLine;
    
    long m_pDelayLine_c;
    long m_pDelayLine_l;
};


#endif
