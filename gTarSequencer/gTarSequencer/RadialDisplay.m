//
//  DialButton.m
//  DialButton
//
//  Created by Ilan Gray on 7/20/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "RadialDisplay.h"

@implementation RadialDisplay

@synthesize bottomLabel;
@synthesize middleLabel;
@synthesize topLabel;
@synthesize center;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.userInteractionEnabled = NO;
    
    // set radii:
    innerRadius = 100;
    outerRadius = 220;
    
    // define center:
    // - 70 before
    double verticalOffset = 75;         // the bigger this number the higher up the center is located
    center = CGPointMake(self.frame.size.width/2, self.frame.size.height - verticalOffset);
    
    fillColor = [UIColor colorWithRed:240/255.0 green:146/255.0 blue:0 alpha:1];

    // define the angular bounds:
    double angleWidth = 17;
    
    double angleGap = (180 - NUMBER_OF_WEDGES*angleWidth)/(NUMBER_OF_WEDGES + 1);
    
    double tempAngle = angleGap;
    for (int i=0;i<NUMBER_OF_WEDGES*2;i+=2)
    {
        angles[i] = [self radians:tempAngle];
        
        tempAngle+=angleWidth;
        angles[i+1] = [self radians:tempAngle];
        
        tempAngle+=angleGap;
    }
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    outline = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:outline];
    
    filling = [[UIImageView alloc] initWithFrame:frame];
    filling.clearsContextBeforeDrawing = NO;
    [self addSubview:filling];
    
    [self createOutline];
    
    currentAngle = angles[0];
    
    CGSize fullScreen = CGSizeMake(480, 320);
    UIGraphicsBeginImageContext(fullScreen);
}

- (double)radians:(double)degrees
{
    return (degrees * M_PI / 180.0);
}

#pragma mark Filling

- (void)fillToPercent:(double)percent
{
    double minAngle = angles[0];
    double maxAngle = angles[NUMBER_OF_WEDGES*2 - 1];
    double totalAngularDistance = maxAngle - minAngle;
    
    double newAngleToFill = percent * totalAngularDistance + minAngle;
    
    BOOL clockwise;
    double lowerBound, upperBound;
    
    if ( newAngleToFill > currentAngle )
    {
        upperBound = newAngleToFill;
        lowerBound = currentAngle;
        clockwise = YES;
    }
    else {
        upperBound = currentAngle;
        lowerBound = newAngleToFill;
        clockwise = NO;
    }
    
    // Draw new color:
    NSArray * anglesToFill = [self anglesFromLowerBound:lowerBound toUpperBound:upperBound];  
    
    [self fillAngles:anglesToFill withErasing:!clockwise];
    
    currentAngle = newAngleToFill;
}

- (NSArray *)anglesFromLowerBound:(double)lowerBound toUpperBound:(double)upperBound
{
    NSMutableArray * anglesToFill = [[NSMutableArray alloc] init];;
    
    // Get all the angles into the array:
    [anglesToFill addObject:[NSNumber numberWithDouble:lowerBound]];
    
    for (int i=0;i<NUMBER_OF_WEDGES*2;i++)
    {
        if ( angles[i] > lowerBound && angles[i] < upperBound )
        {
            [anglesToFill addObject:[NSNumber numberWithDouble:angles[i]]];
        }
    }
    
    [anglesToFill addObject:[NSNumber numberWithDouble:upperBound]];
    
    // Delete the ends if they fall in the gaps:
    double firstAngle = [[anglesToFill objectAtIndex:0] doubleValue];
    if ( [self isAngleInBetweenWedges:firstAngle] )
    {
        [anglesToFill removeObjectAtIndex:0];
    }
    
    double finalAngle = [[anglesToFill lastObject] doubleValue];
    if ( [self isAngleInBetweenWedges:finalAngle] )
    {
        [anglesToFill removeObject:[anglesToFill lastObject]];
    }
    
    return anglesToFill;
}

- (void)fillAngles:(NSArray *)anglesToFill withErasing:(BOOL)shouldErase
{
    if ( anglesToFill == nil || [anglesToFill count] == 0 )
    {
        return;
    }

    CGContextRef fillingContext = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(fillingContext, NO);
    
    // Set blend mode to either erase or fill:
    if ( shouldErase )
    {
        CGContextSetBlendMode(fillingContext, kCGBlendModeClear);
    }
    else
    {
        CGContextSetBlendMode(fillingContext, kCGBlendModeNormal);
        CGContextSetFillColorWithColor(fillingContext, fillColor.CGColor);
    }
    
    // Iterate thru the array, build shapes, and fill those shapes:
    for (int i=0;i<[anglesToFill count];i+=2)
    {
        double startAngle = [[anglesToFill objectAtIndex:i] doubleValue];
        double endAngle = [[anglesToFill objectAtIndex:i+1] doubleValue];
        
        CGPathRef wedgePath = [self drawWedgewithStartingAngle:startAngle andEndingAngle:endAngle];
        CGContextAddPath(fillingContext, wedgePath);
        CGContextFillPath(fillingContext);
    }
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    filling.image = image;
}

