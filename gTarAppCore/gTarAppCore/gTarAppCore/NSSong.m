//
//  NSSong.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "NSSong.h"

#import "NSMeasure.h"
#import "XmlDom.h"

@implementation NSSong

@synthesize m_measures;
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
        NSLog(@"Using instrument: %@", m_instrument);
        
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
        
        XmlDom * trackDom = [contentDom getChildWithName:@"track"];
        
        NSArray * measureArray = [trackDom getChildArrayWithName:@"measure"];
        
        for ( XmlDom * measureDom in measureArray )
        {
            
            //
            // Get each Measure
            //
            NSMeasure * measure = [[NSMeasure alloc] initWithXmlDom:measureDom];
            
            [self addMeasure:measure];
            
            [measure release];
            
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

- (void)dealloc
{
	
	[m_measures release];
    [m_author release];
	[m_title release];
    [m_description release];
    [m_instrument release];
    
	[super dealloc];
	
}

- (void)addMeasure:(NSMeasure*)measure
{
	[m_measures addObject:measure];
	
	[m_measures sortUsingSelector:@selector(compare:)];
}

- (NSArray*)getSortedNotes
{
    
    NSMutableArray * notesArray = [[NSMutableArray alloc] init];
    
    for ( NSMeasure * measure in m_measures )
    {
        [notesArray addObjectsFromArray:measure.m_notes];
    }
    
    [notesArray sortUsingSelector:@selector(compare:)];
    
    return [notesArray autorelease];
    
}

@end
