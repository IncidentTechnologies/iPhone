//
//  AudioController.h
//  AudioJunk1
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAStreamBasicDescription.h"

// iZotope Stuff
#import "iZTrashFX.h"
#import "iZAudioConstants.h"
#import "constants_iZTrashFX.h"

#define IZOTOPE_TRASH_UNLOCK 0x67876765
#define IZOTOPE_BOX_MODELER_UNLOCK 0x63678010

#define MIN_FREQ 50
#define SAMPLING_FREQUENCY 44100

#define CHORUS_EFFECT_MAX_MS_DELAY 100      // maximum chorus delay of 500

#define DELAY_EFFECT_MAX_MS_DELAY 1000

class Effect
{  
public:   
    Effect(double wet, double SamplingFrequency) :
        m_fPassThrough(false),
        m_SamplingFrequency(SamplingFrequency),
        m_wet(wet)
    {
        if(m_wet > 1.0f) m_wet = 1.0f;
        else if(m_wet < 0.0f) m_wet = 0.0f;
    }
    
    virtual double InputSample(double sample) = 0;
    
    bool SetPassThru(bool state){ return (m_fPassThrough = state); }
    
    bool SetWet(double wet)
    {
        if(wet > 1.0f || wet < 0.0f) return false;
        m_wet = wet;
        return true;
    }
    
    ~Effect()
    {
        
    }
    
protected:
    double m_wet;
    bool m_fPassThrough;
    double m_SamplingFrequency;
};

class DistortionEffect :
    public Effect
{
public:
    DistortionEffect(double gain, double wet, double SamplingFrequency) :
        Effect(wet, SamplingFrequency),
        m_gain(gain)
    {
        //if(m_gain > 2.0) m_gain = 2.0f;
        if(m_gain < 1.0) m_gain = 1.0f;
    }
    
    bool SetGain(double gain)
    {
        if(gain < 1.0f) return false;        
        m_gain = gain;
        return true;
    }
    
    double InputSample(double sample)
    {
        if(m_fPassThrough)
            return sample;
        
        double retVal = 0;        
        retVal = (1.0f - m_wet) * (sample) + (m_wet) * (sample * m_gain);        
        return retVal;
    }
    
    ~DistortionEffect()
    {
        /* empty stub */
    }
    
private:
    double m_gain;
};

class DelayEffect :
    public Effect
{
public:
    DelayEffect(int msDelayTime, double feedback, double wet, double SamplingFrequency) :
        Effect(wet, SamplingFrequency),
        m_msDelayTime(msDelayTime),
        m_pDelayLine_n(0),
        m_pDelayLine(NULL),
        m_feedback(feedback)
    {
        if(m_msDelayTime > DELAY_EFFECT_MAX_MS_DELAY) m_msDelayTime = DELAY_EFFECT_MAX_MS_DELAY;
        else if (m_msDelayTime < 0) m_msDelayTime = 0;
        
        if(m_feedback > 0.99f) m_feedback = 0.99f;
        else if(m_feedback < 0.0f) m_feedback = 0.0f;
        
        m_pDelayLine_n = (int)(((double) DELAY_EFFECT_MAX_MS_DELAY / 1000.0f) * m_SamplingFrequency);
        m_pDelayLine = new double[m_pDelayLine_n];
        memset(m_pDelayLine, 0, sizeof(double) * m_pDelayLine_n);
        
        m_pDelayLine_l = (int)(((double)m_msDelayTime / 1000.f) * m_SamplingFrequency);
        m_pDelayLine_c = 0;
    }
    
    double InputSample(double sample)
    {
        double retVal = 0;
        
        if(m_fPassThrough)
            return sample;
        
        long feedBackSampleIndex = m_pDelayLine_c - m_pDelayLine_l;
        if(feedBackSampleIndex < 0)
            feedBackSampleIndex = (m_pDelayLine_c - m_pDelayLine_l) + m_pDelayLine_n;
        float feedBackSample = m_pDelayLine[feedBackSampleIndex];
        
        retVal = (1.0f - m_wet) * sample + m_wet * feedBackSample;
        
        // place the new sample into the circular buffer
        m_pDelayLine[m_pDelayLine_c] = m_feedback * retVal;
        
        m_pDelayLine_c++;
        if(m_pDelayLine_c > m_pDelayLine_n)
            m_pDelayLine_c = 0;
        
        return retVal;
    }
    
    ~DelayEffect()
    {
        if(m_pDelayLine != NULL)
        {
            delete [] m_pDelayLine;
            m_pDelayLine = NULL;
        }
    }
    
private:

    int m_msDelayTime;
    double m_feedback;
    
    long m_pDelayLine_n;
    double *m_pDelayLine;

    long m_pDelayLine_c;
    long m_pDelayLine_l;
};

