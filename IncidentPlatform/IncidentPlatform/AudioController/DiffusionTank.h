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
    DiffusionTank(double msDelayTime, double feedback, bool posOutputSum, double wet, double SamplingFrequency);
    
    /*inline */double InputSample(double sample);
    /*inline */double GetSample(long offset);
    
private:
    double m_OutputSumSign;
    long m_delayedSampleIndex;
};

#endif
