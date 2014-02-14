//
//  EnvelopeNode.h
//  AudioController
//
//  Created by Idan Beck on 2/12/14.
//
//

#import "AudioNode.h"

class EnvelopeNode : public AudioNode {
    EnvelopeNode();
    
    //void NoteOn();
    //void NoteOff();
    
private:
    int m_channel_n;
    float m_CLK;
    BOOL m_fNoteOn;
    
public:
    float m_msAttack;
    float m_msDecay;
    float m_SustainLevel;
    
    float m_msRelease;
    float m_ReleaseLevel;
};
