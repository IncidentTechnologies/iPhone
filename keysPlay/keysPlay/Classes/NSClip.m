//
//  NSClip.m
//  keysPlay
//
//  Created by Kate Schnippering on 12/24/14.
//
//

#import "NSClip.h"
#import "XmlDom.h"

@implementation NSClip

@synthesize m_notes;
@synthesize m_name;
@synthesize m_color;
@synthesize m_startbeat;
@synthesize m_endbeat;
@synthesize m_cliplength;
@synthesize m_clipstart;
@synthesize m_looping;
@synthesize m_loopstart;
@synthesize m_looplength;
@synthesize m_muted;

-(id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        DLog(@"CLIP");
        
        m_name = [dom getTextFromChildWithName:@"name"];
        
        m_color = [dom getTextFromChildWithName:@"color"];
        
        m_startbeat = [[dom getTextFromChildWithName:@"startbeat"] doubleValue];
        
        m_endbeat = [[dom getTextFromChildWithName:@"endbeat"] doubleValue];
        
        m_cliplength = [[dom getTextFromChildWithName:@"cliplength"] doubleValue];
        
        m_clipstart = [[dom getTextFromChildWithName:@"clipstart"] doubleValue];
        
        m_looping = [[dom getTextFromChildWithName:@"looping"] boolValue];
        
        m_loopstart = [[dom getTextFromChildWithName:@"loopstart"] doubleValue];
        
        m_looplength = [[dom getTextFromChildWithName:@"looplength"] doubleValue];
        
        m_muted = [[dom getTextFromChildWithName:@"muted"] boolValue];
        
        DLog(@"CLIP name | %@",m_name);
        DLog(@"CLIP color | %@",m_color);
        DLog(@"CLIP startbeat | %f",m_startbeat);
        DLog(@"CLIP endbeat | %f",m_endbeat);
        DLog(@"CLIP cliplength | %f",m_cliplength);
        DLog(@"CLIP clipstart | %f",m_clipstart);
        DLog(@"CLIP looping | %i",m_looping);
        DLog(@"CLIP loopstart | %f",m_loopstart);
        DLog(@"CLIP looplength | %f",m_looplength);
        DLog(@"CLIP muted | %i",m_muted);
        
        m_notes = [[NSMutableArray alloc] init];
        
        NSArray * notechildren = [dom getChildArrayWithName:@"note"];
        
        for(XmlDom * child in notechildren){
            
            NSNote * note = [[NSNote alloc] initWithXmlDom:child];
            
            [self addNote:note];
        }
    }
    
    return self;
}

- (void)addNote:(NSNote *)note
{
    [m_notes addObject:note];
}

@end
