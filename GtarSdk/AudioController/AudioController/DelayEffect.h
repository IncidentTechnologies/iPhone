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
    DelayEffect(double msDelayTime, double feedback, double wet, double SamplingFrequency);
    
    inline double InputSample(double sample);
    
    bool SetFeedback(double feedback);
    
    Parameter& getPrimaryParam();
    
    bool setPrimaryParam(float value);
    
    Parameter& getSecondaryParam();
    
    bool setSecondaryParam(float value);
    
    void Reset();
    
    void ClearOutEffect();
    
    ~DelayEffect();
    
protected:
    
    Parameter *m_pDelayTime;
    Parameter *m_pFeedback;
    
    long m_pDelayLine_n;
    double *m_pDelayLine;
    
    long m_pDelayLine_c;
    long m_pDelayLine_l;
};


#endif
