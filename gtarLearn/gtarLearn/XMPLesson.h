//
//  XMPLesson.h
//  gtarLearn
//
//  Created by Idan Beck on 12/17/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPObject.h"
#import "XMPTree.h"

@interface XMPLesson : XMPObject {
    NSString *m_Description;
    NSString *m_Title;
    NSString *m_Author;
    
    NSArray *m_Chapters;
    
    // Lesson graphic?
    
    // Convenience
    XMPTree *m_pxmp;
}

- (id) initWithLessonName:(NSString *)LessonName;

-(RESULT)ConstructLessonFromXMPTree:(XMPTree*)pTree;

@end
