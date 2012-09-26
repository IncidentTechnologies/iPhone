//
//  SelectSongOptionsPopupViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 11/8/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "SelectSongOptionsPopupViewController.h"
#import "CustomSegmentedControl.h"

#import "SelectNavigationViewController.h"
#import "UserSong.h"
#import "SongViewController.h"
#import "RoundedRectangleView.h"

@implementation SelectSongOptionsPopupViewController

@synthesize m_navigationController;
@synthesize m_userSong;
@synthesize m_muffleView;
@synthesize m_tempoView;
@synthesize m_difficultyControl;
@synthesize m_muffleControl;
@synthesize m_tempoSlider;
@synthesize m_tempoSliderValue;
@synthesize m_titleLabel;
@synthesize m_artistLabel;
@synthesize m_difficultyDescriptionLabel;
@synthesize m_previewButton;

#define EASY_MODE_TEXT @"In easy mode, you only need to pluck the correct string. Incorrect notes will not played."
#define MEDIUM_MODE_TEXT @"In medium mode, you must pluck the correct string while fingering the correct frets."
#define HARD_MODE_TEXT @"In hard mode, all notes will be played."

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        
        self.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
        
    }
    
    return self;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    
    [m_muffleView release];
    [m_tempoView release];
    [m_difficultyControl release];
    [m_muffleControl release];
    [m_tempoSlider release];
    [m_tempoSliderValue release];
    [m_titleLabel release];
    [m_artistLabel release];
    [m_difficultyDescriptionLabel release];
    [m_previewButton release];
    
    [super dealloc];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [m_difficultyControl changeOnImages:[NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"EasyButtonON.png"], 
                                         [UIImage imageNamed:@"MediumButtonON.png"],
                                         [UIImage imageNamed:@"HardButtonON.png"], nil]
                           andOffImages:[NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"EasyButtonOFF.png"], 
                                         [UIImage imageNamed:@"MediumButtonOFF.png"],
                                         [UIImage imageNamed:@"HardButtonOFF.png"], nil]];
    
    [m_muffleControl changeOnImages:[NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"MuffleButtonOnOFF.png"], 
                                     [UIImage imageNamed:@"MuffleButtonOffOFF.png"], nil]
                       andOffImages:[NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"MuffleButtonOnON.png"], 
                                     [UIImage imageNamed:@"MuffleButtonOffON.png"], nil]];
    
    m_difficultyDescriptionLabel.text = EASY_MODE_TEXT;
    
    //
    // There is some kind of bug that causes the slider to go invisible
    // during the pop-up animation. There are some reports online of people
    // seeing similar things in similar contexts .. I accidentally found that 
    // adding another view fixes the problem .. its silly but it works for now.
    //
