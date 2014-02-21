//
//  ScrollingSelector.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/26/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "ScrollingSelector.h"

@implementation ScrollingSelector

@synthesize delegate;
@synthesize options;
@synthesize cancelButton;
@synthesize scrollView;
@synthesize paginationView;

- (id)initWithFrame:(CGRect)frame
{
        
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect wholeScreen = CGRectMake(0, 0, x, y);
    
    self = [super initWithFrame:wholeScreen];
    if (self) {
        
        // Black out the rest of the screen:
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        // Left and Right arrows
        // [self drawArrowsWithX:x andY:y];
       
        // Cancel button
        [self drawCancelButtonWithX:x];
        
        // Draw main window
        NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:@"ScrollingSelector" owner:self options:nil];
        backgroundView = nibViews[0];
        backgroundView.frame = frame;
        backgroundView.layer.cornerRadius = 5.0;
        [self addSubview:backgroundView];
        
        scrollView.bounces = NO;
        scrollView.delegate = self;
        scrollView.userInteractionEnabled = YES;
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
                
        // Set sizings
        currentOrigin = CGPointMake(0, 0);
        
        int iconSideLength = 60;
        cols = 3;
        gap = (frame.size.width - (iconSideLength*cols))/4;
        
        iconBorderSize = CGSizeMake(iconSideLength, iconSideLength);
        iconSize = CGSizeMake(iconSideLength-20, iconSideLength-20);
        labelSize = CGSizeMake(104, 20);
        
        topRowIcon = 35;
        bottomRowIcon = 140;
        
        topRowLabel = 100;
        bottomRowLabel = 205;
        
        lastContentOffset = CGPointMake(0,0);
        
    }
    return self;
}

- (void)updatePaginationView:(double)focus
{
    
    float pagewidth = 15;
    float pagegap = 8;
    
    pageCount = ceil([images count]/6.0);
    
    // remove all subviews
    NSArray * viewsToRemove = [paginationView subviews];
    for(UIView * v in viewsToRemove){
        [v removeFromSuperview];
    }
    
    // draw circles
    CGSize size = CGSizeMake(paginationView.frame.size.width, paginationView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double leftoffset = paginationView.frame.size.width/2 - (pageCount*pagewidth+(pageCount-1)*pagegap)/2;
    
    // no need to draw for only one
    if(pageCount <= 1){
        return;
    }
    
    for(int i = 0; i < pageCount; i++){
        
        CGRect pageFrame = CGRectMake(i*(pagewidth+pagegap) + leftoffset, 0, pagewidth, pagewidth);

        CGContextAddRect(context, pageFrame);
        if(i == focus || (i==pageCount-1 && focus >= pageCount) || (i==0 && focus < 0)){
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        }else{
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3].CGColor);
        }
        CGContextFillEllipseInRect(context,pageFrame);
    }
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [paginationView addSubview:image];
    
    UIGraphicsEndImageContext();
    
    // after pagination is drawn fade non-visible pages accordingly
    [self fadePagesFrom:focus];
    
}

- (void)setOptions:(NSMutableArray *)newOps
{
    options = newOps;
    
    names = [[NSMutableArray alloc] init];
    images = [[NSMutableArray alloc] init];
    customized = [[NSMutableArray alloc] init];
    highlightedImages = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in options)
    {
        NSString * name = [dict objectForKey:@"Name"];
        [names addObject:name];
        
        NSString * iconName = [dict objectForKey:@"IconName"];
        
        UIImage * normalImage = [UIImage imageNamed:iconName];
        [images addObject:normalImage];
        
        [customized addObject:[dict objectForKey:@"Custom"]];
        
        UIImage * highlightedImage = [UIImage imageNamed:iconName];
        [highlightedImages addObject:highlightedImage];
    }
    
    [self updateDisplay];
}

- (void)moveFrame:(CGRect)newFrame
{
    backgroundView.frame = newFrame;
}

