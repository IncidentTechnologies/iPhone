#pragma once

// XMPValue is a value in an XMP file

#include "dss_list.h"
#include "SmartBuffer.h"

using namespace dss;

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