// Main difference between a chorus and delay is that a chrous does not feedback
// and only plays the input signal again with a delay defined in the chorus
class ChorusEffect :
    public Effect
{
public:
    ChorusEffect(long msDelayTime, double depth, double width, double LFOFreq, double wet, double SamplingFrequency) :
        Effect(wet, SamplingFrequency),
        m_pDelayLine(NULL),
        m_pDelayLine_n(0),
        m_SamplingFrequency(SamplingFrequency),
        m_msDelayTime(msDelayTime),
        m_width(width),
        m_LFOFreq(LFOFreq),
        m_depth(depth)
    {
        if(m_msDelayTime > CHORUS_EFFECT_MAX_MS_DELAY) m_msDelayTime = CHORUS_EFFECT_MAX_MS_DELAY;
        else if(m_msDelayTime < 0) m_msDelayTime = 0;
        
        if(m_depth > 1.0f) m_depth = 1.0f;
        else if(m_depth < 0.0f) m_depth = 0.0f;
        
        if(m_LFOFreq < 0.0f) m_LFOFreq = 0.0f;
        else if(m_LFOFreq > 10.f) m_LFOFreq = 10.0f;
        
        if(m_width < 0.0f) m_width = 0.0f;
        else if(m_width > 1.0f) m_width = 1.0f;
        
        m_pDelayLine_n = (int)(((double) CHORUS_EFFECT_MAX_MS_DELAY / 1000.0f) * m_SamplingFrequency);
        m_pDelayLine = new double[m_pDelayLine_n];
        memset(m_pDelayLine, 0, sizeof(double) * m_pDelayLine_n);
        
        m_pDelayLine_l = (int)(((double)m_msDelayTime / 1000.f) * m_SamplingFrequency);
        m_pDelayLine_c = 0;
    }
    
    bool SetMSDelayTime(long msDelayTime)
    {
        if(msDelayTime > CHORUS_EFFECT_MAX_MS_DELAY || msDelayTime < 0) return false;
        
        m_msDelayTime = msDelayTime;
        m_pDelayLine_l = (int)(((double)m_msDelayTime / 1000.f) * m_SamplingFrequency);
        m_pDelayLine_c = 0;
        
        return true;
    }
    
    bool SetDepth(double depth)
    {
        if(depth < 0.0f || depth > 1.0f) return false;
        m_depth = depth;
        return true;
    }
    
    bool SetLFOFreq(double freq)
    {
        if(freq < 0.0f || freq > 10.0f) return false;
        m_LFOFreq = freq;
        return true;
    }
    
    bool SetWidth(double width)
    {
        if(width < 0.0f || width > 1.0f) return false;
        m_width = width;
        return true;
    }
    
    bool PassThrough(bool state){ return (m_fPassThrough = state); }
    
    double InputSample(double sample)
    {
        double retVal = 0;
        
        if(m_fPassThrough)
            return sample;
        
        // place the new sample into the circular buffer
        m_pDelayLine[m_pDelayLine_c] = sample;
        
        // Get the feedback sample
        static long thetaN = 0;
        double ratio = 1 + m_width * sin(2.0f * M_PI * m_LFOFreq * (double)(thetaN / m_SamplingFrequency));
        
        long ratioL = m_pDelayLine_l * ratio;
        
        long feedBackSampleIndex = m_pDelayLine_c - ratioL;
        if(feedBackSampleIndex < 0)
            feedBackSampleIndex = (m_pDelayLine_c - ratioL) + m_pDelayLine_n;
        float feedBackSample = m_pDelayLine[feedBackSampleIndex];
        
        m_pDelayLine_c++;
        if(m_pDelayLine_c > m_pDelayLine_n)
            m_pDelayLine_c = 0;
        
        // increment theta
        thetaN += 1;
        if(thetaN == m_SamplingFrequency)
            thetaN = 0;
        
        retVal = (1 - m_wet) * sample + m_wet * (sample + m_depth * feedBackSample);
        return retVal;
    }
    
    ~ChorusEffect()
    {
        if(m_pDelayLine != NULL)
        {
            delete [] m_pDelayLine;
            m_pDelayLine = NULL;
        }
    }
    
private:
    double m_SamplingFrequency;
    long m_msDelayTime;

    long m_pDelayLine_n;
    double *m_pDelayLine;
    
    
    long m_pDelayLine_c;
    long m_pDelayLine_l;
    
    double m_depth;
    double m_width;
    double m_LFOFreq;
};