- (void)updateDisplay
{
    imageButtons = [[NSMutableArray alloc] init];
    
    for (UIView * subview in scrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    [self updateContentSize];
    
    [self layoutContent];
}

- (void)updateContentSize
{
    int columnsCount = [names count] / 2;
    
    if ( [names count] % 2 == 1 )
    {
        columnsCount++;
    }
    
    double totalWidth = gap + ( columnsCount * (iconBorderSize.width + gap) );
    
    double totalHeight = scrollView.frame.size.height;
    
    contentSize = CGSizeMake(totalWidth, totalHeight);
    
    //int size = contentSize.width;
    //int scrollViewWidth = scrollView.frame.size.width;
    /*
    if ( size <= scrollViewWidth )
    {
        [self hideLeftArrow:YES rightArrow:YES];
    }
    else {
        [self hideLeftArrow:YES rightArrow:NO];
    }
    */
    [scrollView setContentSize:contentSize];
    scrollView.contentOffset = CGPointMake(0, 0);
}

- (void)layoutContent
{
    
    instrumentObjects = [[NSMutableDictionary alloc] init];
    
    for (int i=0;i<[images count];i++)
    {
        UIView * newbutton = [self addImageAtIndex:i];
        UILabel * newlabel = [self addLabelAtIndex:i];

        NSArray * iconObj = [[NSArray alloc] initWithObjects:newbutton,newlabel, nil];
        
        [instrumentObjects setObject:iconObj forKey:[NSNumber numberWithInt:i]];
    }
    
    // Pagination
    currentPage = 0;
    targetPage = 0;
    
    [self updatePaginationView:currentPage];
}

- (UIView *)addImageAtIndex:(int)index
{
    // -- update position:
    currentOrigin.x = [self xOriginForImageWithIndex:index];
    
    if (index%2 == 0){
        currentOrigin.y = topRowIcon;
    }else{
        currentOrigin.y = bottomRowIcon;
    }
    
    // -- make new image:
    CGRect imageBorderFrame = CGRectMake(currentOrigin.x, currentOrigin.y, iconBorderSize.width, iconBorderSize.height);
    CGRect imageFrame = CGRectMake(10, 10, iconSize.width, iconSize.height);
    
    UIView * buttonborder = [[UIView alloc] initWithFrame:imageBorderFrame];
    buttonborder.layer.borderWidth = 1.0;
    buttonborder.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonborder.layer.cornerRadius = 5.0;
    
    // Custom instrument, add white background
    if([customized[index] isEqualToNumber:[NSNumber numberWithInt:1]]){
        [buttonborder setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5]];
    }
    
    UIButton * button = [[UIButton alloc] initWithFrame:imageFrame];
    [button setBackgroundColor:[UIColor clearColor]];
    
    [button setImage:[images objectAtIndex:index] forState:UIControlStateNormal];
    
    [button setImage:[highlightedImages objectAtIndex:index] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(userDidSelectInstrument:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:buttonborder];
    [buttonborder addSubview:button];
    
    [imageButtons addObject:button];
    
    // if custom instrument creator, indicate with arrow
    if(index == 0){
        
        float playWidth = 10;
        float playHeight = 15;
        float playX = imageBorderFrame.origin.x+imageBorderFrame.size.width+5;
        float playY = imageBorderFrame.origin.y+imageBorderFrame.size.height/2-playHeight/2;
        
        CGSize size = CGSizeMake(scrollView.frame.size.width/2,scrollView.frame.size.height/2);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 2.0);
        
        CGContextMoveToPoint(context, playX, playY);
        CGContextAddLineToPoint(context, playX, playY+playHeight);
        CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
        CGContextClosePath(context);
        
        CGContextFillPath(context);
        
        UIImage * playImage = UIGraphicsGetImageFromCurrentImageContext();
        UIImageView * image = [[UIImageView alloc] initWithImage:playImage];
        
        [scrollView addSubview:image];
        
        UIGraphicsEndImageContext();
        
    }
    
    return buttonborder;
}

- (UILabel *)addLabelAtIndex:(int)index
{
    // -- update position:
    int imageOffset = [self xOriginForImageWithIndex:index];
    currentOrigin.x = imageOffset - gap/2;
    
    if ( index%2 == 0 )
    {
        currentOrigin.y = topRowLabel;
    }
    else
    {
        currentOrigin.y = bottomRowLabel;
    }
    
    // -- make new label:
    CGRect labelFrame = CGRectMake(currentOrigin.x, currentOrigin.y, labelSize.width, labelSize.height);
    UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:[names objectAtIndex:index]];
    [label setFont:[UIFont systemFontOfSize:14.0]];
    
    [scrollView addSubview:label];
    
    return label;
}

- (int)xOriginForImageWithIndex:(int)index
{
    return (gap + (index/2) * (gap + iconBorderSize.width));
}

#pragma mark Actions

- (void)userDidCancel:(id)sender
{
    [delegate scrollingSelectorUserDidSelectIndex:-1];
}

