//
//  MidiMonitorView.h
//  AudioJunk1
//
//  Created by idanbeck on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreMidiObject.h"

#import "AudioController.h"

@interface MidiMonitorView : UIViewController<UITextViewDelegate>
{
    UITextView *m_pTextView;
}

- (id) initWithTabBar;

void MidiMonitorWriteString(void *self, NSString *pstrString);
- (void) writeString:(NSString *)pstrString;

void MidiMonitorWriteLine(void *self, NSString *pstrLine);
- (void) writeLine:(NSString *)pstrLine;


@end
