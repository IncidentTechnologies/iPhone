#include "XMPTree.h"
#include <string>
#include <stdlib.h>

// TODO: Move all objects into separate files

/* XMPValue *************/
XMPValue::XMPValue(char *pszValue) :
    m_ValueType(XMP_VALUE_INVALID),
    m_Buffer(NULL),
    m_BufferSize(0)
{
    SetValue(pszValue);
}

XMPValue::XMPValue(long int value) :
    m_ValueType(XMP_VALUE_INVALID),
    m_Buffer(NULL),
    m_BufferSize(0)
{
    SetValueInt(value);
}

RESULT XMPValue::SetValueInt(long int value) {
    RESULT r = R_SUCCESS;

    // This is an integer
    m_ValueType = XMP_VALUE_INTEGER;
    m_Buffer = new long int;
    //char *pEnd;
    //long int *TempInt = new long int(strtol(pszValue, &pEnd, 10));
    memcpy(m_Buffer, (void*)(&value), sizeof(long int));
    m_BufferSize = sizeof(long int);

Error:
    return r;
}

char* XMPValue::GetPszValue() {
    char *ReturnBuffer = new char[25];
    memset(ReturnBuffer, 0, sizeof(char) * 25);

    switch(m_ValueType)
    {
        case XMP_VALUE_INTEGER: sprintf(ReturnBuffer, "%d", *((long int*)m_Buffer));
                                break;
        case XMP_VALUE_DOUBLE:  sprintf(ReturnBuffer, "%f", *((double*)m_Buffer));
                                break;
        case XMP_VALUE_CHAR:    sprintf(ReturnBuffer, "%c", *((char*)m_Buffer));
                                break;
        case XMP_VALUE_STRING:  sprintf(ReturnBuffer, "%s", (char*)m_Buffer);
                                break;
        case XMP_VALUE_INVALID: 
        default:                strcpy(ReturnBuffer, "InvalidValue");
                                break;
    }
    
    return ReturnBuffer;
}

RESULT XMPValue::SetValueType(XMP_VALUE_TYPE xvt){ m_ValueType = xvt; return R_SUCCESS; }

RESULT XMPValue::SetValue(char *pszValue) {
    RESULT r = R_SUCCESS;

    // Scan the string and determine what kind of value it is
    int Length = strlen(pszValue);
    bool ContainsChars = false;
    bool FoundDecimalPoint = false;

    for(int i = 0; i < Length; i++)        
        if(pszValue[i] < '0' || pszValue[i] > '9')
            ContainsChars = true;
    
    if(!ContainsChars)
        for(int i = 0; i < Length; i++)        
            if(pszValue[i] == '.') {
                if(FoundDecimalPoint = false) 
                    FoundDecimalPoint = true;
                else
                    ContainsChars = true;       // found two decimal points                
            }

    if(ContainsChars) {
        if(Length > 1) {
            // Must be a string
            m_ValueType = XMP_VALUE_STRING;
            m_Buffer = new char[Length];
            strcpy((char*)m_Buffer, pszValue);
            m_BufferSize = sizeof(char) * Length;
        }
        else if(Length == 0) {
            m_ValueType = XMP_VALUE_CHAR;
            m_Buffer = new char;
            memcpy(m_Buffer, pszValue, sizeof(char));
            m_BufferSize = sizeof(char);
        }
    }
    else {
        if(FoundDecimalPoint) {
            // This is a floating point number
            m_ValueType = XMP_VALUE_DOUBLE;
            m_Buffer = new double;
            char *pEnd;
            float *TempFloat = new float(strtod(pszValue, &pEnd));
            memcpy(m_Buffer, (void*)TempFloat, sizeof(double));
            m_BufferSize = sizeof(double);
        }
        else {
            // This is an integer
            m_ValueType = XMP_VALUE_INTEGER;
            m_Buffer = new long int;
            char *pEnd;
            long int *TempInt = new long int(strtol(pszValue, &pEnd, 10));                
            memcpy(m_Buffer, (void*)TempInt, sizeof(long int));
            m_BufferSize = sizeof(long int);
        }
    }

Error:
    return r;
}

