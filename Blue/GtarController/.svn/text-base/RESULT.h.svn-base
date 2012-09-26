#ifndef RESULT_H_
#define RESULT_H_

// ****************************************************************************
// *                           * RESULT for iPhone *                          *
// ****************************************************************************
/*  RESULT for iPhone provides a smaller and restrained set of RESULT codes
 *  for the purpose of use in the embedded platform.  This provide a direct 
 *  connection between the firmware and platform for greater flexability down
 *  the line
// ****************************************************************************/

#ifndef NULL
	#define NULL 0
#endif

#ifndef DEBUG_COMMON
    #define DEBUG_COMMON
#endif

// Error codes  
// Success is anything equal to or greater than zero
// Failure is anything less than zero (0x8.....) since 8 = 0b1000

#define CHECK_ERR(r) ((r & 0x80000000) != 0)

/// <resultor>
typedef enum incident_result
{
    // Failure Codes
    R_FAIL  		= 0x80000000,
    R_NO    		= 0x80000000,
    R_ERROR 		= 0x80000000,
    R_FALSE 		= 0x80000000,
    R_DEPRECATED	= 0x80000001,			// Deprecated is an error, since this should not be called
    
    // Success Codes
    R_SUCCESS       = 0x00000000,
    R_YES           = 0x00000000,
    R_TRUE			= 0x00000000,
    //R_OK            = 0x00000000,     // interferes with an iPhone value
    R_DONE          = 0x00000000,
    R_NO_ISSUE      = 0x00000000,
    
    // Warning
    R_UNSUPPORTED   = 0x00000010,
    R_NO_EFFECT		= 0x00000010,
    
    
    R_INVALID_RESULT        = 0xFFFFFFFF        // Last result EVER!
} RESULT; // End of typedef enum incident_results

#endif /*RESULT_H_*/
