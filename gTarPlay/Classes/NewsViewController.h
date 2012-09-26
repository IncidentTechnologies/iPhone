//
//  NewsViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/16/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CloudResponse;

@interface NewsViewController : UIViewController
{

    IBOutlet UIButton * m_newsTickerView;
    
    NSArray * m_newsStories;
    NSInteger m_currentNewsStory;
    NSTimer * m_newsTickerTimer;
    
}

@property (nonatomic, retain) IBOutlet UIButton * m_newsTickerView;

- (void)getNewsHeadlines;
- (void)requestNewsHeadlinesCallback:(CloudResponse*)cloudResponse;

- (void)startNewsTicker;
- (void)stopNewsTicker;
- (void)cycleNewsTicker;

- (IBAction)newsStoryClicked:(id)sender;

@end
