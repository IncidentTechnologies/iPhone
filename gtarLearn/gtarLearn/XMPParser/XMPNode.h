#pragma once

// XMP Node is a node in an XMP tree 

#include "dss_list.h"
#include "SmartBuffer.h"
#include "XMPAttribute.h"


using namespace dss;

class XMPNode {
public:
    XMPNode(char *pszName, XMPNode *Parent = NULL, char *pszContent = NULL, void *pDataBuffer = NULL, long int DataBuffer_s = 0); 

    ~XMPNode();

    RESULT AddChild(XMPNode *child);

    // Find Child currently works based on sequential search
    // this might need to be optimized in the future
    XMPNode *FindChildByName(char *pszName);

    RESULT AddAttribute(XMPAttribute *attribute);

    XMPNode *GetParent();    
    char *GetName();
    char *GetContentCopy();
    bool Empty(); 

    RESULT AppendContent(char *pszContent);

    bool IsContentNode();
    bool IsDataNode();
    
    list<XMPNode*>*GetChildren();
    list<XMPAttribute*>*GetAttributes();

private:
    char *m_pszName;        // Tag name
    list<XMPAttribute*> m_Attributes;    // List of attributes 
    bool m_fRoot;           // Root flag

    // Structure
    XMPNode *m_Parent;          // Parent tag, this can be NULL but will usually be an XML ROOT 
    list<XMPNode*> m_Children;  // List of child tags

    bool m_fContent;                // Designates this as a content node, content nodes may not have children
    SmartBuffer *m_sbContent;       // Content of the node, can be NULL in many cases

public:
    // Data content
    bool m_fData;
    void *m_pDataBuffer;
    long int m_DataBuffer_s;
};