/* XMPAttribute *************/
XMPAttribute::XMPAttribute(char *pszName, char *pszValue) :
  m_pszName(pszName),
  m_XMPValue(pszValue)
{      
    if(pszName == NULL)        
        m_XMPValue.SetValueType(XMP_VALUE_INVALID);        // post-facto invalidation if name is not present
}

XMPAttribute::XMPAttribute(char *pszName, long int value) :
    m_pszName(pszName),
    m_XMPValue(value)
{      
    if(pszName == NULL)        
        m_XMPValue.SetValueType(XMP_VALUE_INVALID);        // post-facto invalidation if name is not present
}

XMPAttribute::XMPAttribute(XMPElement *pElement) :
  m_pszName(pElement->GetName()),
  m_XMPValue(pElement->GetValue())
{
    if(m_pszName == NULL)
        m_XMPValue.SetValueType(XMP_VALUE_INVALID);         // post-facto invalidation if name is not present
}

char* XMPAttribute::GetName(){
  return m_pszName; 
}

XMPValue XMPAttribute::GetXMPValue(){
  return m_XMPValue; 
}

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

/* XMPTree **************/
XMPTree::XMPTree(char* pszFilename) :
  m_pszFilename(pszFilename)
{
    RESULT r = R_SUCCESS;
    
    m_pRoot = new XMPNode("root", NULL);
    m_pNodeNav = m_pRoot;
    
    if(m_pszFilename != NULL) {
        m_pParser = new XMPParser(m_pszFilename);    
        CVRM(m_pParser, "XMPTree: XMPParser is invalid for %s file", pszFilename);
        ConstructTree();
        delete m_pParser;
    }

    Validate();
    return;
Error:
    Invalidate();
    return;
}

// XMP can be created out of nothing
XMPTree::XMPTree() :
  m_pszFilename(NULL)
{
    m_pRoot = new XMPNode("root", NULL);
    m_pNodeNav = m_pRoot;
}

XMPTree::~XMPTree() {
    // TODO: Implement this!
}

// Constructs tree based on the parser component
RESULT XMPTree::ConstructTree() {
    RESULT r = R_SUCCESS;

    list<XMPElement*>*Elements = m_pParser->GetElementList();        
    list<XMPElement*>::iterator it = Elements->First();
    XMPNode *CurrentNode = m_pRoot;
    XMPNode *CurrentEmptyNode = NULL;

    while(it != NULL) {
        //(*it)->PrintElement();  // debug: print out the list for fun

      switch((*it)->GetElementType()) {
        case XMP_START_TAG: {
            // In this case we crate a new tree node and move to that level
            if(CurrentEmptyNode != NULL)
                CurrentEmptyNode = NULL;

            XMPNode *TempNode = new XMPNode((*it)->GetName(), CurrentNode);
            CNRM(TempNode, "XMPTree.ConstructTree: Failed to create a new start tag node");
            CurrentNode->AddChild(TempNode);
            CurrentNode = TempNode;                    
        } break;

        case XMP_END_TAG: {
            // In this case we jump out into the previous level
            CurrentNode = CurrentNode->GetParent();
            CNRM(CurrentNode, "XMPTree.ConstructTree: End tag failure, current node is null!");
        } break;

        case XMP_EMPTY: {
            // In this case we create a new tree node but don't jump into it
            // need to set a pointer so if any attributes belong to the empty
            // tag they are correctly set.  This pointer is set to NULL anytime
            // another tag is encountered
            CurrentEmptyNode = NULL;        // reset just in case
            CurrentEmptyNode = new XMPNode((*it)->GetName(), CurrentNode);
            CNRM(CurrentEmptyNode, "XMPTree.ConstructTree: Failed to create a new empty tag node");
            CurrentNode->AddChild(CurrentEmptyNode);
        } break;

        case XMP_CONTENT: {
            // Creates a new content node and appends it to the current node (no need to enter the level)
            if(CurrentEmptyNode != NULL)
                CurrentEmptyNode = NULL;
            XMPNode *TempNode = new XMPNode("content", CurrentNode, (*it)->GetValue());
            CNRM(TempNode, "XMPTree.ConstructTree: Failed to create a new content node");
            CurrentNode->AddChild(TempNode);
        } break;

        case XMP_CONTENT_DATA: {
            // If an XMP Content Data node is encountered we will append just the data node to the current node
            // which should be a start tage
            //XMPNode *DataNode = new XMPNode()
            CNRM((*it)->GetBuffer(), "Data node has NULL buffer!");
            CBRM(((*it)->GetBufferSize() != 0), "Data node has zero sized data!");

            XMPNode *pData = new XMPNode("data", NULL, NULL, (*it)->GetBuffer(), (*it)->GetBufferSize());
            CRM(CurrentNode->AddChild(pData), "AppendData: Failed to append Data Content");
        } break;

        case XMP_TAG_ATTRIBUTE: {
            XMPAttribute *TempAttribute = new XMPAttribute((*it));
            CNRM(TempAttribute, "XMPTree.ConstructTree: Failed to create a new attribute");
            // Attributes can be given to empty nodes so we check if we have one
            if(CurrentEmptyNode != NULL)                    
                CurrentEmptyNode->AddAttribute(TempAttribute);                    
            else                    
                CurrentNode->AddAttribute(TempAttribute);                    
        } break;                

        case XMP_INVALID: {
            printf("XMPTree.ConstructTree: Invalid element type!\n");
        } break;

        default: {
            printf("XMPTree.ConstructTree: Could not add element type!\n");
        } break;

      };

      it++;     // Increment our point in the list of nodes
    }

    if(CurrentNode != m_pRoot) {
        CBRM(0, "XMP Error! No end tag found for %s", CurrentNode->GetName());
    }

Error:
    return r;
}

