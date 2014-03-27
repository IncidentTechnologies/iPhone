//
//  RecordShareViewController.m
//  Sequence
//
//  Created by Kate Schnippering on 3/25/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "RecordShareViewController.h"

@interface RecordShareViewController ()

@end

@implementation RecordShareViewController

@synthesize delegate;
@synthesize backButton;
@synthesize progressView;
@synthesize instrumentView;
@synthesize trackView;
@synthesize progressViewIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        tracks = [[NSMutableArray alloc] init];
        tickmarks = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	trackView.bounces = NO;
    [trackView setDelegate:self];
    
    [self reloadInstruments];
}

- (void)clearAllSubviews
{
    for(UIView * v in instrumentView.subviews){
        [v removeFromSuperview];
    }
    
    for(UIView * v in progressView.subviews){
        [v removeFromSuperview];
    }
    
    for(UIView * v in trackView.subviews){
        [v removeFromSuperview];
    }
}

- (void)reloadInstruments
{
    instruments = [[NSMutableArray alloc] initWithArray:[delegate getInstruments]];
    
    [self clearAllSubviews];
    
    int i = 0;
    
    float instHeight = (instrumentView.frame.size.height+1) / MAX_INSTRUMENTS;
    float instWidth = instrumentView.frame.size.width;
    
    for(Instrument * inst in instruments){
        
        float displayHeight = (i == MAX_INSTRUMENTS-1) ? instHeight : instHeight + 1;
        
        //
        // Instrument icon
        //
        
        CGRect instFrame = CGRectMake(-1, i*instHeight, instWidth+2, displayHeight);
        
        UIButton * instView = [[UIButton alloc] initWithFrame:instFrame];
        [instView setImage:[UIImage imageNamed:inst.iconName] forState:UIControlStateNormal];
        [instView setUserInteractionEnabled:NO];
        [instView setImageEdgeInsets:UIEdgeInsetsMake(5,14,5,14)];
        
        instView.layer.borderColor = [UIColor whiteColor].CGColor;
        instView.layer.borderWidth = 1.0f;
        
        [instrumentView addSubview:instView];
        
        //
        // Recorded track
        //
        
        float trackWidth = trackView.frame.size.width+2;
        CGRect trackFrame = CGRectMake(-1, i*instHeight, trackWidth, displayHeight);
        
        UIView * track = [[UIView alloc] initWithFrame:trackFrame];
        [track setBackgroundColor:[UIColor grayColor]];
        
        track.layer.borderColor = [UIColor darkGrayColor].CGColor;
        track.layer.borderWidth = 1.0f;
        
        [trackView addSubview:track];
        
        [tracks addObject:track];
        
        i++;
    }
    
    for(;i<MAX_INSTRUMENTS;i++){
        
        //
        // Blank instrument
        //
        
        float displayHeight = (i == MAX_INSTRUMENTS-1) ? instHeight : instHeight + 1;
        
        CGRect instFrame = CGRectMake(-1, i*instHeight, instWidth+2, displayHeight);
        UIButton * instView = [[UIButton alloc] initWithFrame:instFrame];
        [instView setBackgroundColor:[UIColor darkGrayColor]];
        [instView setUserInteractionEnabled:NO];
        
        instView.layer.borderColor = [UIColor whiteColor].CGColor;
        instView.layer.borderWidth = 1.0f;
        
        [instrumentView addSubview:instView];
        
        //
        // Blank track
        //
        
        float trackWidth = trackView.frame.size.width+2;
        CGRect trackFrame = CGRectMake(-1, i*instHeight, trackWidth, displayHeight);
        
        UIView * track = [[UIView alloc] initWithFrame:trackFrame];
        [track setBackgroundColor:[UIColor grayColor]];
        
        track.layer.borderColor = [UIColor darkGrayColor].CGColor;
        track.layer.borderWidth = 1.0f;
        
        [trackView addSubview:track];
        
        [tracks addObject:track];
        
    }
    
    // fake pattern
    
    NSDictionary * pattern0i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern0j = [NSDictionary dictionaryWithObjectsAndKeys:@"D",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern0k = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern0 = [[NSMutableArray alloc] initWithObjects:pattern0i,pattern0j,pattern0k, nil];
    
    NSDictionary * pattern1i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern1j = [NSDictionary dictionaryWithObjectsAndKeys:@"D",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern1k = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0.9],@"delta_i",@"C",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern1 = [[NSMutableArray alloc] initWithObjects:pattern1i,pattern1j,pattern1k, nil];
    
    NSDictionary * pattern2i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern2j = [NSDictionary dictionaryWithObjectsAndKeys:@"D",@"start",[NSNumber numberWithDouble:0.3],@"delta_i",@"OFF",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern2k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern2 = [[NSMutableArray alloc] initWithObjects:pattern2i,pattern2j,pattern2k, nil];
    
    NSDictionary * pattern3i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:YES],@"patternrepeat", nil];
    NSDictionary * pattern3j = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern3k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:YES],@"patternrepeat", nil];
    NSMutableArray * pattern3 = [[NSMutableArray alloc] initWithObjects:pattern3i,pattern3j,pattern3k, nil];
    
    NSDictionary * pattern4i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern4j = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern4k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern4 = [[NSMutableArray alloc] initWithObjects:pattern4i,pattern4j,pattern4k, nil];
    
    NSDictionary * pattern5i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern5j = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0.5],@"delta_i",@"D",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern5k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:YES],@"patternrepeat", nil];
    NSMutableArray * pattern5 = [[NSMutableArray alloc] initWithObjects:pattern5i,pattern5j,pattern5k, nil];
    
    NSDictionary * pattern6i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern6j = [NSDictionary dictionaryWithObjectsAndKeys:@"B",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern6k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern6 = [[NSMutableArray alloc] initWithObjects:pattern6i,pattern6j,pattern6k, nil];
    
    NSDictionary * pattern7i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern7j = [NSDictionary dictionaryWithObjectsAndKeys:@"B",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern7k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern7 = [[NSMutableArray alloc] initWithObjects:pattern7i,pattern7j,pattern7k, nil];
    
    NSDictionary * pattern8i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern8j = [NSDictionary dictionaryWithObjectsAndKeys:@"D",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern8k = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern8 = [[NSMutableArray alloc] initWithObjects:pattern8i,pattern8j,pattern8k, nil];
    
    NSDictionary * pattern9i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern9j = [NSDictionary dictionaryWithObjectsAndKeys:@"D",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern9k = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0.9],@"delta_i",@"C",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern9 = [[NSMutableArray alloc] initWithObjects:pattern9i,pattern9j,pattern9k, nil];
    
    NSDictionary * pattern10i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern10j = [NSDictionary dictionaryWithObjectsAndKeys:@"D",@"start",[NSNumber numberWithDouble:0.3],@"delta_i",@"OFF",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern10k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern10 = [[NSMutableArray alloc] initWithObjects:pattern10i,pattern10j,pattern10k, nil];
    
    NSDictionary * pattern11i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:YES],@"patternrepeat", nil];
    NSDictionary * pattern11j = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern11k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:YES],@"patternrepeat", nil];
    NSMutableArray * pattern11 = [[NSMutableArray alloc] initWithObjects:pattern11i,pattern11j,pattern11k, nil];
    
    NSDictionary * pattern12i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern12j = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern12k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern12 = [[NSMutableArray alloc] initWithObjects:pattern12i,pattern12j,pattern12k, nil];
    
    NSDictionary * pattern13i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern13j = [NSDictionary dictionaryWithObjectsAndKeys:@"OFF",@"start",[NSNumber numberWithDouble:0.5],@"delta_i",@"D",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern13k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:YES],@"patternrepeat", nil];
    NSMutableArray * pattern13 = [[NSMutableArray alloc] initWithObjects:pattern13i,pattern13j,pattern13k, nil];
    
    NSDictionary * pattern14i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern14j = [NSDictionary dictionaryWithObjectsAndKeys:@"B",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern14k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern14 = [[NSMutableArray alloc] initWithObjects:pattern14i,pattern14j,pattern14k, nil];
    
    NSDictionary * pattern15i = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern15j = [NSDictionary dictionaryWithObjectsAndKeys:@"B",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSDictionary * pattern15k = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"start",[NSNumber numberWithDouble:0],@"delta_i",@"",@"delta",[NSNumber numberWithBool:NO],@"patternrepeat", nil];
    NSMutableArray * pattern15 = [[NSMutableArray alloc] initWithObjects:pattern15i,pattern15j,pattern15k, nil];
    
    NSMutableArray * patternData = [[NSMutableArray alloc] initWithObjects:pattern0,pattern1,pattern2,pattern3,pattern4,pattern5,pattern6,pattern7,pattern8,pattern9,pattern10,pattern11,pattern12,pattern13,pattern14,pattern15,nil];
    
    [self loadPattern:patternData];
    
}

