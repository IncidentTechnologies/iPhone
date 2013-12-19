//
//  XMPLessonChapter.m
//  gtarLearn
//
//  Created by Idan Beck on 12/17/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import "XMPLessonChapter.h"
#import "XMPLesson.h"
#import "XMPAttribute.h"
#import "XMPValue.h"
#import "XMPObjectFactory.h"

@implementation XMPLessonChapter

-(id)initWithParentLesson:(XMPLesson*)parentLesson andXMPNode:(XMPNode*)xmpNode {
    RESULT r = R_SUCCESS;
    
    m_xmpNode = xmpNode;
    CPRM((self = [super init]), "initWithParentLesson: Failed to init super");
    
    m_type = XMP_OBJECT_CHAPTER;
    m_ParentLesson = parentLesson;

    
    // Construct Lesson
    CRM([self ConsructLessonChapterFromChapterNode:m_xmpNode], "initWithParentLesson: Failed to construct chapter");
    
    return self;
Error:
    return NULL;

}

-(RESULT)ConsructLessonChapterFromChapterNode:(XMPNode*)chapterNode {
    RESULT r = R_SUCCESS;
    
    // Get the title
    XMPValue chapterTitle = chapterNode->GetAttribute((char*)"title")->GetXMPValue();
    m_Title = [[NSString alloc] initWithCString:chapterTitle.GetPszValue() encoding:NSUTF8StringEncoding];
    
    list<XMPNode*>* chapterContents = chapterNode->GetChildren();
    
    for(list<XMPNode*>::iterator it = chapterContents->First(); it != NULL; it++) {
        XMPObject *newObj = [XMPObjectFactory MakeXMPObject:(*it)];

        if(newObj != NULL)
            [m_contents addObject:newObj];
    }
Error:
    return r;
}

@end
