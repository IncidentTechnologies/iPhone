//
//  DiffusionTank.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#ifndef gTarAudioController_DiffusionEffect_h
#define gTarAudioController_DiffusionEffect_h

#include "DelayEffect.h"

/*
 A single diffusion chamber for use in reverberator network. This is basically
 a delay line with a feedback/feedforward network around it. Design taken from
 Jon Datorro's "Effective Design Part 1: Reverberator and Other Filters".
 https://ccrma.stanford.edu/~dattorro/EffectDesignPart1.pdf
 */
class DiffusionTank :
public DelayEffect
{
public:
    DiffusionTank(double msDelayTime, double feedback, bool posOutputSum, double wet, double SamplingFrequency):
    DelayEffect(msDelayTime, feedback, wet, SamplingFrequency)
    {
        if (posOutputSum)
        {
            m_OutputSumSign = 1.0;
        }
        else
        {
            m_OutputSumSign = -1.0;
        }        
    }
    
    inline double InputSample(double sample)
    {
        double retVal = 0;
        
        if(m_fPassThrough)
            return sample;
        
        m_delayedSampleIndex = m_pDelayLine_c - m_pDelayLine_l;
        if(m_delayedSampleIndex < 0)
            m_delayedSampleIndex = m_delayedSampleIndex + m_pDelayLine_n;
        float delayedSample = m_pDelayLine[m_delayedSampleIndex];
        
        // feedback and feedforward
        double intoDelayLine = sample - m_OutputSumSign * delayedSample * m_pFeedback->getValue();
        retVal = delayedSample + m_OutputSumSign * intoDelayLine * m_pFeedback->getValue();
        
        // place the new sample into the circular buffer
        m_pDelayLine[m_pDelayLine_c] = intoDelayLine;
        
        m_pDelayLine_c++;
        if(m_pDelayLine_c >= m_pDelayLine_n)
            m_pDelayLine_c = 0;
        
        return retVal;                
    }
    
    inline double GetSample(long offset)
    {
        long index = m_delayedSampleIndex + offset;
        if (index >= m_pDelayLine_n)
            index -= m_pDelayLine_n;
        
        return m_pDelayLine[index];
    }
    
private:
    double m_OutputSumSign;
    long m_delayedSampleIndex;
};

#endif
