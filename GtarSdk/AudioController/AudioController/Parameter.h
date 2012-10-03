//
//  Parameter.h
//  gTarAudioController
//
//  This class represents a single parameter on an effect or module
//
//  Created by Franco Cedano on 11/23/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#ifndef gTarAudioController_Parameter_h
#define gTarAudioController_Parameter_h

#include <string>

class Parameter
{
public:
    Parameter(float initial, float min, float max, const std::string& desc)
    {
        m_max = max;
        m_min = min;
        if (initial > max)
        {
            m_value = max;
        }
        else if (initial < min)
        {
            m_value = min;
        }
        else
        {
            m_value = initial;
        }
        m_name = desc;
    }
    
    float getValue() {return m_value;};
    bool setValue(float newVal)
    {
        if (newVal > m_max || newVal < m_min)
        {
            return false;
        }
        m_value = newVal;
        return true;
    }
    
    float getMax() {return m_max;};
    float getMin() {return m_min;};
    std::string getName() {return m_name;};
private:
    float m_value;
    float m_max;
    float m_min;
    std::string m_name;
};

#endif
