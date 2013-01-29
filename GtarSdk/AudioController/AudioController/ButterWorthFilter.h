//
//  ButterWorthFilter.h
//  gTarAudioController
//
//  Created by Franco Cedano on 12/7/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#ifndef gTarAudioController_ButterWorthFilter_h
#define gTarAudioController_ButterWorthFilter_h

#include "ButterWorthFilterElement.h"

#define MAX_BUTTERWORTH_ORDER 16

class ButterWorthFilter : public Effect
{
public:
    ButterWorthFilter(int order, double cutoff, double SamplingFrequency) :
    Effect  ("Filter", 1.0, SamplingFrequency),
    m_ppFilters(NULL),
    m_SamplingFrequency(SamplingFrequency)
    {
        m_pCutoff = new Parameter(cutoff, 10, 5000, "Frequency");
        m_order = order + (order % 2);  // ensure only even orders 
        if(m_order == 0)                // no zero order filters
            m_order = 2;
        
        m_ppFilters_n = m_order / 2;
        
        m_ppFilters = new ButterWorthFilterElement*[m_ppFilters_n];
        
        // order is just a cascade of 2nd order filters
        for(int i = 0; i < m_ppFilters_n; i++)
        {    
            m_ppFilters[i] = new ButterWorthFilterElement(0, 2, m_pCutoff->getValue(), m_SamplingFrequency);
        }         
    }
    
    bool SetCutoff(double cutoff)
    {
        bool retVal = true;
        
        // propogate the change
        for(int i = 0; i < m_ppFilters_n; i++)
        {
            if(!(retVal = m_ppFilters[i]->CalculateCoefficients(0, cutoff, m_SamplingFrequency)))
                break;
        }
        
        return retVal;
    }
    
    inline double InputSample(double sample)
    {
        if(m_fPassThrough)
            return sample;
        
        double retVal = sample;
        
        //for(int i = 0; i < m_ppFilters_n; i++)
        
        if((m_order / 2) > m_ppFilters_n)     // error condition!
        {
            return 0;
        }
        
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
                m_ppFilters[i] = new ButterWorthFilterElement(0, 2, m_pCutoff->getValue(), m_SamplingFrequency);
            }  
        }        
        
        return true;
    }
    
    void Reset()
    {
        for(int i = 0; i < m_ppFilters_n; i++)
        {
            m_ppFilters[i]->Reset();
        }
    }
    
    Parameter& getPrimaryParam()
    {
        return *m_pCutoff;
    }
    
    bool setPrimaryParam(float value)
    {
        return SetCutoff(value);
    }
    
    Parameter& getSecondaryParam()
    {
        return getPrimaryParam();    
    }
    
    bool setSecondaryParam(float value)
    {
        return setPrimaryParam(value);
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
        
        delete m_pCutoff;
        m_pCutoff = NULL;
    }
    
private:
    ButterWorthFilterElement **m_ppFilters;
    int m_ppFilters_n;
    int m_order;
    Parameter *m_pCutoff;                             // cutoff frequency in HZ (elements convert to radians)
    double m_SamplingFrequency;
    
};


#endif