class ButterWorthFilterElement
{
public:
    
    // This will calculate the coefficients for the given order, k, cutoff, and sampling frequency
    // provided
    bool CalculateCoefficients(int k, float cutoff, float SamplingFrequency)
    {
        m_fReady = false;
        
        m_k = k;
        m_SamplingFrequency = SamplingFrequency;
        m_cutoff = 2.0 * M_PI * cutoff;
        double freqRatio = m_SamplingFrequency / cutoff;
        double OmegaPrime = tan(M_PI / freqRatio);
        double c = 1.0 + 2.0*cos((M_PI * (2*m_k + 1)) / (2 * m_order)) * OmegaPrime + pow(OmegaPrime, 2.0);
        
        // Set up A coefficients
        // this assumes m_pAC is a valid 3 length double buffer
        m_pAC[0] = m_pAC[2] = pow(OmegaPrime, 2.0) / c;
        m_pAC[1] = m_pAC[0] * 2.0;
        
        // Set up B coefficients
        // This assumes m_pBC is a valid 3 length double buffer
        m_pBC[0] = 0;           // this coefficient is not used
        m_pBC[1] = (2.0 * (pow(OmegaPrime, 2.0) - 1.0)) / c;
        m_pBC[2] = (1.0 - 2.0*cos((M_PI * (2*m_k + 1)) / (2 * m_order)) * OmegaPrime + pow(OmegaPrime, 2.0)) / c;
        
        
        m_fReady = true;
        return true;
    }
    
    ButterWorthFilterElement(int k, int order, float cutoff, float SamplingFrequency) :
        m_pDelayLine(NULL),
        m_pAC(NULL),
        m_pBC(NULL),
        m_order(2),
        m_k(k),
        m_SamplingFrequency(SamplingFrequency),
        m_pSampleDelay(NULL),
        m_pSampleDelay_n(0),
        m_fReady(false)
    {
        // set up the sample delay line
        //m_pSampleDelay_n = m_order;
        m_pSampleDelay_n = 3;
        m_pSampleDelayCount = 0;
        m_pSampleDelay = new double[m_pSampleDelay_n];
        memset(m_pSampleDelay, 0, sizeof(double) * m_pSampleDelay_n);
        
        m_cutoff = 2.0 * M_PI * cutoff;        
        //double freqRatio = (2.0 * M_PI * m_SamplingFrequency) / m_cutoff;
        double freqRatio = m_SamplingFrequency / cutoff;
        
        // Delay and coefficient lines are as long as the order of the filter
        // adding a bumper of 1 to the end to keep math tidy
        
        //m_pDelayLine_n = m_order;
        m_pDelayLine_n = 2;
        m_pDelayLine = new double[m_pDelayLine_n];
        memset(m_pDelayLine, 0, sizeof(double) * (m_pDelayLine_n));
        
        double OmegaPrime = tan(M_PI / freqRatio);
        double c = 1.0 + 2.0*cos((M_PI * (2*m_k + 1)) / (2 * m_order)) * OmegaPrime + pow(OmegaPrime, 2.0);
            
        // A Coefficients 
        m_pAC = new double[3];
        m_pAC[0] = m_pAC[2] = pow(OmegaPrime, 2.0) / c;
        m_pAC[1] = m_pAC[0] * 2.0;
            
        // B Coefficients
        m_pBC = new double[3];
        m_pBC[0] = 0;           // this coefficient is not used
        m_pBC[1] = (2.0 * (pow(OmegaPrime, 2.0) - 1.0)) / c;
        m_pBC[2] = (1.0 - 2.0*cos((M_PI * (2*m_k + 1)) / (2 * m_order)) * OmegaPrime + pow(OmegaPrime, 2.0)) / c;
        
        m_fReady = true;
    }
    
