#pragma once

// Valid.h
// Valid is an inheritable object that is used to 
// indicate when an object is valid and if fully functional.
// This is particularily useful when an objects initialization 
// could fail and there would otherwise be no otherway to tell
// especially when initialization is done inside of the constructor

class valid
{
public:
    valid() :
        m_fValid(false)
    { /* empty stub */ }
    
    ~valid()
    {/*empty stub*/}

    bool IsValid()
    {
        return m_fValid;
    }

public:
    bool Validate(){ return (m_fValid = true); }
    bool Invalidate(){ return (m_fValid = false); }

    // virtual function that should be implemented and called when 
    // any changes are made to the object
    virtual bool Evaluate() = 0;    
    
private:
    bool m_fValid;
};




