//
//  NSTrack.m
//  keysPlay
//
//  Created by Kate Schnippering on 12/24/14.
//
//

#import "NSTrack.h"
#import "NSInstrument.h"
#import "XmlDom.h"

@implementation NSTrack

@synthesize m_clips;
@synthesize m_name;
@synthesize m_instrument;

-(id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        m_name = [dom getTextFromChildWithName:@"name"];
        
        m_level = [[dom getTextFromChildWithName:@"level"] doubleValue];
        
        m_muted = [[dom getTextFromChildWithName:@"muted"] boolValue];
        
        m_instrument = [[NSInstrument alloc] initWithXmlDom:[dom getChildWithName:@"instrument"]];
        
        DLog(@"TRACK name | %@",m_name);
        DLog(@"TRACK level | %f",m_level);
        DLog(@"TRACK muted | %i",m_muted);
        
        m_clips = [[NSMutableArray alloc] init];
        
        // Init the clip children
        NSArray * clipchildren = [dom getChildArrayWithName:@"clip"];
        
        for(XmlDom * child in clipchildren){
            
            NSClip * clip = [[NSClip alloc] initWithXmlDom:child];
            
            [self addClip:clip];
        }
    }
    
    return self;
}

-(void)addClip:(NSClip *)clip
{
    [m_clips addObject:clip];
}

/*
- (NSArray *)convertClipsToMeasures
{
    NSMutableArray * noteArray = [[NSMutableArray alloc] init];
    
    double startBeat = 0;
    double endBeat = 20.0; // get max from noteArray;
    double beatsPerMeasure = 4.0;

    for(double beat = startBeat; beat < endBeat+beatsPerMeasure; beat += beatsPerMeasure){
        // add notes from clip
    }
    
    // then generate measures
    
    return nil;
}
 */

@end
