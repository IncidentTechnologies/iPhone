//
//  SequencerViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuitarView.h"

#import "RadialButton.h"
#import "ScrollingSelector.h"

#import "InstrumentTableViewController.h"
#import "BottomBarViewController.h"

@interface SequencerViewController : UIViewController <GuitarViewDelegate> {

    // gtar connection
    BOOL isConnected;
    GuitarView *guitarView;
    int string;
    int fret;
    
    InstrumentTableViewController * instrumentTableViewController;
    BottomBarViewController * bottomBarViewController;
    
    IBOutlet UIImageView * gTarLogoImageView;
    
}

@property (retain, nonatomic) InstrumentTableViewController * instrumentTableViewController;
@property (retain, nonatomic) BottomBarViewController * bottomBarViewController;

@property (retain, nonatomic) IBOutlet UIImageView * gTarLogoImageView;
@property (retain, nonatomic) IBOutlet UILabel * gTarConnectedText;


@end
