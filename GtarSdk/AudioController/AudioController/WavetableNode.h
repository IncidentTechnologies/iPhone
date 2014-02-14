//
//  WavetableOscillatorNode.h
//  AudioController
//
//  Created by Idan Beck on 2/12/14.
//
//

#include "GeneratorNode.h"

typedef enum {
    WAVETABLE_SINE,
    WAVETABLE_SAW,
    WAVETABLE_SQUARE,
    WAVETABLE_TRIANGLE,
    WAVETABLE_INVALID
} WAVETABLE_TYPE;

class WavetableNode : public GeneratorNode {
    WavetableNode();
    
    float GetNextSample();
    
public:
    WAVETABLE_TYPE m_type;
    float m_phase;
    float m_frequency;
    float m_theta;
};
