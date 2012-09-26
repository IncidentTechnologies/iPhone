//
//  AudioJunk1AppDelegate.h
//  AudioJunk1
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MidiMonitorView.h"

@class AudioJunk1ViewController;

@interface AudioJunk1AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AudioJunk1ViewController *viewController;
    
    UITabBarController *tabController;
    
@public
    MidiMonitorView *midiMonitorViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AudioJunk1ViewController *viewController;
@property (nonatomic, retain) IBOutlet MidiMonitorView *midiMonitorViewController;

@property (nonatomic, retain) IBOutlet UITabBarController *tabController;

@end

