//
//  NoteVerifier.h
//  EtarLearn
//
//  Created by Marty Greenia on 10/11/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NoteVerifierDelegate <NSObject>
@optional
// Callback called when a correct string is played
- (void)correctString:(NSInteger)str andFret:(NSInteger)fret;
// Callback called when an incorrect string is played
- (void)incorrectString:(NSInteger)str andFret:(NSInteger)fret;
// Callback called when all correct strings are played
- (void)allCorrectStringsAndFrets;
- (void)correctString:(NSInteger)str wrongFret:(NSInteger)fret;
// TODO: hacky
- (Boolean)getEasyMode;

@end


@interface NoteVerifier : NSObject
{
	NSMutableArray * targetNotes;
	id <NoteVerifierDelegate> delegate;
	double lastPluck;
}

//- (void)setTargetNotes;
- (void)handleInputString:(NSInteger)str andFret:(NSInteger)fret;

@property (nonatomic, retain) NSMutableArray * targetNotes;
@property (nonatomic, retain) id <NoteVerifierDelegate> delegate;
@property (nonatomic) double lastPluck;

@end
