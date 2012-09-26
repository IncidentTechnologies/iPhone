//
//  gTarJamViewController.h
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JamIntranetMultiplayerPicker.h"
#import "JamController.h"

@interface gTarJamViewController : UIViewController <IntranetMultiplayerClientDelegate, IntranetMultiplayerServerDelegate, JamIntranetMultiplayerClientDelegate>
{
	
	IBOutlet JamIntranetMultiplayerPicker * m_multiplayerPicker;
	IBOutlet UIView * m_multiplayerPickerView;
	IBOutlet UIButton * m_serverClientToggle;
	IBOutlet UIButton * m_startMultiplayerButton;
	NSString * m_currentToggle;
	
	//JamController * m_jamController;
	IBOutlet UIView * m_tableSlider;
	IBOutlet UIView * m_buttonSlider;
	
}

@property (nonatomic, retain) JamIntranetMultiplayerPicker * m_multiplayerPicker;
@property (nonatomic, retain) UIView * m_multiplayerPickerView;
@property (nonatomic, retain) UIButton * m_serverClientToggle;
@property (nonatomic, retain) UIView * m_tableSlider;
@property (nonatomic, retain) UIView * m_buttonSlider;

//- (IBAction)hostButtonClicked:(id)sender;
//- (IBAction)joinButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)toggleButtonClicked:(id)sender;
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)startMultiplayerButtonClicked:(id)sender;


@end
