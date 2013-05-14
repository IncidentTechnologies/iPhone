//
//  Effect.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#ifndef gTarAudioController_Effect_h
#define gTarAudioController_Effect_h

#include "Parameter.h"

class Effect
{  
public:   
    Effect(std::string name, double wet, double SamplingFrequency) :
    m_name(name),
    m_fPassThrough(false),
    m_SamplingFrequency(SamplingFrequency)
    {
        m_pWet = new Parameter(wet, 0.0, 1.0, "Wet");
    }
    
    virtual double InputSample(double sample) = 0;
    
    bool SetPassThru(bool state)
    {
        m_fPassThrough = state;
        if (state)
        {
            ClearOutEffect();
        }
        return true;
    }
    
    bool SetWet(double wet)
    {
        return m_pWet->setValue(wet);
    }
    
    float GetWet()
    {
        return m_pWet->getValue();
    }
    
    virtual void Reset()
    {
        m_fPassThrough = true;
    }
    
    virtual void ClearOutEffect()
    {
        
    }
    
    virtual ~Effect()
    {
        
    }
    
    std::string getName() {return m_name;};
    virtual Parameter& getPrimaryParam() {/*empty default*/ Parameter *p = new Parameter(0, 0, 0, NULL); return *p; };
    virtual bool setPrimaryParam(float value) {/*empty default*/ return false; };
    virtual Parameter& getSecondaryParam() {/*empty default*/ Parameter *p = new Parameter(0, 0, 0, NULL); return *p; };
    virtual bool setSecondaryParam(float value) {/*empty default*/ return false; };
protected:
    std::string m_name;
    Parameter *m_pWet;
    bool m_fPassThrough;
    double m_SamplingFrequency;
};


#endif
