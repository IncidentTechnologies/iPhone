//
//  VAChecklist.h
//  gTarVerificationApp
//
//  Created by Joel Greenia on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VAChecklist : NSObject
{
@public
    BOOL m_connected;
    BOOL m_disconnected;
    
    char m_noteOn[6][17];
    
    char m_fretUp[6][17];
    char m_fretDown[6][17];
    
}

@end
