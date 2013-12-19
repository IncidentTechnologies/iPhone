//
//  XMPLesson.m
//  gtarLearn
//
//  Created by Idan Beck on 12/17/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import "XMPLesson.h"
#import "dss_list.h"
#import "XMPLessonChapter.h"

@implementation XMPLesson

using namespace dss;

- (id) initWithLessonName:(NSString *)LessonName {
    RESULT r = R_SUCCESS;
    NSError *pError = NULL;
    NSString *pTempFilePath = NULL;
    
    CPRM((self = [super init]), "initWithLessonName: Failed to init super");
    pTempFilePath = [[NSBundle mainBundle] pathForResource:LessonName ofType:@"xmp"];
    CNRM(pTempFilePath, "initWithLessonName: Lesson not found!");
    
    m_pxmp = new XMPTree((char *)[pTempFilePath UTF8String]);
    m_pxmp->PrintXMPTree();
    
    // init chapters array
    m_type = XMP_OBJECT_LESSON;
    m_Chapters = [[NSArray alloc] init];
    m_xmpNode = m_pxmp->GetRootNode();
    
    // TODO: ?
    // [self BuildChildren];
        
    CRM([self ConstructLessonFromXMPTree:m_pxmp], "initWithLessonName: Failed to construct from XMP");

    return self;
Error:
    return NULL;
}

-(RESULT)ConstructLessonFromXMPTree:(XMPTree*)pTree {
    RESULT r = R_SUCCESS;
    list<XMPNode*>* chapters = NULL;
    int a = 5;
    
    XMPNode *tempNode = NULL;
    XMPNode *nxmp = pTree->GetRootNode();
    CPRM((nxmp = nxmp->FindChildByName((char*)"xmp")), "ConstructLessonFromXMPTree: XMP node not present");
    CPRM((nxmp = nxmp->FindChildByName((char*)"header")), "ConstructLessonFromXMPTree: Header node not present");
    
    if((tempNode = nxmp->FindChildByName((char*)"description")) != NULL)
        m_Description = [[NSString alloc] initWithCString:tempNode->text() encoding:NSUTF8StringEncoding];
    
    if((tempNode = nxmp->FindChildByName((char*)"title")) != NULL)
        m_Title = [[NSString alloc] initWithCString:tempNode->text() encoding:NSUTF8StringEncoding];
    
    if((tempNode = nxmp->FindChildByName((char*)"author")) != NULL)
        m_Author = [[NSString alloc] initWithCString:tempNode->text() encoding:NSUTF8StringEncoding];
    
    CPR((nxmp = nxmp->GetParent()));
    CPRM((nxmp = nxmp->FindChildByName((char*)"content")), "ConstructLessonFroXMPTree: Failed to find lesson content");
    
    // Construct the chapters
    CNRM((chapters = nxmp->GetChildren("chapter")), "ConstructLessonFromXMPTree: Lesson contains no lessons");
    for(dss::list<XMPNode*>::iterator it = chapters->First(); it != NULL; it++) {
        XMPLessonChapter *xmpLessonChapter = [[XMPLessonChapter alloc] initWithParentLesson:self andXMPNode:(*it)];
        m_Chapters = [m_Chapters arrayByAddingObject:xmpLessonChapter];
    }

    
Error:
    return r;
}

@end
