#import "XMPTrack.h"
#import "dss_list.h"

@implementation XMPTrack

using namespace dss;

-(id) initWithXMPNode:(XMPNode*)xmpNode {
    RESULT r = R_SUCCESS;
    
    m_xmpNode = xmpNode;
    CPRM((self = [super init]), "initWithLessonName: Failed to init super");
    m_type = XMP_OBJECT_TRACK;
    
    CRM([self ConstructTrack], "initWithLessonName: Failed to construct from XMP");
    
    return self;
Error:
    return NULL;
}

-(RESULT)ConstructTrack {
    RESULT r = R_SUCCESS;
    
    XMPValue trackNameVal = [self GetAttributeValueWithName:@"main"];
    if(trackNameVal.m_ValueType != XMP_VALUE_INVALID)
        m_Name = [[NSString alloc] initWithCString:trackNameVal.GetPszValue() encoding:NSUTF8StringEncoding];
    else
        m_Name = @"";
    
Error:
    return r;
}

@end