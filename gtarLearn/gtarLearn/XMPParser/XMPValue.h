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
    XMPValue();
    XMPValue(char *pszValue); 
    XMPValue(long int value);
    XMPValue(double value);

    RESULT SetValueInt(long int value);
    RESULT SetValueDouble(double value);
    RESULT SetValueType(XMP_VALUE_TYPE xvt);
    RESULT SetValue(char *pszValue);
    
    char *GetPszValue();
    RESULT GetValueInt(long int *);
    RESULT GetValueDouble(double *);
    RESULT SetValueChar(char value);
    
    RESULT SetBuffer(void *newBuffer, int newBuffer_n, XMP_VALUE_TYPE newType);
    
    // Operators
    XMPValue &operator=(const XMPValue &rhs);
    XMPValue &operator+=(const XMPValue &rhs);
    XMPValue &operator--(int /*unused*/);
    XMPValue &operator++(int /*unused*/);
    XMPValue &operator-=(const XMPValue &rhs);
    
    const XMPValue operator+(const XMPValue &rhs);
    const XMPValue operator-(const XMPValue &rhs);
    
    static SmartBuffer CreateSmartBuffer(XMPValue *xmpValue);
    
public:
    XMP_VALUE_TYPE m_ValueType;
    void *m_Buffer;
    int m_BufferSize;
};