    ~ButterWorthFilterElement()
    {
        m_fReady = false;
        
        if(m_pDelayLine != NULL)
        {
            delete [] m_pDelayLine;
            m_pDelayLine = NULL;
        }
        
        if(m_pSampleDelay != NULL)
        {
            delete [] m_pSampleDelay;
            m_pSampleDelay = NULL;
        }
        
        if(m_pAC != NULL)
        {
            delete [] m_pAC;
            m_pAC = NULL;
        }
        
        if(m_pBC != NULL)
        {
            delete [] m_pBC;
            m_pBC = NULL;
        }
    }
    
    // Simplification of the InputSamples function
    // creates a delay line of the order of the filter
    // this will return 0 until the line is filled
    double InputSample(double sample)
    {
        double retVal = 0;
        
        // first we shift all of the values to the right
        for(int i = m_order - 1; i > 0; i--)
            m_pSampleDelay[i] = m_pSampleDelay[i - 1];
        m_pSampleDelay[0] = sample;
        
        // Call the input samples routine and return the value
        retVal = InputSamples(m_pSampleDelay, m_pSampleDelay_n);
        
        return retVal;
    }
    
private:
    double InputSamples(double *pSamples, int pSamples_n)
    {
        double retVal = 0;
        
        /*
        if(pSamples_n != m_order)
            return 0;          
         */
        while(!m_fReady);   // wait until the filter is ready
            
        retVal = m_pAC[0]*pSamples[0] + m_pAC[1]*pSamples[1] + m_pAC[2]*pSamples[2] - m_pBC[1]*m_pDelayLine[0] - m_pBC[2]*m_pDelayLine[1];
        
        // prevent clip
        if(retVal > 1.0) 
            retVal = 1.0;
        else if(retVal < -1.0) 
            retVal = -1.0;
        
        // Shift over the delay line
        for(int i = m_order - 1; i > 0; i--)
            m_pDelayLine[i] = m_pDelayLine[i - 1];
        m_pDelayLine[0] = retVal;
        
        return retVal;
    }
    
private:
    int m_order;
    int m_k;
    double m_cutoff;
    double m_SamplingFrequency;
    
    double *m_pDelayLine;
    int m_pDelayLine_n;
    
    double *m_pAC;
    int m_pAC_n;
    
    double *m_pBC;
    int m_pBC_n;   
    
    double *m_pSampleDelay;
    int m_pSampleDelay_n;
    int m_pSampleDelayCount;
    
    bool m_fReady;
};


class ButterWorthFilter
{
public:
    ButterWorthFilter(int order, double cutoff, double SamplingFrequency) :
        m_ppFilters(NULL),
        m_SamplingFrequency(SamplingFrequency),
        m_cutoff(cutoff)
    {
        m_order = order + (order % 2);  // ensure only even orders 
        if(m_order == 0)                // no zero order filters
            m_order = 2;
        
        m_ppFilters_n = m_order / 2;
        
        m_ppFilters = new ButterWorthFilterElement*[m_ppFilters_n];
        
        // order is just a cascade of 2nd order filters
        for(int i = 0; i < m_ppFilters_n; i++)
        {    
            //m_ppFilters[i] = new ButterWorthFilterElement(i, m_order, m_cutoff, m_SamplingFrequency);
            m_ppFilters[i] = new ButterWorthFilterElement(0, 2, m_cutoff, m_SamplingFrequency);
        }         
    }
    
