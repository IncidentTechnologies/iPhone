//
//  TimeFormatter.m
//  gTarAppCore
//
//  Created by Marty Greenia on 10/27/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "TimeFormatter.h"

@implementation TimeFormatter

+ (NSTimeInterval)convertDateStringToInterval:(NSString*)dateString {
    NSDateFormatter * dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [[dateFormat dateFromString:dateString] timeIntervalSince1970];
}

+ (NSTimeInterval)intervalFromNow:(NSTimeInterval)time {
    NSDate * date = [NSDate date];
    NSTimeInterval now = [date timeIntervalSince1970];
    return (now - time);
}

+ (NSString*)stringFromNow:(NSTimeInterval)time {
    NSDate * date = [NSDate date];
    NSTimeInterval now = [date timeIntervalSince1970];
    
    if ( time > now )
        return [NSString stringWithFormat:NSLocalizedString(@"The Future", NULL)];
    
    NSTimeInterval delta = now - time;
    NSInteger seconds = (NSInteger)delta;
    // seconds
    if ( seconds == 1 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u second ago", NULL), seconds];
    
    if ( seconds < 60 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u seconds ago", NULL), seconds];
    
    // minutes
    NSInteger minutes = [TimeFormatter convertToMinutes:delta];
    if ( minutes == 1 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u minute ago", NULL), minutes];
    
    if ( minutes < 60 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u minutes ago", NULL), minutes];
    
    // hours
    NSInteger hours = [TimeFormatter convertToHours:delta];
    if ( hours == 1 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u hour ago", NULL), hours];
    
    if ( hours < 24 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u hours ago", NULL), hours];
    
    //days
    NSInteger days = [TimeFormatter convertToDays:delta];
    if ( days == 1 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u day ago", NULL), days];
    
    if ( days < 7 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u days ago", NULL), days];
    
    // weeks
    NSInteger weeks = [TimeFormatter convertToWeeks:delta];
    
    if ( weeks == 1 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u week ago", NULL), weeks];

    if ( weeks < 4 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u weeks ago", NULL), weeks];
    
    // months
    NSInteger months = [TimeFormatter convertToMonths:delta];
    if ( months == 1 )
        return [NSString stringWithFormat:NSLocalizedString(@"%u month ago", NULL), months];
    
    return [NSString stringWithFormat:NSLocalizedString(@"%u months ago", NULL), months];
    
}

// minutes
+ (NSTimeInterval)convertToMinutes:(NSTimeInterval)time {
    return (time / 60.0);
}

// hours
+ (NSTimeInterval)convertToHours:(NSTimeInterval)time {
    return ([TimeFormatter convertToMinutes:time] / 60.0);
}

// days
+ (NSTimeInterval)convertToDays:(NSTimeInterval)time {
    return ([TimeFormatter convertToHours:time] / 24.0);
}

// weeks
+ (NSTimeInterval)convertToWeeks:(NSTimeInterval)time {
    return ([TimeFormatter convertToDays:time] / 7.0);
}

// months
+ (NSTimeInterval)convertToMonths:(NSTimeInterval)time {
    return ([TimeFormatter convertToWeeks:time] / 4.0);
}

// years
+ (NSTimeInterval)convertToYears:(NSTimeInterval)time {
    return ([TimeFormatter convertToMonths:time] / 12.0);
}

@end