RESULT XMPTree::PrintXMPDepth(int depth, SmartBuffer* &n_psmbuf, FILE *pFile) {
    if(depth != 0)
        for(int i = 0; i < depth; i++)                     
            PrintXMPStr("    ", n_psmbuf, pFile);        

    return R_SUCCESS;
}

RESULT XMPTree::PrintXMPChar(char c, SmartBuffer* &n_psmbuf, FILE *pFile) {
    if(n_psmbuf != NULL) 
        *n_psmbuf += c;
    else if(pFile != NULL)
        fputc(c, pFile);
    else
        printf("%c", c);

    return R_SUCCESS;
}

RESULT XMPTree::PrintXMPStr(char *psz, SmartBuffer* &n_psmbuf, FILE *pFile) {
    if(n_psmbuf != NULL)
        *n_psmbuf += psz;
    else if(pFile != NULL)
        fputs(psz, pFile);
    else
        printf("%s", psz);

    return R_SUCCESS;
}

// Also output a smart buffer with the contents of the 
RESULT XMPTree::PrintXMPTree( XMPNode *node, int depth, SmartBuffer* &n_psmbuf, FILE *pFile) {
    RESULT r = R_SUCCESS;    

    if(node->IsContentNode()) {
        PrintXMPDepth(depth, n_psmbuf, pFile);
        PrintXMPStr(node->GetContentCopy(), n_psmbuf, pFile);
        PrintXMPChar('\n', n_psmbuf, pFile);
    }
    else if(node->IsDataNode()) {
        if(pFile == NULL)
            PrintXMPDepth(depth, n_psmbuf, pFile);

        char *tempChRg = new char[3];  

        if(pFile != NULL) {
            fputc((char)42, pFile);
            //fputs("data", pFile);
            int byteswritten = fwrite(node->m_pDataBuffer, 1, node->m_DataBuffer_s, pFile);
            CBRM((byteswritten == node->m_DataBuffer_s), "Written bytes %d and size %d do not match", byteswritten, node->m_DataBuffer_s);
            //fputs("enddata", pFile);
            fputc((char)42, pFile);
        }
        else {
            for(int i = 0; i < node->m_DataBuffer_s; i++) {                                           
                sprintf(tempChRg, "%0X\0", (unsigned int)(static_cast<unsigned int*>(node->m_pDataBuffer) + i));
                PrintXMPStr(tempChRg, n_psmbuf, pFile);                

                // Pop in a new line every 22 numbers
                if((i + 1) % 30 == 0) {                
                    PrintXMPChar('\n', n_psmbuf, pFile);
                    PrintXMPDepth(depth, n_psmbuf, pFile);
                }                
            }
        }

        PrintXMPChar('\n', n_psmbuf, pFile);

        delete [] tempChRg;
        tempChRg = NULL;

    }
    else {        
        PrintXMPDepth(depth, n_psmbuf, pFile);
        PrintXMPChar('<', n_psmbuf, pFile);
        PrintXMPStr(node->GetName(), n_psmbuf, pFile);

        //if(node == m_pNodeNav)
        //    PrintXMPChar('*', n_psmbuf, pFile);


        for(list<XMPAttribute*>::iterator attribit = node->GetAttributes()->First(); attribit != NULL; attribit++) {                        
            PrintXMPChar(' ', n_psmbuf, pFile);
            PrintXMPStr((*attribit)->GetName(), n_psmbuf, pFile);
            PrintXMPStr("=\"", n_psmbuf, pFile);
            PrintXMPStr((*attribit)->GetXMPValue().GetPszValue(), n_psmbuf, pFile);
            PrintXMPChar('\"', n_psmbuf, pFile);           
        }

        if(node->GetChildren()->Size() != 0) {            
            PrintXMPStr(">\n", n_psmbuf, pFile);

            for(list<XMPNode*>::iterator kidit = node->GetChildren()->First(); kidit != NULL; kidit++)
                PrintXMPTree((*kidit), depth + 1, n_psmbuf, pFile);

            PrintXMPDepth(depth, n_psmbuf, pFile);
            PrintXMPStr("</", n_psmbuf, pFile);
            PrintXMPStr(node->GetName(), n_psmbuf, pFile);
            PrintXMPStr(">\n", n_psmbuf, pFile);           
        }
        else {
            // must be an empty tag            
            PrintXMPStr(" />\n", n_psmbuf, pFile);
        }
    }

Error:
    return r;
}

