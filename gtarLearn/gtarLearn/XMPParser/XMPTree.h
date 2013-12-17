#pragma once

// XMP Tree takes an XMP Parser object as an input / or creates
// one internally.  Then it will create the appropriate XMP
// Tree that can then be navigated 

#include "XMPParser.h"
#include "dss_list.h"

// XMP Values are types of values that can be put into the XML file format
typedef enum XMPValueTypes
{
    XMP_VALUE_INTEGER,
    XMP_VALUE_DOUBLE,
    XMP_VALUE_CHAR,
    XMP_VALUE_STRING,
    XMP_VALUE_INVALID
} XMP_VALUE_TYPE;

// XMPValue takes a string as an input and will convert it internally as a value
class XMPValue {
public:
    XMPValue(char *pszValue); 
    XMPValue(long int value); 

    RESULT SetValueInt(long int value);
    RESULT SetValueType(XMP_VALUE_TYPE xvt);
    RESULT SetValue(char *pszValue);
    
    char *GetPszValue();
    
public:
    XMP_VALUE_TYPE m_ValueType;
    void *m_Buffer;
    int m_BufferSize;
};

class XMPAttribute {
public:
    XMPAttribute(char *pszName = NULL, char *pszValue = NULL);
    XMPAttribute(char *pszName = NULL, long int value = 0);
    XMPAttribute(XMPElement *pElement);

    char *GetName();
    XMPValue GetXMPValue();

private:
    char *m_pszName;
    XMPValue m_XMPValue;
};

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

class XMPTree : public valid {
public:
    // XMP can be created out of an existing file
    XMPTree(char* pszFilename);
    XMPTree();      // XMP can be created out of nothing
    ~XMPTree();

    RESULT ConstructTree();
    
    RESULT PrintXMPDepth(int depth, SmartBuffer* &n_psmbuf, FILE *pFile);
    RESULT PrintXMPChar(char c, SmartBuffer* &n_psmbuf, FILE *pFile);
    RESULT PrintXMPStr(char *psz, SmartBuffer* &n_psmbuf, FILE *pFile);
    RESULT PrintXMPTree(SmartBuffer* &n_psmbuf);
    RESULT PrintXMPTree();
    RESULT PrintXMPTree(XMPNode *node, int depth, SmartBuffer* &n_psmbuf, FILE *pFile = NULL);
    
    RESULT SaveXMPToFile(char *pszFilename, bool fOverwrite);

    // Navigation Functions
    RESULT ResetNavigator();
    RESULT NavigateToChildName(char *pszName);
    RESULT NavigateToParent();
    RESULT AddChildByName(char *pszName);
    RESULT AddAttributeByNameValue(char *pszName, char *pszValue);
    RESULT AddAttribute(XMPAttribute *attrib);
    RESULT AppendContent(char *pszContent);

    // AppendData is a more complex hybrid action which will append a new node and fill it
    // with the data buffer passed
    RESULT AppendData(char *pszDataName, long int DataID, void *pBuffer, long int pBuffer_s);

    XMPNode *GetRootNode();

private:
    // Parser Object for use to parse out the file
    XMPParser *m_pParser;
    
    char *m_pszFilename;

    // Root node of the tree
    XMPNode *m_pRoot;

    // Tree Cursor for Navigation
    XMPNode *m_pNodeNav;
};