    bool SetCutoff(double cutoff)
    {
        bool retVal = true;
        
        // propogate the change
        for(int i = 0; i < m_ppFilters_n; i++)
            if(!(retVal = m_ppFilters[i]->CalculateCoefficients(0, cutoff, m_SamplingFrequency)))
                 break;
        
        return retVal;
    }
    
    double InputSample(double sample)
    {
        double retVal = sample;
        
        //for(int i = 0; i < m_ppFilters_n; i++)
        
        if((m_order / 2) > m_ppFilters_n)     // error condition!
            return 0;
        
        for(int i = 0; i < (m_order / 2); i++)
            retVal = m_ppFilters[i]->InputSample(retVal);
        
        return retVal;
    }
    
    bool SetOrder(int order)
    {
        // first of all adjust to ensure it's an even order
        int NewOrder = order + (order % 2);

        if(NewOrder == m_order)
            return true;
        
        if((NewOrder / 2) < m_ppFilters_n)
        {
            m_order = NewOrder;
        }
        else
        {
            // We need to create a larger set of filters!
            // delete existing filters
            for(int i = 0; i < m_ppFilters_n; i++)
            {
                if(m_ppFilters[i] != NULL)
                {
                    delete m_ppFilters[i];
                    m_ppFilters[i] = NULL;
                }
            }
            delete [] m_ppFilters;
            
            // create new ones
            m_order = NewOrder;
            m_ppFilters_n = m_order / 2;            
            m_ppFilters = new ButterWorthFilterElement*[m_ppFilters_n];
            
            // order is just a cascade of 2nd order filters
            for(int i = 0; i < m_ppFilters_n; i++)
            {    
                //m_ppFilters[i] = new ButterWorthFilterElement(i, m_order, m_cutoff, m_SamplingFrequency);
                m_ppFilters[i] = new ButterWorthFilterElement(0, 2, m_cutoff, m_SamplingFrequency);
            }  
        }        
        
        return true;
    }
    
    ~ButterWorthFilter()
    {
        if(m_ppFilters != NULL)
        {
            for(int i = 0; i < m_ppFilters_n; i++)
            {
                if(m_ppFilters[i] != NULL)
                {
                    delete m_ppFilters[i];
                    m_ppFilters[i] = NULL;
                }
            }
            
            delete [] m_ppFilters;
            m_ppFilters = NULL;
        }
    }
    
private:
    ButterWorthFilterElement **m_ppFilters;
    int m_ppFilters_n;
    int m_order;
    double m_cutoff;                             // cutoff frequency in HZ (elements convert to radians)
    double m_SamplingFrequency;
    
};

class Oscillator
{
public:
    Oscillator(double frequency, double SamplingFrequency) :
        m_phase(0.0f),
        m_SamplingFrequency(SamplingFrequency),
        m_fNoteOn(false),
        m_frequency(frequency)
    {
        SetAttack(2.0f, 1.0f);
        SetDecay(75.0f);
        SetSustain(0.5f);
        SetRelease(250.0f);
        SetLevel(1.0f);
    }
    
private:
    virtual double GetNextSample() = 0;
    
public:
    double GetSample()
    {
        // Calculate the envelope multiplier
        double env = 1.0f;               
        static double s_curEnvLevel; // for use in the release
        
        if(m_fNoteOn)
        {
            double relTime = (m_NoteOnSampleCount / m_SamplingFrequency) * 1000.0f;         // Envelopes are in ms 
            
            if(relTime > 0 && relTime <= m_msAttack)
            {
                // We're in the attack slope
                double ratio = relTime / m_msAttack;
                env = m_levelAttack * ratio;
            }
            else if(relTime > m_msAttack && relTime <= m_msAttack + m_msDecay)
            {
                // We're in the decay slope
                double adjTime = relTime - m_msAttack;
                double ratio = adjTime / m_msDecay;
                env = m_levelAttack + (m_levelSustain - m_levelAttack) * ratio;
            }
            else if(relTime > m_msAttack + m_msDecay)
            {
                // We're in the sustain slope
                env = m_levelSustain;
            }
            
            s_curEnvLevel = env;
        }
        else
        {
            double relTime = (m_NoteOffSampleCount / m_SamplingFrequency) * 1000.0f;
            if(relTime < m_msRelease)
            {
                double ratio = relTime / m_msRelease;
                env = s_curEnvLevel * (1.0f - ratio);
                m_NoteOffSampleCount++;
            }
            else 
                return 0.0f;
        }

        return m_level * env * GetNextSample();
    }
    