- (void)printArray:(NSArray *)array
{
    NSLog(@"Angles to fill: \n");
    for (NSNumber * num in array )
    {
        NSLog(@"%f", [num doubleValue]);
    }
    NSLog(@"\n");
}

#pragma mark Gap Functions

/* Determines whether or not the given angle 
 falls in between the gaps of the outline wedges */
- (BOOL)isAngleInBetweenWedges:(double)angle
{
    if ( angle < angles[0] || angle > angles[NUMBER_OF_WEDGES*2-1] )
    {
        return YES;
    }
    
    for (int i=1;i<NUMBER_OF_WEDGES*2 - 1;i+=2)
    {
        if ( angle > angles[i] && angle < angles[i+1] )
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark Outline

- (void)createOutline
{
    // Draw the outline:
    CGSize size = outline.frame.size;
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // -- draw black background:
    int bottomBarHeight = 67;
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor);
    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height - bottomBarHeight));
    CGContextFillPath(context);
    
    // -- draw wedges:
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
    
    for (int i=0;i<NUMBER_OF_WEDGES*2;i+=2)
    {
        CGPathRef wedgePath = [self drawWedgewithStartingAngle:angles[i] andEndingAngle:angles[i+1]];
        CGContextAddPath(context, wedgePath);
        CGContextStrokePath(context);
    }
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    outline.image = image;
    
    UIGraphicsEndImageContext();
    
    // Add UILabels labeling min, max, and medium values:
    CGFloat labelWidth = 30;
    CGFloat labelHeight = 20;
    CGFloat labelYOffset = 230;
    CGFloat labelXOffset = 5;
    CGRect frame;
    
    frame = CGRectMake(labelXOffset, labelYOffset, labelWidth, labelHeight);
    bottomLabel = [[UILabel alloc] initWithFrame:frame];
    bottomLabel.text = @"60";
    bottomLabel.textColor = [UIColor whiteColor];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textAlignment = UITextAlignmentCenter;
    [outline addSubview:self.bottomLabel];
    
    frame = CGRectMake(outline.frame.size.width/2 - labelWidth/2, 2, labelWidth, labelHeight);
    middleLabel = [[UILabel alloc] initWithFrame:frame];
    middleLabel.text = @"120";
    middleLabel.textColor = [UIColor whiteColor];
    middleLabel.backgroundColor = [UIColor clearColor];
    middleLabel.textAlignment = UITextAlignmentCenter;
    [outline addSubview:middleLabel];
    
    frame = CGRectMake(outline.frame.size.width - labelXOffset - labelWidth, labelYOffset, labelWidth, labelHeight);
    topLabel = [[UILabel alloc] initWithFrame:frame];
    topLabel.text = @"180";
    topLabel.textColor = [UIColor whiteColor];
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.textAlignment = UITextAlignmentCenter;
    [outline addSubview:topLabel];
}

#pragma mark Drawing Wedges

/* Given a starting and end angle, this function uses the 
 inner and outer radii to return the corresponding wedge. */
- (CGPathRef)drawWedgewithStartingAngle:(double)startAngle andEndingAngle:(double)endAngle
{
    CGPoint offset;
    CGMutablePathRef wedgePath = CGPathCreateMutable();
    double arcStart, arcEnd;
    
    // Move to point 1:
    offset = CGPointMake(innerRadius*cos(startAngle), innerRadius*sin(startAngle));
    CGPoint pointOne = [self transformCenterwithOffset:offset];
    CGPathMoveToPoint(wedgePath, nil, pointOne.x, pointOne.y);
    
    // Arc clockwise to point 2:
    arcStart = [self invertedSupplement:startAngle];
    arcEnd = [self invertedSupplement:endAngle];
    
    CGPathAddArc(wedgePath, nil, center.x, center.y, innerRadius, arcStart, arcEnd, NO);
    
    // Line to point 3:
    offset = CGPointMake(outerRadius*cos(endAngle), outerRadius*sin(endAngle));
    CGPoint pointThree = [self transformCenterwithOffset:offset];
    CGPathAddLineToPoint(wedgePath, nil, pointThree.x, pointThree.y);
    
    // Arc counter-clockwise to point 4:
    arcStart = [self invertedSupplement:endAngle];
    arcEnd = [self invertedSupplement:startAngle];
    
    CGPathAddArc(wedgePath, nil, center.x, center.y, outerRadius, arcStart, arcEnd, YES);
    
    // Line back to point 1:
    CGPathAddLineToPoint(wedgePath, nil, pointOne.x, pointOne.y);
    
    return wedgePath;
}

- (double)invertedSupplement:(double)oldAngle
{
    double supplement = M_PI - oldAngle;
    
    double invertedSupplement = -1 * supplement;
    
    return invertedSupplement;
}

- (CGPoint)transformCenterwithOffset:(CGPoint)offset
{
    return CGPointMake(center.x - offset.x, center.y - offset.y);
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
