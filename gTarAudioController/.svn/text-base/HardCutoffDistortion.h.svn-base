//
//  HardCutoffDistortion.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//
//  Hard cutoff with overdrive. Hard limit the input then scale it up to
//  have the same amplitue as the undistorted input.

#ifndef gTarAudioController_HardCutoffDistortion_h
#define gTarAudioController_HardCutoffDistortion_h

#include "Effect.h"
#include "LocalMax.h"


class HardCutoffDistortion :
public Effect
{
public:
    HardCutoffDistortion (double cutoff, double wet, double SamplingFrequency) :
    Effect("Hard cutoff distortion", wet, SamplingFrequency),
    m_cutoff(cutoff)
    {
        m_pLocalMax = new LocalMax(m_SamplingFrequency);        
    }
    
    bool SetCutoff(double cutoff)
    {
        if(cutoff > 1.0f || cutoff < 0.0) return false;        
        m_cutoff = cutoff;
        return true;
    }
    
    inline double InputSample(double sample)
    {
        if(m_fPassThrough)
            return sample;
        
        double retVal;
        
        // cutoff value will be a percentage (m_cutoff) of the local max
        double currentMax = m_pLocalMax->GetLocalMax(sample);
        double scaledCutoff = currentMax * m_cutoff;
        
        if (sample > scaledCutoff)
        {
            retVal = scaledCutoff;
        }
        else if (sample < -scaledCutoff)
        {
            retVal =  -scaledCutoff;
        }
        else
        {
            retVal = sample;
        }
        
        // scale output so that cutoff is scaled up to inputs max amplitude (local max)
        retVal = retVal/m_cutoff;
        return retVal;
    }
    
    ~HardCutoffDistortion()
    {
        delete m_pLocalMax;
        m_pLocalMax = NULL;
    }
    
private:
    double m_cutoff;
    LocalMax *m_pLocalMax;
};
#endif