    double SetFrequency(double freq)
    {
        return (m_frequency = freq);
    }
    
    bool SetLevel(double level)
    {
        m_level = level;
        if(m_level > 1.0f) 
            m_level = 1.0f;
        else if(m_level < 0.0f)
            m_level = 0.0f;
        
        return true;
    }
    
    double IncrementPhase()
    {
        m_phase += (m_frequency/2.0f) * (2 * M_PI) / m_SamplingFrequency;
        
        if(m_phase >= 2 * M_PI)
			m_phase = m_phase - 2 * M_PI;

        //if(m_fNoteOn)
            m_NoteOnSampleCount++;
        
        return m_phase;
    }
    
    bool SetPhase(double phase)
    {
        if(phase > 2.0 * M_PI || phase < 0) return false;
        m_phase = phase;
        return true;
    }
    
    bool SetAttack(double delay, double level)
    {
        m_msAttack = delay;
        m_levelAttack = (level > 1.0f) ? 1.0f : 
                        (level < 0.0f) ? 0.0f : level;
        return true;
    }
    
    bool SetDecay(double delay)     //, double level)
    {
        m_msDecay = delay;
        //m_levelDecay = (level > 1.0f) ? 1.0f : (level < 0.0f) ? 0.0f : level;
        return true;
    }
    
    bool SetSustain(/*double delay, */double level)
    {
        //m_msSustain = delay;
        m_levelSustain = (level > 1.0f) ? 1.0f : 
                        (level < 0.0f) ? 0.0f : level;
        return true;
    }
    
    bool SetRelease(double delay)
    {
        m_msRelease = delay;
        return true;
    }
    
    bool NoteOn() 
    { 
        m_NoteOnSampleCount = 0;
        m_phase = 0.0f;
        return (m_fNoteOn = true); 
    }
    
    bool NoteOn(double freq)
    {
        m_frequency = freq;
        return NoteOn();
    }
    
    bool NoteOff() 
    { 
        m_NoteOffSampleCount = 0;
        return (m_fNoteOn = false); 
    }
    
    ~Oscillator()
    {
        
    }
               
private:
    double m_SamplingFrequency;
    double m_phase;
    
    // all values are determined in milliseconds 
    double m_msAttack;
    double m_levelAttack;
    
    double m_msDecay;
    // double m_levelDecay;     // has no level as it goes from the Attack level to the sustain level
    
    //double m_msSustain;       // has no time delay since it will sustain until the note is off
    double m_levelSustain;
    
    double m_msRelease;
    //double m_levelRelease;  // release has no resulting level, it goes to zero
    
    double m_frequency;
    
    double m_level;
    
public:
    bool m_fNoteOn;
    long m_NoteOnSampleCount;
    long m_NoteOffSampleCount;      // for the release 
};

class SineOscillator :
    public Oscillator
{
public:
    SineOscillator(double freq, double SamplingFrequency) :
        Oscillator(freq, SamplingFrequency)
    {
        /* empty stub */
    }
    
private:
    double GetNextSample() 
    {
        return sin(IncrementPhase());
    }
    
    ~SineOscillator()
    {
        /* empty stub */
    }
    
private:
    // empty
};