- (void)loadPattern:(NSMutableArray *)patternData
{
    [self setMeasures:[patternData count]];
    [self drawPatternsOnMeasures:patternData];
    [self resetProgressView];
    
    // figure out datastruct for pattern
}

- (void)setMeasures:(int)newNumMeasures
{
    //
    // Draw measures
    //
    
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    
    numMeasures = newNumMeasures;
    numMeasures = MAX(numMeasures,MIN_MEASURES);
    
    CGSize newContentSize = CGSizeMake(numMeasures*measureWidth,trackView.frame.size.height);
    
    for(int i = 0; i < numMeasures; i++){
        CGRect measureLineFrame = CGRectMake(i*measureWidth, 0, 1, trackView.frame.size.height);
        UIView * measureLine = [[UIView alloc] initWithFrame:measureLineFrame];
        [measureLine setBackgroundColor:[UIColor darkGrayColor]];
        
        [trackView addSubview:measureLine];
    }
    
    if(newContentSize.width > trackView.frame.size.width){
        // for some reason this needs extra padding
        [trackView setContentSize:newContentSize];
        
        for(UIView * t in tracks){
            [t setFrame:CGRectMake(t.frame.origin.x, t.frame.origin.y, newContentSize.width+2, t.frame.size.height)];
        }
    }
    
}

