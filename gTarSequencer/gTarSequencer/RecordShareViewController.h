//
//  RecordShareViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 3/25/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "Instrument.h"

#define MAX_INSTRUMENTS 5
#define MIN_MEASURES 8
#define MEASURES_PER_SCREEN 8.0

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@protocol RecordShareDelegate <NSObject>

- (void) viewSeqSetWithAnimation:(BOOL)animate;

- (NSMutableArray *)getInstruments;

@end

@interface RecordShareViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray * instruments;
    NSMutableArray * tracks;
    NSMutableArray * tickmarks;
    
    int numMeasures;
    
    NSString * prevPattern[MAX_INSTRUMENTS];
    NSString * prevInterruptPattern[MAX_INSTRUMENTS];
    double prevTranspose[MAX_INSTRUMENTS];
}

- (void)reloadInstruments;
- (void)loadPattern:(NSMutableArray *)patternData;
- (IBAction)userDidBack:(id)sender;

@property (weak, nonatomic) id<RecordShareDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton * backButton;
@property (weak, nonatomic) IBOutlet UIView * progressView;
@property (weak, nonatomic) IBOutlet UIView * instrumentView;
@property (weak, nonatomic) IBOutlet UIScrollView * trackView;
@property (retain, nonatomic) UIView * progressViewIndicator;
@property (weak, nonatomic) IBOutlet UIView * noSessionOverlay;

@end