class SawOscillator :
    public Oscillator
{
public:
    SawOscillator(double freq, double SamplingFrequency) :
        Oscillator(freq, SamplingFrequency)
    {
        /* empty stub */
    }
    
private:
    double GetNextSample() 
    {
        return ((IncrementPhase() / (2 * M_PI)) - 0.5f) * 2.0f;
    }
    
    ~SawOscillator()
    {
        /* empty stub */
    }
    
private:
    // empty
};

class SquareOscillator :
    public Oscillator
{
public:
    SquareOscillator(double freq, double SamplingFrequency) :
        Oscillator(freq, SamplingFrequency)
    {
        /* empty stub */
    }
    
private:
    double GetNextSample() 
    {
        if(IncrementPhase() < M_PI)				
            return 1.0f;			
        else				
            return -1.0f;
    }
    
    ~SquareOscillator()
    {
        /* empty stub */
    }
    
private:
    // empty
};

class KSObject
{
public:
	KSObject() :
		m_BufferKS(NULL),
		m_eBufferKS(0),
		m_FreqKS(0),
		m_Fs(44100.0f),
		m_attenuationKS(0.99f),
        m_pBWFilter(NULL),
        m_bwFltOrder(10),
        m_bwFltCutoff(2000)
	{
        m_BufferKS_n = (int) m_Fs / MIN_FREQ;
        m_BufferKS = new float[m_BufferKS_n];
        memset(m_BufferKS, 0, sizeof(float) * m_BufferKS_n);
        
        // Set up the butterworth filter
        if(m_bwFltOrder > 0)
            m_pBWFilter = new ButterWorthFilter(m_bwFltOrder, m_bwFltCutoff, m_Fs);
        else
            m_pBWFilter = NULL;
	}
	
	KSObject(float SamplingFreq) :
		m_BufferKS(NULL),
		m_eBufferKS(0),
		m_FreqKS(420),
		m_Fs(SamplingFreq),
        m_attenuationKS(0.99f),
        m_pBWFilter(NULL),
        m_bwFltOrder(10),
        m_bwFltCutoff(2000)
	{
		m_BufferKS_n = (int) m_Fs / MIN_FREQ;
        m_BufferKS = new float[m_BufferKS_n];
        memset(m_BufferKS, 0, sizeof(float) * m_BufferKS_n);
        
        // Set up the butterworth filter
        if(m_bwFltOrder > 0)
            m_pBWFilter = new ButterWorthFilter(m_bwFltOrder, m_bwFltCutoff, m_Fs);
        else
            m_pBWFilter = NULL;
	}
	
    // Seed the current buffer with zeros 
    void Kill()
    {
        memset(m_BufferKS, 0, sizeof(m_BufferKS) * m_BufferKS_CurLength);
    }
    
	void Pluck(float freq)
	{
		// set up an example pluck
		m_FreqKS = freq;
		m_BufferKS_CurLength = (int) (m_Fs / m_FreqKS);
		m_eBufferKS = m_BufferKS_CurLength - 1;
		
		srand( time(NULL) );
		
		// Now initialize the delay line buffer with noise
		for(int i = 0; i < m_BufferKS_CurLength; i++)
		{
			float randFloat = (float)rand() / (float)RAND_MAX;      // range of [0, 1]
			float randFloatAdj = (randFloat - 0.5f) * 2.0f;         // converted to a range of [-1, 1]
            m_BufferKS[i] = randFloatAdj;
		}
	}
    
    bool SetBWFilterCutoff(double cutoff)
    {
        m_bwFltCutoff = cutoff;
        if(m_pBWFilter != NULL)
            return m_pBWFilter->SetCutoff(m_bwFltCutoff);
        else 
            return false;
    }
    
    bool SetBWFilterOrder(int order)
    {
        m_bwFltOrder = order;
        if(m_pBWFilter != NULL)
            return m_pBWFilter->SetOrder(order);
        else
            return false;
    }
	
