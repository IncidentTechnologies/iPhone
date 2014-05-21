//
//  NoteAnimation.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/23/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "NoteAnimation.h"


@implementation NoteAnimation

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andOverlay:(Model*)overlay
{

    self = [super initWithFramesPerModel:5];
    
	if ( self )
	{
		
		m_overlay = overlay;
		
		m_center = center;
		
		// Create all the notes for our animation

		NSString * filePath;
		UIImage * image;
		UIImage * scaledImage;

		Texture2D * texture;
		Model * model;
		
		// note 0
		filePath = [[NSBundle mainBundle] pathForResource:@"note-blank4" ofType:@"png"];
		image = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(size);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		texture = [[Texture2D alloc] initWithImage:scaledImage];
		model = [[Model alloc] initWithCenter:center andColor:color andTexture:texture];
		
		[self addModel:model];
		
		
		
#if 0
		// note 1
		filePath = [[NSBundle mainBundle] pathForResource:@"note_hit1" ofType:@"png"];
		image = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(size);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		texture = [[Texture2D alloc] initWithImage:scaledImage];
		model = [[Model alloc] initWithCenter:center andColor:color andTexture:texture];
		
		[self addModel:model];
		
		[texture release];
		[model release];
		[image release];
		
		
		// note 2
		filePath = [[NSBundle mainBundle] pathForResource:@"note_hit2" ofType:@"png"];
		image = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(size);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		texture = [[Texture2D alloc] initWithImage:scaledImage];
		model = [[Model alloc] initWithCenter:center andColor:color andTexture:texture];
		
		[self addModel:model];
		
		[texture release];
		[model release];
		[image release];
				
		
		// note 3
		filePath = [[NSBundle mainBundle] pathForResource:@"note_hit3" ofType:@"png"];
		image = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(size);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		texture = [[Texture2D alloc] initWithImage:scaledImage];
		model = [[Model alloc] initWithCenter:center andColor:color andTexture:texture];
		
		[self addModel:model];
		
		[texture release];
		[model release];
		[image release];
#else
        // TODO
        // Getting rid of this for performance reasons .. for now
        /*
		// note 0w
		filePath = [[NSBundle mainBundle] pathForResource:@"note_bright100" ofType:@"png"];
		image = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(size);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		texture = [[Texture2D alloc] initWithImage:scaledImage];
		model = [[Model alloc] initWithCenter:center andColor:color andTexture:texture];
		
		[self addModel:model];
		
		[texture release];
		[model release];
		[image release];
		

		filePath = [[NSBundle mainBundle] pathForResource:@"note_bright100b" ofType:@"png"];
		image = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(size);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		texture = [[Texture2D alloc] initWithImage:scaledImage];
		model = [[Model alloc] initWithCenter:center andColor:color andTexture:texture];
		
		[self addModel:model];
		
		[texture release];
		[model release];
		[image release];
		*/
#endif

	}

	return self;
	
}


- (void)drawCurrentFrame
{
	
	[super drawCurrentFrame];
	
	[m_overlay drawAt:m_center];
	
}

@end
