//
//  GeneratorNode.h
//  AudioController
//
//  Created by Idan Beck on 2/12/14.
//
//

#include "AudioNode.h"

class GeneratorNode : public AudioNode {
public:
    GeneratorNode();
    
    //- (id) initWithAudioController:(AudioController*)ac;
    int InitializeChannels();
    int SetChannelCount(int channel_n);
 
    virtual float GetNextSample() = 0;
};
