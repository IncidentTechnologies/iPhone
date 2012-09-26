//
//  SongMerger.m
//  gTar
//
//  Created by Marty Greenia on 2/8/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "gTar.h"
#import "SongModel.h"
#import "SongRecorder.h"
#import "SongCreator.h"
#import "SongMerger.h"


@implementation SongMerger

+ (NSString*)xmpBlobWithXmpBlob:(NSString*)xmpBlob1 andXmpBlob:(NSString*)xmpBlob2
{

	SongModel * sm1 = new SongModel(xmpBlob1);
	SongModel * sm2 = new SongModel(xmpBlob2);
	
	sm1->StartModelAtTime(0);
	sm1->AdvanceModelToNextTargetNotes();
	
	sm2->StartModelAtTime(0);
	sm2->AdvanceModelToNextTargetNotes();
	
	double tempo = sm1->m_song->m_tempo;
	
	SongRecorder * recorder = [[SongRecorder alloc] initWithTempo:tempo];

	[recorder beginSong];
	
	while ( sm1->IsEndOfSong() == NO || sm2->IsEndOfSong() == NO )
	{
		
		char notes[ GTAR_GUITAR_STRING_COUNT ];
		double currentTime;
		
		double time1 = sm1->GetCurrentTime();
		double time2 = sm2->GetCurrentTime();
		
		// figure out which song has the next set of notes
		if ( sm1->IsEndOfSong() == NO && 
			(sm2->IsEndOfSong() == YES || time1 < time2 ) )
		{
			currentTime	= time1;
			sm1->GetTargetNotesBytes(notes);
			sm1->AdvanceModelToNextTargetNotes();
		}
		else if ( sm2->IsEndOfSong() == NO )
		{
			currentTime	= time2;
			sm2->GetTargetNotesBytes(notes);
			sm2->AdvanceModelToNextTargetNotes();
		}
		else 
		{
			// both songs are EoS.
			// in the common case, the while() conditional should catch this.
			break;
		}
		
		for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
		{
			char fret = notes[str];
			
			if ( fret != GTAR_GUITAR_NOTE_OFF )
			{
				[recorder advanceRecordingToTime:currentTime];
				[recorder playString:str andFret:fret];
			}

		}
		
	}
	
	[recorder finishSong];
	
	CSong * recordedSong = recorder.m_song;
	
	// set some header info
	recordedSong->SetName( sm1->m_song->m_name );
	recordedSong->SetArtist( sm1->m_song->m_artist );
	recordedSong->SetDescription( sm1->m_song->m_description );
	
	NSString * xmpBlob = [SongCreator xmpBlobWithSong:recordedSong];
	
	return xmpBlob;
}

@end