	double GetNextKSSample()
	{
		// first ensure that the pluck is initialized
		if(m_BufferKS == NULL || m_FreqKS == 0)
			return 0;
		
		double CurVal = m_BufferKS[m_eBufferKS];		
        
        int order;
        if(m_bwFltOrder == 0)
            order = 2;
        else
            order = m_bwFltOrder;        
        float *pValArray = new float[order];
        
        for(int i = 0; i < order; i++)
        {
            int SampleIndex = 0;
            if(m_eBufferKS + i >= m_BufferKS_CurLength)
                SampleIndex = m_eBufferKS + i - m_BufferKS_CurLength;
            else
                SampleIndex = m_eBufferKS + i;
            
            if(SampleIndex < m_BufferKS_CurLength)
                pValArray[i] = m_BufferKS[SampleIndex];
            else
            {
                NSLog(@"err: Out of bounds in KS array lookup!");
                pValArray[i] = 0;
            }
        }
		
        float NewValf;
        if(m_bwFltOrder == 0 || m_pBWFilter == NULL)
            NewValf = m_attenuationKS * (0.5 * pValArray[0] + 0.5 * pValArray[1]);
        else
            NewValf = m_attenuationKS * m_pBWFilter->InputSample(CurVal);
		
        // clean up
        delete [] pValArray;
        pValArray = NULL;        
        
		// Now replace the current sample with the filtered one
		m_BufferKS[m_eBufferKS] = NewValf;
		
		m_eBufferKS++;
		if(m_eBufferKS >= m_BufferKS_CurLength)
			m_eBufferKS = 0;	
		
		return CurVal;
	}
	
	~KSObject()
	{	
		if(m_BufferKS != NULL)
		{
			delete [] m_BufferKS;
			m_BufferKS = NULL;
		}
	}
	
private:
	float *m_BufferKS;
	int m_BufferKS_n;
    int m_BufferKS_CurLength;
	int m_eBufferKS;
	float m_FreqKS;
    
    ButterWorthFilter *m_pBWFilter;
    int m_bwFltOrder;
    double m_bwFltCutoff;
    
public:
	float m_Fs;
	
public:
	float m_attenuationKS;
	
public:
	static float GuitarFreqLookup(int string, int fret)
	{
		int midi = 40 + string * 5;
		if(string > 3) 
			midi -= 1;
		
		midi += fret;
		
		// Now we have the midi note we can get the frequency
		// f = Fr * 2^(midi / 12)
		float f = 440.0f * pow(2.0, (float)(midi - 69) / 12.0f);
		
		return f;
	}
};

@interface AudioController : NSObject 
{
	// Audio Graph Members
	AUGraph augraph;
	AudioUnit mixer;
	
	// Audio Stream Descriptors
	CAStreamBasicDescription outputCASBD;

	// Sine Phase Indicator;
	double sinPhase;
	float frequency;
	
	int m_WaveformSelect;
	
	KSObject *m_pksobjects;
	int m_pksobjects_n;
    
    ButterWorthFilter *m_pBwFilter;
    
    bool m_fNoteOn;
    
    ChorusEffect *m_pChorusEffect;
    DelayEffect *m_pDelayEffect;
    DistortionEffect *m_pDistortionEffect;
    
    // iZotope Effects
    iZTrashFX::TrashFXEngine* m_pTFXEngine;
    
    SineOscillator *m_pSineOsc;
    SawOscillator *m_pSawOsc;
    SquareOscillator *m_pSquareOsc;
}

@property (assign) float frequency;
@property (assign) double sinPhase;
@property (assign) bool m_fNoteOn;

- (void) initializeAUGraph:(int)waveform;
- (void) startAUGraph;
- (void) stopAUGraph;

- (void) SetWaveform:(int)WaveformSelect;
- (void) SetWaveFrequency:(float)freq;

- (void) KillString:(int)string;
- (void) PluckStringFret:(int)string atFret:(int)fret;
- (void) SetAttentuation:(float)atten;

- (bool) SetBWCutoff:(double)cutoff;
- (bool) SetBWOrder:(int)order;

- (bool) SetKSBWCutoff:(double)cutoff;
- (bool) SetKSBWOrder:(int)order;

- (bool) NoteOnStringFret:(int)string atFret:(int)fret;
- (bool) NoteOn:(double)freq;
- (bool) NoteOff;


@end
