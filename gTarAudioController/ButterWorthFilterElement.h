//
//  ButterWorthFilterElement.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#ifndef gTarAudioController_ButterWorthFilterElement_h
#define gTarAudioController_ButterWorthFilterElement_h

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
    inline double InputSample(double sample)
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
    
    void Reset()
    {
        memset(m_pSampleDelay, 0, sizeof(double) * m_pSampleDelay_n);
        memset(m_pDelayLine, 0, sizeof(double) * (m_pDelayLine_n));
    }
    
private:
    inline double InputSamples(double *pSamples, int pSamples_n)
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

#endif
