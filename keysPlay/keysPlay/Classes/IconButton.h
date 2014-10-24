//
//  IconButton.h
//  keysPlay
//
//  Created by Marty Greenia on 5/10/13.
//
//

#import <UIKit/UIKit.h>

// This button just automatically resizes its imageView to be an aspect-fit 20px high image (i.e. "icon").
// Specifically, setting the self.imageView.contentMode to aspect-fit must be done in code (not IB), which
// requires an IBOutlet for the pointer, which otherwise you dont need.
// This has just been so common, I figured I would offload it to a class. You can set your button to IconButton
// and all of the resizing will be automatic
@interface IconButton : UIButton

@end
