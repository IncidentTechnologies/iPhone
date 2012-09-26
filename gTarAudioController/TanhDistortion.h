//
//  TanhDistortion.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//
//  Distortion effect, applies the input signal to a hyperbolic tangent
//  function.
//

#ifndef gTarAudioController_TanhDistortion_h
#define gTarAudioController_TanhDistortion_h

#include "Effect.h"

class TanhDistortion :
public Effect
{
public:
    TanhDistortion (double gain, double wet, double SamplingFrequency) :
    Effect("Distortion", wet, SamplingFrequency)
    {
        m_pPosFactor = new Parameter(1.0, 1.0, 100, "Positive Dist");
        m_pNegFactor = new Parameter(1.0, 1.0, 100, "Negative Dist");
    }
    
    inline double InputSample(double sample)
    {
        double retVal = 0;
        
        if(m_fPassThrough)
            return sample;
        
        float factor;
        if (sample > 0)
        {
            factor = m_pPosFactor->getValue();
            retVal = tanh(factor*sample)/factor;
        }
        else
        {
            factor = m_pNegFactor->getValue();
            retVal = tanh(factor*sample)/factor;
        }
        
        return retVal * 2;
    }
    
    bool setPosFactor(double factor)
    {
        return m_pPosFactor->setValue(factor);
    }
    
    bool setNegFactor(double factor)
    {
        return m_pNegFactor->setValue(factor);
    }
    
    Parameter& getPrimaryParam()
    {
        return *m_pPosFactor;
    }
    
    bool setPrimaryParam(float value)
    {
        return m_pPosFactor->setValue(value);
    }
    
    Parameter& getSecondaryParam()
    {
        return *m_pNegFactor;
    }
    
    bool setSecondaryParam(float value)
    {
        return m_pNegFactor->setValue(value);        
    }
    
    ~TanhDistortion()
    {
        delete m_pPosFactor;
        m_pPosFactor = NULL;
        
        delete m_pNegFactor;
        m_pNegFactor = NULL;
    }
    
private:
    Parameter *m_pPosFactor;
    Parameter *m_pNegFactor;
};


#endif
