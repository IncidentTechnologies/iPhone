#pragma once

// The XMP parser will take the output of the XMPTokenizer and 
// convert it into a list of discernable XMP elements
#include "XMPTokenizer.h"
#include "RESULT.h"
#include "EHM.h"

typedef enum XMPElementType
{
    XMP_START_TAG,      // <tag>
    XMP_END_TAG,        // </tag>
    XMP_DECLARATION,    // <?declaration>     NOT SUPPORTED FOR NOW
    XMP_EMPTY,          // <empty/>
    XMP_COMMENT,        // <!-- comment -->  (usually not processed beyond this stage)   NOT SUPPORTED FOR NOW!
    XMP_CONTENT,        // this is not a tag but the content between two tags
    XMP_TAG_ATTRIBUTE,      // Attribute inside of a tag
    XMP_CONTENT_DATA,   // XMP specific data content
    XMP_INVALID         // an invalid XMP type, error!
} XMP_ELEMENT_TYPE;

extern const char* pszXMPElementType[];

class XMPElement
{
public:
    XMPElement(XMP_ELEMENT_TYPE type, char *pszName, char *pszValue = NULL) :
      m_Type(type),
      m_pszName(pszName),
      m_pszValue(pszValue),
      m_pBuffer(NULL),
      m_pBuffer_s(-1),
      m_pszDataname(NULL),
      m_dataid(-1)
    {
        /*empty here*/
    }

    XMPElement(void *pDataBuffer, long int datasize, int dataid, char *pszDataName) :
      m_Type(XMP_CONTENT_DATA),
      m_pszName(NULL),
      m_pszValue(NULL),
      m_pBuffer(pDataBuffer),
      m_pBuffer_s(datasize),
      m_pszDataname(pszDataName),
      m_dataid(dataid)
    {
        /*empty here*/
    }

    ~XMPElement()
    {
        /*empty stub*/
    }

    RESULT PrintElement()
    {
        printf("Element type:%s ", pszXMPElementType[m_Type]);

        if(m_pszName != NULL)
            printf("name:%s ", m_pszName);
        
        if(m_pszValue != NULL)
            printf("value:%s ", m_pszValue);

        printf("\n");
        return R_SUCCESS;
    }

    XMP_ELEMENT_TYPE GetElementType(){ return m_Type; }
    RESULT SetElementType(XMP_ELEMENT_TYPE type){ m_Type = type; return R_SUCCESS; }

    char *GetName(){ return m_pszName; }
    char *GetValue(){ return m_pszValue; }

    void *GetBuffer(){ return m_pBuffer; }
    long int GetBufferSize(){ return m_pBuffer_s; }
    int GetDataID(){ return m_dataid; }
    char *GetDataName(){ return m_pszDataname; }

private:
    XMP_ELEMENT_TYPE m_Type;
    char *m_pszName;
    char *m_pszValue;

    // data info
    void *m_pBuffer;
    long int m_pBuffer_s;
    int m_dataid;
    char *m_pszDataname;
};

class XMPParser :
    public valid
{
public:
    XMPParser() :
      m_pTokenizer(NULL)
      {
          //RESULT r = R_SUCCESS;

          // Create the element list
          m_pElements = new list<XMPElement*>();

          Validate();
          return;
Error:
          Invalidate();
          return;
      }

    XMPParser(const char* pszFile) :
      m_pTokenizer(NULL)
    {
        RESULT r = R_SUCCESS;
        
        // Tokenize the file outputs a list of tokens
		// The parser then converts this into a list of
		// elements
        m_pTokenizer = new XMPTokenizer(pszFile);

        CVRM(m_pTokenizer, "XMPParser: Tokenizer for file %s was invalid", pszFile);
        
        // Create the element list
        m_pElements = new list<XMPElement*>();
		ParseTokens();

        //for(list<XMPElement*>::iterator it = m_pElements->First(); it != NULL; it++)
        //{
            //reinterpret_cast<XMPElement*>(*it)->PrintElement();
        //}

        Validate();
        return;
    Error:
        Invalidate();
        return;
    }

	XMPTokenizer *GetXMPTokenizer(){ return m_pTokenizer; }
    
    // Will return the index of the character in the string before
    // hitting the end of the string or a specific delimiter provided
    // by delim.  Instance is a variable that will allow finding the #instance
    // occurance of said character
    // Using instance <= 0 will find the last instance of the character in a block 
    static int FindCharInString(const char *pszString, char c, char delim, int instance);

    // Will remove whitespace at beginning and end of string
    char *RemoveWhitespacePads(char* &dr_pszSrc);
    static char* RemoveWhitespace(char *pszSrc);

    RESULT ExtractAttributes(char* pszToken, list<XMPElement*> *plistElements);
	
    
    RESULT ParseTokens();
    RESULT ParseTokens(char *pszString);

    list<XMPElement*>*GetElementList(){ return m_pElements; }

private:
    list<XMPElement*> *m_pElements;
    XMPTokenizer *m_pTokenizer;
};