- (void)userDidSelectInstrument:(id)sender
{
    int selectedIndex = [imageButtons indexOfObject:sender];
    
    if(CUSTOMINSTRUMENT && selectedIndex == 0){
        [self launchCustomInstrumentSelector];
    }else{
        [delegate scrollingSelectorUserDidSelectIndex:selectedIndex];
    }
}

#pragma mark Scrolling and Arrows

- (void)scrollViewDidScroll:(UIScrollView *)scroller
{
    //[self autoHideArrows];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroller
{
    [self snapScrollerToPlace:scroller];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scroller
{
    scrollView.scrollEnabled = NO;
    scrollView.scrollEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scroller willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self snapScrollerToPlace:scroller];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self fadeAllPagesIn];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scroller withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    double scrollDistance = (gap + iconBorderSize.width) * cols;
    double velocityOffset = floor(abs(velocity.x)/3.0)+1;
    
    if(scrollView.contentOffset.x > lastContentOffset.x){
        targetPage = MIN(pageCount-1,currentPage+velocityOffset);
    }else if(scrollView.contentOffset.x < lastContentOffset.x){
        targetPage = MAX(0,currentPage-velocityOffset);
    }
    
    CGPoint newOffset = CGPointMake(targetPage*scrollDistance,0);
    
    targetContentOffset->x = newOffset.x;
    lastContentOffset.x = newOffset.x;

}

- (void)snapScrollerToPlace:(UIScrollView *)scroller
{
    currentPage = targetPage;
    [self updatePaginationView:currentPage];
}

// call this when a new custom instrument is added
- (void)scrollToMax
{
    double maxScroll = contentSize.width - scrollView.frame.size.width;
    CGPoint newOffset = scrollView.contentOffset;
    newOffset.x = maxScroll;
    
    currentPage = pageCount-1;
    
    //[self emphasizeArrow:rightArrow setOn:YES];
    //[self emphasizeArrow:leftArrow setOn:NO];
    
    [scrollView setContentOffset:newOffset animated:YES];
    [self updatePaginationView:currentPage];
    //[self autoHideArrows];
}

