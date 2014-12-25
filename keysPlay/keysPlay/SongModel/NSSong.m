//
//  NSSong.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "NSSong.h"

#import "NSMeasure.h"
#import "NSTrack.h"
#import "NSMarker.h"
#import "XmlDom.h"

#define DEFAULT_INSTRUMENT @"Piano"

@implementation NSSong

@synthesize m_measures;
@synthesize m_markers;
@synthesize m_tracks;
@synthesize m_author;
@synthesize m_title;
@synthesize m_description;
@synthesize m_instrument;
@synthesize m_id;
@synthesize m_tempo;

- (id)initWithXmlDom:(XmlDom*)xmlDom
{
    
    if ( xmlDom == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        
        m_measures = [[NSMutableArray alloc] init];
        m_markers = [[NSMutableArray alloc] init];
        m_tracks = [[NSMutableArray alloc] init];
        
        XmlDom * dom;

        XmlDom * songDom = [xmlDom getChildWithName:@"song"];
        
        //
        // Get Header info
        // 
        XmlDom * headerDom = [songDom getChildWithName:@"header"];
        
        if ( headerDom == nil )
        {
            headerDom = [xmlDom getChildWithName:@"header"];
        }
        
        dom = [headerDom getChildWithName:@"id"];
        self.m_id = [[dom getNumberFromChildWithName:@"value"] integerValue];
        
        self.m_title = [headerDom getTextFromChildWithName:@"title"];
        
        self.m_author = [headerDom getTextFromChildWithName:@"author"];
        
        self.m_description = [headerDom getTextFromChildWithName:@"description"];
        
        dom = [headerDom getChildWithName:@"instrument"];
        self.m_instrument = [dom getTextFromChildWithName:@"name"];
        DLog(@"Using instrument: %@", m_instrument);
        
        // Ensure that instrument is not NULL
        if(m_instrument == NULL){
            
            DLog(@"Instrument is NULL using default, %@",DEFAULT_INSTRUMENT);
            self.m_instrument = DEFAULT_INSTRUMENT;
            
        }
        
        dom = [headerDom getChildWithName:@"tempo"];
        self.m_tempo = [[dom getNumberFromChildWithName:@"value"] floatValue];
        
        //
        // Get Content
        //
        XmlDom * contentDom = [songDom getChildWithName:@"content"];

        if ( contentDom == nil )
        {
            contentDom = [xmlDom getChildWithName:@"content"];
        }
        
        NSArray * trackArray = [contentDom getChildArrayWithName:@"track"];
        
        XmlDom * trackDom = [trackArray firstObject];
        
        NSArray * measureArray = [trackDom getChildArrayWithName:@"measure"];
        
        NSArray * markerArray = [trackDom getChildArrayWithName:@"marker"];
        
        
        // Measures + Markers for standard songs
        for ( XmlDom * measureDom in measureArray )
        {
            
            //
            // Get each Measure
            //
            NSMeasure * measure = [[NSMeasure alloc] initWithXmlDom:measureDom];
            
            [self addMeasure:measure];
            
        }
        
        for ( XmlDom * markerDom in markerArray )
        {
            
            NSMarker * marker = [[NSMarker alloc] initWithXmlDom:markerDom];
            
            [m_markers addObject:marker];
            
        }
        
        
        // Clips for Opho songs to select a track
        for ( XmlDom * nthTrackDom in trackArray )
        {
            NSTrack * track = [[NSTrack alloc] initWithXmlDom:nthTrackDom];
            
            [m_tracks addObject:track];
        }

        // done
        
    }
    
    return self;

}

- (id)initWithAuthor:(NSString*)author
			andTitle:(NSString*)title
			 andDesc:(NSString*)desc
			   andId:(NSUInteger)idNum
			andTempo:(double)tempo
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_measures = [[NSMutableArray alloc] init];
		
		self.m_author = author;
		self.m_title = title;
		self.m_description = desc;
		self.m_id = idNum;
		self.m_tempo = tempo;
		
	}
	
	return self;
}


- (void)addMeasure:(NSMeasure*)measure
{
	[m_measures addObject:measure];
	
	[m_measures sortUsingSelector:@selector(compareStartbeat:)];
}

- (NSArray*)getSortedNotes
{
    
    NSMutableArray * notesArray = [[NSMutableArray alloc] init];
    
    for ( NSMeasure * measure in m_measures )
    {
        [notesArray addObjectsFromArray:measure.m_notes];
    }
    
    [notesArray sortUsingSelector:@selector(compareStartbeat:)];
    
    return notesArray;
    
}

@end
