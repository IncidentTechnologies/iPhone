//
//  DefaultViewController.h
//  gTarCreate
//
//  Created by Idan Beck on 2/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DefaultViewController : UIViewController {
    
}

@property (nonatomic, retain) IBOutlet UIButton *m_buttonTest;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonTrigger;

-(IBAction)onButtonTestClicked:(id)sender;
-(IBAction)onButtonTriggerClicked:(id)sender;

-(void)setUpSamplerWithBaseName:(NSString *)strBaseName;

-(void)testFxNode;

@end
