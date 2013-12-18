#include "XMPNode.h"
#include <string>
#include <stdlib.h>
#include "XMPParser.h"

XMPNode::XMPNode(char *pszName, XMPNode *Parent, char *pszContent, void *pDataBuffer, long int DataBuffer_s) :
  //m_pszName(),
  m_Parent(Parent),
  m_fRoot(false),
  m_fContent(false),
  m_sbContent(NULL),
  m_pDataBuffer(pDataBuffer),
  m_DataBuffer_s(DataBuffer_s),
  m_fData(false)
{
    if(pszContent != NULL) {
        m_fContent = true;
        m_sbContent = new SmartBuffer(pszContent);        
    }
    
    if(pDataBuffer != NULL && DataBuffer_s > 0) {
        m_fData = true;
    }
    
    if(m_Parent == NULL && m_sbContent == NULL) {
        m_fRoot = true;        
    }

    m_pszName = XMPParser::RemoveWhitespace(pszName);
}

XMPNode::~XMPNode() {
    // TODO: NEED TO DO THIS
}

RESULT XMPNode::AddChild(XMPNode *child) {
    RESULT r = R_SUCCESS;

    CBRM(!m_fContent, "XMLTreeNode.AddChild: Cannot add child to a content node!");
    CRM(m_Children.Append(child), "XMPNode.AddChild: Failed to append child");

Error:
    return r;
}

// Find Child currently works based on sequential search
// this might need to be optimized in the future
XMPNode* XMPNode::FindChildByName(char *pszName) {
    for(list<XMPNode*>::iterator it = m_Children.First(); it != NULL; it++)        
        if(strcmp((*it)->GetName(), pszName) == 0)            
            return (*it);                    
    return NULL;
}

RESULT XMPNode::AddAttribute(XMPAttribute *attribute) {
    RESULT r = R_SUCCESS;

    CBRM(!m_fContent, "XMLTreeNode.AddChild: Cannot add attribute to a content node!");
    CRM(m_Attributes.Append(attribute), "XMPNode.AddChild: Failed to push child");

Error:
    return r;
}

XMPNode* XMPNode::GetParent(){
  return m_Parent; 
}

char* XMPNode::GetName(){
  return m_pszName; 
}

// This function will copy the Content!
char* XMPNode::GetContentCopy() {
    return m_sbContent->CreateBufferCopy();
}

bool XMPNode::Empty() {
    if(m_Children.Size() == 0 && !m_fContent)
        return true;
    else
        return false;
}

RESULT XMPNode::AppendContent(char *pszContent) {
    RESULT r = R_SUCCESS;

    CBRM(m_fContent, "XMPNode: Cannot append content to non-content node!");

    if(m_sbContent == NULL) {
        m_sbContent = new SmartBuffer(pszContent);
        CPRM(m_sbContent, "XMPNode.SetContent: Cannot create content smart buffer!");
    }
    else {
        CRM(m_sbContent->Append(new SmartBuffer(pszContent)), "XMPNode.SetContent: Failed to append new content to pre-existing content"); 
    }

Error:
    return r;
}

bool XMPNode::IsContentNode(){ 
  return m_fContent; 
}

bool XMPNode::IsDataNode(){ 
  return m_fData; 
}

list<XMPNode*>* XMPNode::GetChildren(){
  return &m_Children; 
}

list<XMPAttribute*>* XMPNode::GetAttributes(){
  return &m_Attributes; 
}