/*
- (void)userDidTapArrow:(id)sender
{
    double scrollDistance = (gap + iconBorderSize.width) * cols;
    double maxScroll = contentSize.width - scrollView.frame.size.width;
    
    CGPoint newOffset = scrollView.contentOffset;

    // identify direction:
    if(sender == rightArrow){
        
        double expectedScroll = floor((scrollView.contentOffset.x+scrollDistance) / scrollDistance) * scrollDistance;
        newOffset.x = MIN(expectedScroll,maxScroll);
        currentPage++;
        
        [self emphasizeArrow:rightArrow setOn:YES];
        [self emphasizeArrow:leftArrow setOn:NO];
        
    }else{
        
        double expectedScroll = ceil((scrollView.contentOffset.x-scrollDistance) / scrollDistance) * scrollDistance;
        newOffset.x = MAX(expectedScroll,0);
        currentPage--;
        
        [self emphasizeArrow:leftArrow setOn:YES];
        [self emphasizeArrow:rightArrow setOn:NO];
    }
    
    [scrollView setContentOffset:newOffset animated:YES];
    
    [self updatePaginationView:currentPage];
    
    [self autoHideArrows];
    
}

- (void)hideLeftArrow:(BOOL)left rightArrow:(BOOL)right{
    
    [leftArrow setHidden:left];
    [rightArrow setHidden:right];
    
    if(right && !left){
        [self emphasizeArrow:leftArrow setOn:YES];
    }else if(left && !right){
        [self emphasizeArrow:rightArrow setOn:YES];
    }
}

- (void)autoHideArrows
{
    double maxScroll = contentSize.width - scrollView.frame.size.width;
    
    if (scrollView.contentOffset.x <= 0){
        [self hideLeftArrow:YES rightArrow:NO];
    }else if (scrollView.contentOffset.x >= maxScroll){
        [self hideLeftArrow:NO rightArrow:YES];
    }else{
        [self hideLeftArrow:NO rightArrow:NO];
    }
}

- (void)emphasizeArrow:(UIButton *)arrow setOn:(BOOL)on
{
    if(on){
        [arrow setAlpha:0.8];
    }else{
        [arrow setAlpha:0.3];
    }
}

- (void)drawArrowsWithX:(float)x andY:(float)y
{
    
    CGFloat arrowHeight = 66;
    CGFloat arrowWidth = 22;
    CGFloat inset = 15;
    
    CGFloat arrowRX = 0;
    CGFloat arrowRY = 0;
    CGFloat arrowLX = arrowWidth;
    CGFloat arrowLY = 0;
    
    CGRect arrowRFrameOn = CGRectMake(x - inset - arrowWidth, (y - arrowHeight)/2, arrowWidth, arrowHeight);
    CGRect arrowLFrameOn = CGRectMake(inset, (y - arrowHeight)/2, arrowWidth, arrowHeight);
    CGSize size = CGSizeMake(arrowWidth,arrowHeight);
    
    // right
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef rcontext = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(rcontext, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(rcontext, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(rcontext,2.0);
    
    CGContextMoveToPoint(rcontext, arrowRX, arrowRY);
    CGContextAddLineToPoint(rcontext, arrowRX, arrowRY+arrowHeight);
    CGContextAddLineToPoint(rcontext, arrowRX+arrowWidth, arrowRY+arrowHeight/2);
    CGContextClosePath(rcontext);
    
    CGContextFillPath(rcontext);
    
    UIImage * newRImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * rImage = [[UIImageView alloc] initWithImage:newRImage];
    rightArrow = [[UIButton alloc] initWithFrame:arrowRFrameOn];
    [rightArrow addTarget:self action:@selector(userDidTapArrow:) forControlEvents:UIControlEventTouchUpInside];
    [self emphasizeArrow:rightArrow setOn:NO];
    
    [rightArrow addSubview:rImage];
    [self addSubview:rightArrow];
    
    UIGraphicsEndImageContext();
    
    // left
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef lcontext = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(lcontext, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(lcontext, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(lcontext,2.0);
    
    CGContextMoveToPoint(lcontext, arrowLX, arrowLY);
    CGContextAddLineToPoint(lcontext, arrowLX, arrowLY+arrowHeight);
    CGContextAddLineToPoint(lcontext, 0, arrowLY+arrowHeight/2);
    CGContextClosePath(lcontext);
    
    CGContextFillPath(lcontext);
    
    UIImage * newLImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * lImage = [[UIImageView alloc] initWithImage:newLImage];
    leftArrow = [[UIButton alloc] initWithFrame:arrowLFrameOn];
    [leftArrow addTarget:self action:@selector(userDidTapArrow:) forControlEvents:UIControlEventTouchUpInside];
    [self emphasizeArrow:leftArrow setOn:NO];
    
    [leftArrow addSubview:lImage];
    [self addSubview:leftArrow];
    
    UIGraphicsEndImageContext();
    
}
*/

- (void)drawCancelButtonWithX:(float)x
{
    CGFloat cancelWidth = 50;
    CGFloat cancelHeight = 50;
    CGFloat inset = 5;
    CGRect cancelFrame = CGRectMake(x - inset - cancelWidth, 0, cancelWidth, cancelHeight);
    cancelButton = [[UIButton alloc] initWithFrame:cancelFrame];
    [cancelButton setTitle:@"X" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
    
    [cancelButton addTarget:self action:@selector(userDidCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: cancelButton];
    
}

#pragma mark - Page Fading

- (void)fadePagesFrom:(int)focus
{
    int numinst = [instrumentObjects count];
    
    for(int i = 0; i < numinst; i++){
        
        NSArray * iconObj = [instrumentObjects objectForKey:[NSNumber numberWithInt:i]];
        
        // fade in
        if(i >= focus*2*cols && i < (focus+1)*2*cols){
            // fade in
            [iconObj[0] setAlpha:1.0];
            [iconObj[1] setAlpha:1.0];
        }else if(focus == pageCount-1 && i >= numinst-(2*cols-numinst%(2*cols))){
            // fade in last page
            [iconObj[0] setAlpha:1.0];
            [iconObj[1] setAlpha:1.0];
        }else{
            [UIView animateWithDuration:0.2 animations:^(void){
                // fade out
                [iconObj[0] setAlpha:0.0];
                [iconObj[1] setAlpha:0.0];
            }];
        }
    }
}

- (void)fadeAllPagesIn
{
    int numinst = [instrumentObjects count];
    
    for(int i = 0; i < numinst; i++){
        NSArray * iconObj = [instrumentObjects objectForKey:[NSNumber numberWithInt:i]];
        [iconObj[0] setAlpha:1.0];
        [iconObj[1] setAlpha:1.0];
    }
}



#pragma mark - Custom Instrument Selector
- (void)launchCustomInstrumentSelector
{
    [delegate launchCustomInstrumentSelector];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end