-(void)drawPatternsOnMeasures:(NSMutableArray *)patternData
{

    UIColor * aColor = [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:0.5];
    UIColor * bColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:0.5];
    UIColor * cColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:0.5];
    UIColor * dColor = [UIColor colorWithRed:137/255.0 green:225/255.0 blue:247/255.0 alpha:0.5];
    UIColor * offColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    
    
    //
    // Draw measure content
    //
    
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    
    // clear prev patterns
    for(int j = 0; j < MAX_INSTRUMENTS; j++){
        prevPattern[j] = @"";
        prevInterruptPattern[j] = nil;
        prevTranspose[j] = 0;
    }
    
    int i = 0;
    
    for(NSMutableArray * measure in patternData){
        int j = 0;
        for(NSDictionary * measureData in measure){
            
            UIView * track = [tracks objectAtIndex:j];
            
            CGRect measureBarFrame;
            CGRect measureBarInterruptFrame;
            
            // Check for measure interruption
            NSString * interruptMeasure = [measureData objectForKey:@"delta"];
            if(![interruptMeasure isEqualToString:@""]){
                
                double delta_i = [[measureData objectForKey:@"delta_i"] doubleValue];
                
                measureBarFrame = CGRectMake(i*measureWidth, track.frame.origin.y+1, measureWidth*delta_i, track.frame.size.height-2);
                measureBarInterruptFrame = CGRectMake(i*measureWidth+measureWidth*delta_i, track.frame.origin.y+1, measureWidth - measureWidth*delta_i, track.frame.size.height-2);
                
            }else{
                measureBarFrame = CGRectMake(i*measureWidth, track.frame.origin.y+1, measureWidth, track.frame.size.height-2);
                measureBarInterruptFrame = CGRectNull;
            }
            
            UIView * measureBar = [[UIView alloc] initWithFrame:measureBarFrame];
            
            NSString * pattern = [measureData objectForKey:@"start"];
            
            // Color the starting measure
            if([pattern isEqualToString:@"A"]){
                [measureBar setBackgroundColor:aColor];
            }else if([pattern isEqualToString:@"B"]){
                [measureBar setBackgroundColor:bColor];
            }else if([pattern isEqualToString:@"C"]){
                [measureBar setBackgroundColor:cColor];
            }else if([pattern isEqualToString:@"D"]){
                [measureBar setBackgroundColor:dColor];
            }else{
                [measureBar setBackgroundColor:offColor];
            }
            
            [trackView addSubview:measureBar];
            
            // Draw progress marker
            if(![pattern isEqualToString:@"OFF"]){
                if(CGRectIsNull(measureBarInterruptFrame)){
                    [self drawProgressMarkerForMeasure:i inRow:j startAt:0.0 withWidth:1.0];
                }else{
                    [self drawProgressMarkerForMeasure:i inRow:j startAt:0.0 withWidth:[[measureData objectForKey:@"delta_i"] doubleValue]];
                }
            }
            
            // Draw interrupt measure
            NSString * interruptPattern = nil;
            double interruptTranspose = 0;
            
            if(!CGRectIsNull(measureBarInterruptFrame)){
                
                UIView * measureInterruptBar = [[UIView alloc] initWithFrame:measureBarInterruptFrame];
                
                interruptPattern = [measureData objectForKey:@"delta"];
                interruptTranspose = measureBarInterruptFrame.size.width;
                
                if([interruptPattern isEqualToString:@"A"]){
                    [measureInterruptBar setBackgroundColor:aColor];
                }else if([interruptPattern isEqualToString:@"B"]){
                    [measureInterruptBar setBackgroundColor:bColor];
                }else if([interruptPattern isEqualToString:@"C"]){
                    [measureInterruptBar setBackgroundColor:cColor];
                }else if([interruptPattern isEqualToString:@"D"]){
                    [measureInterruptBar setBackgroundColor:dColor];
                }else{
                    [measureInterruptBar setBackgroundColor:offColor];
                }
                
                [trackView addSubview:measureInterruptBar];
                
                if(![interruptPattern isEqualToString:@"OFF"]){
                    double delta_i = [[measureData objectForKey:@"delta_i"] doubleValue];
                    [self drawProgressMarkerForMeasure:i inRow:j startAt:delta_i withWidth:(1.0-delta_i)];
                }
            }
            
            // Draw pattern end markers
            BOOL patternend = [[measureData objectForKey:@"patternrepeat"] boolValue];
            
            if(patternend){
                
                CGRect topTickFrame = CGRectMake(i*measureWidth+measureWidth-0.5,track.frame.origin.y,2,10);
                CGRect bottomTickFrame = CGRectMake(i*measureWidth+measureWidth-0.5,track.frame.origin.y+track.frame.size.height-10,2,10);
                
                UIView * topTick = [[UIView alloc] initWithFrame:topTickFrame];
                UIView * bottomTick = [[UIView alloc] initWithFrame:bottomTickFrame];
                
                [topTick setBackgroundColor:[UIColor darkGrayColor]];
                [bottomTick setBackgroundColor:[UIColor darkGrayColor]];
                
                [tickmarks addObject:topTick];
                [tickmarks addObject:bottomTick];
            }
            
            // Indicate letter
            if(![prevPattern[j] isEqualToString:pattern] && ![pattern isEqualToString:@"OFF"] && ([interruptPattern isEqualToString:@""] || interruptPattern == nil)){
                
                CGRect patternLetterFrame;
                float patternLetterWidth = 30;
                float patternLetterIndent = 10;
                
                if(prevInterruptPattern != nil && [prevInterruptPattern[j] isEqualToString:pattern]){
                    patternLetterFrame = CGRectMake(measureBar.frame.origin.x+patternLetterIndent-prevTranspose[j],track.frame.origin.y+track.frame.size.height/2-patternLetterWidth/2,patternLetterWidth,patternLetterWidth);
                }else{
                    patternLetterFrame = CGRectMake(measureBar.frame.origin.x+patternLetterIndent,track.frame.origin.y+track.frame.size.height/2-patternLetterWidth/2,patternLetterWidth,patternLetterWidth);
                }
                
                UILabel * patternLetter = [[UILabel alloc] initWithFrame:patternLetterFrame];
                [patternLetter setText:pattern];
                [patternLetter setTextColor:[UIColor whiteColor]];
                [patternLetter setAlpha:0.5];
                [patternLetter setFont:[UIFont fontWithName:FONT_BOLD size:20.0]];
                
                [trackView addSubview:patternLetter];
            }
            
            prevPattern[j] = pattern;
            prevInterruptPattern[j] = interruptPattern;
            prevTranspose[j] = interruptTranspose;
            
            j++;
        }
        
        i++;
    }
    
    // Draw tickmarks on top
    for(UIView * tick in tickmarks){
        [trackView addSubview:tick];
    }
}