RESULT XMPTree::PrintXMPTree(SmartBuffer* &n_psmbuf) {         
    n_psmbuf = new SmartBuffer();
    return PrintXMPTree(m_pRoot, 0, n_psmbuf); 
}

RESULT XMPTree::PrintXMPTree() {         
    SmartBuffer *pNulBuf = NULL;
    return PrintXMPTree(m_pRoot, 0, pNulBuf); 
}

RESULT XMPTree::SaveXMPToFile(char *pszFilename, bool fOverwrite) {
    RESULT r = R_SUCCESS;
    
    FILE *pFile = fopen(pszFilename, "r");
    if(pFile == NULL || fOverwrite) {
        if(pFile != NULL)
            fclose(pFile);
        pFile = fopen(pszFilename, "wb");
        
        SmartBuffer *pTemp = NULL;
        CRM(PrintXMPTree(m_pRoot, 0, pTemp, pFile), "SaveXMPToFile: Faild due to PrintXMPTree Failure");            
    }
    else        
        CBRM(0, "File %s already exists or overwrite flag not set!", pszFilename);        
    
    //CRM(pNulBuf->SaveToFile(pszFilename, fOverwrite), "SaveXMPToFile: Failed due to SaveToFile failure");

Error:
    if(pFile != NULL) {
        fclose(pFile);
        pFile = NULL;
    }
    return r;
}

// Navigation Functions
RESULT XMPTree::ResetNavigator() {
    m_pNodeNav = m_pRoot;
    return R_SUCCESS;
}

RESULT XMPTree::NavigateToChildName(char *pszName) {
    XMPNode *temp = m_pNodeNav->FindChildByName(pszName);
    if(temp != NULL) {
        m_pNodeNav = temp;
        return R_XMP_NODE_FOUND;
    }
    else
        return R_XMP_NODE_NOT_FOUND;
}

