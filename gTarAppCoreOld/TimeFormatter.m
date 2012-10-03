//
//  TimeFormatter.m
//  gTarAppCore
//
//  Created by Marty Greenia on 10/27/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "TimeFormatter.h"

@implementation TimeFormatter

+ (NSTimeInterval)convertDateStringToInterval:(NSString*)dateString
{
    
    NSDateFormatter * dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [[dateFormat dateFromString:dateString] timeIntervalSince1970];
    
}

+ (NSTimeInterval)intervalFromNow:(NSTimeInterval)time
{
    
    NSDate * date = [NSDate date];
    
    NSTimeInterval now = [date timeIntervalSince1970];
    
    return (now - time);
    
}

+ (NSString*)stringFromNow:(NSTimeInterval)time
{
    
    NSDate * date = [NSDate date];
    
    NSTimeInterval now = [date timeIntervalSince1970];
    
    if ( time > now )
    {
        return [NSString stringWithFormat:@"The Future"];
    }
    
    NSTimeInterval delta = now - time;
    
    NSInteger seconds = (NSInteger)delta;
        
    // seconds
    if ( seconds == 1 )
    {
        return [NSString stringWithFormat:@"%u second ago", seconds];
    }
    
    if ( seconds < 60 )
    {
        return [NSString stringWithFormat:@"%u seconds ago", seconds];
    }
    
    // minutes
    NSInteger minutes = [TimeFormatter convertToMinutes:delta];
    
    if ( minutes == 1 )
    {
        return [NSString stringWithFormat:@"%u minute ago", minutes];
    }
    
    if ( minutes < 60 )
    {
        return [NSString stringWithFormat:@"%u minutes ago", minutes];
    }
    
    // hours
    NSInteger hours = [TimeFormatter convertToHours:delta];
    
    if ( hours == 1 )
    {
        return [NSString stringWithFormat:@"%u hour ago", hours];
    }
    
    if ( hours < 24 )
    {
        return [NSString stringWithFormat:@"%u hours ago", hours];
    }
    
    //days
    NSInteger days = [TimeFormatter convertToDays:delta];
    
    if ( days == 1 )
    {
        return [NSString stringWithFormat:@"%u day ago", days];
    }
    
    if ( days < 7 )
    {
        return [NSString stringWithFormat:@"%u days ago", days];
    }
    
    // weeks
    NSInteger weeks = [TimeFormatter convertToWeeks:delta];
    
    if ( weeks == 1 )
    {
        return [NSString stringWithFormat:@"%u week ago", weeks];
    }
    
    if ( weeks < 4 )
    {
        return [NSString stringWithFormat:@"%u weeks ago", weeks];
    }
    
    // months
    NSInteger months = [TimeFormatter convertToMonths:delta];
    
    if ( months == 1 )
    {
        return [NSString stringWithFormat:@"%u month ago", months];
    }
    
    return [NSString stringWithFormat:@"%u months ago", months];
    
}

// minutes
+ (NSTimeInterval)convertToMinutes:(NSTimeInterval)time
{
    return (time / 60.0);
}

// hours
+ (NSTimeInterval)convertToHours:(NSTimeInterval)time
{
    return ([TimeFormatter convertToMinutes:time] / 60.0);
}

// days
+ (NSTimeInterval)convertToDays:(NSTimeInterval)time
{
    return ([TimeFormatter convertToHours:time] / 24.0);
}

// weeks
+ (NSTimeInterval)convertToWeeks:(NSTimeInterval)time
{
    return ([TimeFormatter convertToDays:time] / 7.0);
}

// months
+ (NSTimeInterval)convertToMonths:(NSTimeInterval)time
{
    return ([TimeFormatter convertToWeeks:time] / 4.0);
}

// years
+ (NSTimeInterval)convertToYears:(NSTimeInterval)time
{
    return ([TimeFormatter convertToMonths:time] / 12.0);
}

@end