#pragma mark - Scrolling and Progress View
-(void)resetProgressView
{
    float indicatorWidth = (MEASURES_PER_SCREEN/numMeasures) * progressView.frame.size.width;
    
    CGRect progressViewIndicatorFrame = CGRectMake(0, 0, indicatorWidth, progressView.frame.size.height);
    progressViewIndicator = [[UIView alloc] initWithFrame:progressViewIndicatorFrame];
    [progressViewIndicator setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3]];
    
    [progressView addSubview:progressViewIndicator];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    double percentMoved = scrollView.contentOffset.x / scrollView.contentSize.width;
    
    double newIndicatorX = progressView.frame.size.width * percentMoved;
    
    [progressViewIndicator setFrame:CGRectMake(newIndicatorX, 0, progressViewIndicator.frame.size.width, progressViewIndicator.frame.size.height)];
}

-(void)drawProgressMarkerForMeasure:(int)m inRow:(int)row startAt:(double)start withWidth:(double)width
{
    float measureWidth = progressView.frame.size.width / numMeasures;
    float rowHeight = (progressView.frame.size.height-10) / MAX_INSTRUMENTS;
    
    CGRect markerFrame = CGRectMake(m*measureWidth+measureWidth*start,row*rowHeight+5,width*measureWidth,1.0);
    
    UIView * marker = [[UIView alloc] initWithFrame:markerFrame];
    [marker setBackgroundColor:[UIColor whiteColor]];
    
    [progressView addSubview:marker];
    
}

#pragma mark - Other Listeners
- (IBAction)userDidBack:(id)sender
{
    [delegate viewSeqSetWithAnimation:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