RESULT XMPTree::NavigateToParent() {
    XMPNode *temp = m_pNodeNav->GetParent();
    if(temp != NULL) {
        m_pNodeNav = temp;
        return R_XMP_NODE_FOUND;
    }
    else
        return R_XMP_NO_PARENT;
}

RESULT XMPTree::AddChildByName(char *pszName) {
    RESULT r = R_SUCCESS;

    XMPNode *pTemp = new XMPNode(pszName, m_pNodeNav, NULL);
    CRM(m_pNodeNav->AddChild(pTemp), "XMPTree:AddChildByName Failed to add child");
Error:
    return r;
}

RESULT XMPTree::AddAttributeByNameValue(char *pszName, char *pszValue) {
    RESULT r = R_SUCCESS;

    XMPAttribute *pTempAtrib = new XMPAttribute(pszName, pszValue);
    CNRM(pTempAtrib, "AddAttributeByNameValue: Failed to allocate attribute");
    CRM(AddAttribute(pTempAtrib), "AddAttributeByName: Failed to add attribute of name %s", pszName);
Error:
    return r;
}

RESULT XMPTree::AddAttribute(XMPAttribute *attrib) {
    RESULT r = R_SUCCESS;
    
    CRM(m_pNodeNav->AddAttribute(attrib), "XMPTree:AddAttribute Failed to add attribute");

Error:
    return r;
}

RESULT XMPTree::AppendContent(char *pszContent) {
    RESULT r = R_SUCCESS;

    XMPNode *pTemp = new XMPNode("content", NULL, pszContent);
    CRM(m_pNodeNav->AddChild(pTemp), "XMPTree:AppendContent Failed to append content");

Error:
    return r;
}

// AppendData is a more complex hybrid action which will append a new node and fill it
// with the data buffer passed
RESULT XMPTree::AppendData(char *pszDataName, long int DataID, void *pBuffer, long int pBuffer_s) {
    RESULT r = R_SUCCESS;
    
    XMPNode *pDataNode = NULL;
    XMPAttribute *pDataNameAttrib = NULL;
    XMPAttribute *pDataIDAtrib = NULL;
    XMPAttribute *pSizeAttrib = NULL;
    void *pTempBuffer = NULL;
    XMPNode *pData = NULL;

    pDataNode = new XMPNode("data", m_pNodeNav, NULL);
    CRM(m_pNodeNav->AddChild(pDataNode), "XMPTree:AppendData Failed to add data node");

    // Add the name attribute
    pDataNameAttrib = new XMPAttribute("dataname", pszDataName);
    CNRM(pDataNameAttrib, "AppendData: Failed to allocate the data name attribute");
    CRM(pDataNode->AddAttribute(pDataNameAttrib), "AppendData: Failed to add the data name attribute");

    // Add the DataID attribute 
    pDataIDAtrib = new XMPAttribute("dataid", DataID);
    CNRM(pDataIDAtrib, "AppendData: Failed to allocate data id attribute");
    CRM(pDataNode->AddAttribute(pDataIDAtrib), "AppendData: Failed to DataID attribute"); 

    // Add the Data Size attribute
    pSizeAttrib = new XMPAttribute("datasize", pBuffer_s);
    CNRM(pSizeAttrib, "AppendData: Failed to allocate data size attribute");
    CRM(pDataNode->AddAttribute(pSizeAttrib), "AppendData: Failed to add data size attribute");

    //Create a new char buffer out of the information
    // We need to make a copy of this data and give it to the node in case the memory is
    // deallocated somewhere else
    pTempBuffer = (void*)malloc(pBuffer_s);
    CNRM(pTempBuffer, "XMPTree:AppendData: failed to allocate node buffer size %d", pBuffer_s);
    memcpy(pTempBuffer, pBuffer, pBuffer_s);

    pData = new XMPNode("data", NULL, NULL, pTempBuffer, pBuffer_s);
    CRM(pDataNode->AddChild(pData), "AppendData: Failed to append Data Content");

Error:
    return r;
}

XMPNode* XMPTree::GetRootNode(){
  return m_pRoot; 
}






