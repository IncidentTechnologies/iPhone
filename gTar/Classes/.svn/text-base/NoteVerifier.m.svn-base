//
//  NoteVerifier.m
//  EtarLearn
//
//  Created by Marty Greenia on 10/11/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "NoteVerifier.h"
#import "Note.h"

@implementation NoteVerifier

@synthesize targetNotes;
@synthesize delegate;
@synthesize lastPluck;

- (void)initStuff
{
	lastPluck = 0;
}

- (void)handleInputString:(NSInteger)str andFret:(NSInteger)fret
{

	double currentPluck = [[NSDate date] timeIntervalSince1970];

	if ( (currentPluck - lastPluck) < 0.2 ) // 200ms
	{
		// Ignore this pluck, it has not been long enough.
		return;
	}
	
	for ( NSInteger i = 0; i < [targetNotes count]; i++ )
	{
		Note * note = [targetNotes objectAtIndex:i];
		
		// Strings from the device are zero-based
		if ( (note.m_fret == fret) && (note.m_string == (str+1)) )
		{
			[delegate correctString:str andFret:fret];
			
			[targetNotes removeObjectAtIndex:i];
			
			if ( [targetNotes count] == 0 )
			{
				[delegate allCorrectStringsAndFrets];
				lastPluck = [[NSDate date] timeIntervalSince1970];
			}
			
			continue;
		}

		// TODO: This is kinda hacky and only works because we know what the delegate is
		if ( [delegate getEasyMode] == YES )
		{
			if ( (note.m_fret != fret) && (note.m_string == (str+1)) )
			{
				
				//[delegate correctString:str wrongFret:note.m_fret];
				[delegate correctString:str andFret:note.m_fret];
				
				[targetNotes removeObjectAtIndex:i];
				
				if ( [targetNotes count] == 0 )
				{
					[delegate allCorrectStringsAndFrets];
					lastPluck = [[NSDate date] timeIntervalSince1970];
				}
			}
		}
	}

}

@end
