//
//  Checklist.h
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#ifndef gTarFunctionalVerification_Checklist_h
#define gTarFunctionalVerification_Checklist_h

typedef struct
{
    BOOL connectedTest;
    BOOL disconnectedTest;
    
    BOOL redTestAll;
    BOOL redTestSeries;
    BOOL greenTestAll;
    BOOL greenTestSeries;
    BOOL blueTestAll;
    BOOL blueTestSeries;
    BOOL whiteTestAll;
    BOOL whiteTestSeries;
    
    BOOL fretUpTest;
    BOOL fretDownTest;
    BOOL noteOnTest;
    
    BOOL fretElectricalTest;
    BOOL piezoElectricalTest;
    BOOL lineOutTest;
    BOOL batteryTest;
    BOOL firmwareTest;
    
} Checklist;

#endif
