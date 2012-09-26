//
//  LoadingSequencesTable.h
//  gTarSequencer
//
//  Created by Ilan Gray on 6/29/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sequencer.h"

@protocol SequenceLoaderDelegate <NSObject>

- (void)didSelectSequenceToLoad:(Sequencer *)userSelection withName:(NSString *)fileName;
- (void)userDidCancelLoading;

@end

@interface SequenceLoaderTable : UITableViewController
{
    NSString * filePath;
    
    NSMutableDictionary * saves;
    
    NSArray * saveNames;
}

@property (weak, nonatomic) id<SequenceLoaderDelegate> delegate;

- (BOOL)saveSequencer:(Sequencer *)toSave withName:(NSString *)saveName;

@end