//    UIView * dummy = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//    dummy.alpha = 0;
//    [self.view addSubview:dummy];
//    [self.view sendSubviewToBack:dummy];
    
    
    UIImage * image;
    
    [m_tempoSlider setThumbImage:[UIImage imageNamed:@"Handle.png"] forState:UIControlStateNormal];
    
    image = [UIImage imageNamed:@"LeftCap_Blue.png"];
    image = [image stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [m_tempoSlider setMinimumTrackImage:image forState:UIControlStateNormal];
    
    image = [UIImage imageNamed:@"RightCap_Grey.png"];
    image = [image stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [m_tempoSlider setMaximumTrackImage:image forState:UIControlStateNormal];
    
    // force it through the animations for the default values
    [self tempoValueChanged:nil];
    [self toggleDifficultyParamters];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_muffleView = nil;
    self.m_tempoView = nil;
    self.m_difficultyControl = nil;
    self.m_muffleControl = nil;
    self.m_tempoSlider = nil;
    self.m_tempoSliderValue = nil;
    self.m_titleLabel = nil;
    self.m_artistLabel = nil;
    self.m_difficultyDescriptionLabel = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [m_titleLabel setText:m_userSong.m_title];
    
    [m_artistLabel setText:m_userSong.m_author];
    
    m_previewButton.selected = NO;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//- (void)attachFinalize
//{
//
//}

#pragma mark - Button handlers

- (IBAction)fullScreenButtonClicked:(id)sender
{
    // Do nothing -- prevent accidental clicks from closing the window.
}

- (IBAction)difficultyValueChanged:(id)sender
{

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    [self toggleDifficultyParamters];

    [UIView commitAnimations];
    
}

- (IBAction)muffleValueChanged:(id)sender
{
    
}

- (IBAction)tempoValueChanged:(id)sender
{
    
    CGFloat value = m_tempoSlider.value;
    
    if ( value < 0.25 )
    {
        m_tempoSlider.value = 0.25;
        value = 0.25;
    }
    
    CGFloat offset = (m_tempoSlider.frame.size.width - m_tempoSlider.currentThumbImage.size.width) * value;
    
    m_tempoSliderValue.transform = CGAffineTransformMakeTranslation( offset, 0 );
    
    [m_tempoSliderValue setText:[NSString stringWithFormat:@"%u%%", ((NSInteger)(value*100))]];
    
}

- (IBAction)playButtonClicked:(id)sender
{
    
    // Stop preview if necessary
    [m_navigationController stopPreview];
    
    // We still all the params into the controller
    SongViewController * songController = [[SongViewController alloc] initWithNibName:nil bundle:nil];
        
    songController.m_userSong = m_userSong;
    
    if ( m_difficultyControl.m_selectedSegmentIndex == 0 )
    {
        // Easy
        songController.m_difficulty = SongViewControllerDifficultyEasy;
    }
    else if ( m_difficultyControl.m_selectedSegmentIndex == 1 )
    {
        // Medium
        songController.m_difficulty = SongViewControllerDifficultyMedium;
        songController.m_muffleWrongNotes = YES;
//        songController.m_muffleWrongNotes = (m_muffleControl.m_selectedSegmentIndex == 0);
    }
    else if ( m_difficultyControl.m_selectedSegmentIndex == 2 )
    {
        // Hard
//        songController.m_difficulty = SongViewControllerDifficultyHard;
//        songController.m_muffleWrongNotes = (m_muffleControl.m_selectedSegmentIndex == 0);
//        songController.m_tempoModifier = m_tempoSlider.value;
        songController.m_difficulty = SongViewControllerDifficultyHard;
        songController.m_muffleWrongNotes = NO;
    }
    
    // Then we pass it to the navcontroller to finish
    [m_navigationController startSongInstance:songController];
    
    [songController release];
    
    [self detachFromSuperView];
    
}

- (IBAction)previewButtonClicked:(id)sender
{
    
    if ( m_previewButton.selected == NO )
    {
        m_previewButton.selected = YES;
        [m_navigationController previewUserSong:m_userSong];
    }
    else
    {
        m_previewButton.selected = NO;
        [m_navigationController stopPreview];
    }
    
}

- (IBAction)closeButtonClicked:(id)sender
{
    
    // Stop preview if necessary
    [m_navigationController stopPreview];
    
    m_previewButton.selected = NO;

    [super closeButtonClicked:sender];
    
}

#pragma mark - Misc

- (void)toggleDifficultyParamters
{
    
    CGFloat offAlpha = 0.25;
    
    if ( m_difficultyControl.m_selectedSegmentIndex == 0 )
    {
        m_muffleView.alpha = offAlpha;
        m_tempoView.alpha = offAlpha;
        
        m_muffleControl.enabled = NO;
        m_tempoSlider.enabled = NO;
        
        m_difficultyDescriptionLabel.text = EASY_MODE_TEXT;
    }
    else if ( m_difficultyControl.m_selectedSegmentIndex == 1 )
    {
        m_muffleView.alpha = 1.0;
        m_tempoView.alpha = offAlpha;
        
        m_muffleControl.enabled = YES;
        m_tempoSlider.enabled = NO;
        
        m_difficultyDescriptionLabel.text = MEDIUM_MODE_TEXT;
    }
    else if ( m_difficultyControl.m_selectedSegmentIndex == 2 )
    {
        m_muffleView.alpha = 1.0;
        m_tempoView.alpha = 1.0;
        
        m_muffleControl.enabled = YES;
        m_tempoSlider.enabled = YES;
        
        m_difficultyDescriptionLabel.text = HARD_MODE_TEXT;
    }

    CATransition * animation = [CATransition animation];
    animation.duration = 0.3f;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [m_difficultyDescriptionLabel.layer addAnimation:animation forKey:nil];
    
}



@end
