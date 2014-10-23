//
//  TimeFormatter.h
//  gTarAppCore
//
//  Created by Marty Greenia on 10/27/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TimeFormatter : NSObject {
    
}

+ (NSTimeInterval)convertDateStringToInterval:(NSString*)dateString;
+ (NSTimeInterval)intervalFromNow:(NSTimeInterval)time;
+ (NSString*)stringFromNow:(NSTimeInterval)time;

+ (NSTimeInterval)convertToMinutes:(NSTimeInterval)time;
+ (NSTimeInterval)convertToHours:(NSTimeInterval)time;
+ (NSTimeInterval)convertToDays:(NSTimeInterval)time;
+ (NSTimeInterval)convertToWeeks:(NSTimeInterval)time;
+ (NSTimeInterval)convertToMonths:(NSTimeInterval)time;
+ (NSTimeInterval)convertToYears:(NSTimeInterval)time;

@end
