#include "XMPValue.h"
#include <string>
#include <stdlib.h>

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
