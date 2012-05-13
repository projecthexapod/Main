//*****************************************************************************
//*****************************************************************************
//  FILENAME: PWM8.h
//   Version: 2.60, Updated on 2011/6/28 at 6:9:51
//  Generated by PSoC Designer 5.1.2306
//
//  DESCRIPTION: PWM8 User Module C Language interface file
//-----------------------------------------------------------------------------
//  Copyright (c) Cypress Semiconductor 2011. All Rights Reserved.
//*****************************************************************************
//*****************************************************************************
#ifndef PWM8_INCLUDE
#define PWM8_INCLUDE

#include <m8c.h>

#pragma fastcall16 PWM8_EnableInt
#pragma fastcall16 PWM8_DisableInt
#pragma fastcall16 PWM8_Start
#pragma fastcall16 PWM8_Stop
#pragma fastcall16 PWM8_bReadCounter              // Read  DR0
#pragma fastcall16 PWM8_WritePeriod               // Write DR1
#pragma fastcall16 PWM8_bReadPulseWidth           // Read  DR2
#pragma fastcall16 PWM8_WritePulseWidth           // Write DR2

// The following symbols are deprecated.
// They may be omitted in future releases
//
#pragma fastcall16 bPWM8_ReadCounter              // Read  DR0 (Deprecated)
#pragma fastcall16 bPWM8_ReadPulseWidth           // Read  DR2 (Deprecated)


//-------------------------------------------------
// Prototypes of the PWM8 API.
//-------------------------------------------------

extern void PWM8_EnableInt(void);                        // Proxy Class 1
extern void PWM8_DisableInt(void);                       // Proxy Class 1
extern void PWM8_Start(void);                            // Proxy Class 1
extern void PWM8_Stop(void);                             // Proxy Class 1
extern BYTE PWM8_bReadCounter(void);                     // Proxy Class 2
extern void PWM8_WritePeriod(BYTE bPeriod);              // Proxy Class 1
extern BYTE PWM8_bReadPulseWidth(void);                  // Proxy Class 1
extern void PWM8_WritePulseWidth(BYTE bPulseWidth);      // Proxy Class 1

// The following functions are deprecated.
// They may be omitted in future releases
//
extern BYTE bPWM8_ReadCounter(void);            // Deprecated
extern BYTE bPWM8_ReadPulseWidth(void);         // Deprecated


//--------------------------------------------------
// Constants for PWM8 API's.
//--------------------------------------------------

#define PWM8_CONTROL_REG_START_BIT             ( 0x01 )
#define PWM8_INT_REG_ADDR                      ( 0x0e1 )
#define PWM8_INT_MASK                          ( 0x02 )


//--------------------------------------------------
// Constants for PWM8 user defined values
//--------------------------------------------------

#define PWM8_PERIOD                            ( 0xff )
#define PWM8_PULSE_WIDTH                       ( 0x00 )


//-------------------------------------------------
// Register Addresses for PWM8
//-------------------------------------------------

#pragma ioport  PWM8_COUNTER_REG:   0x024                  //DR0 Count register
BYTE            PWM8_COUNTER_REG;
#pragma ioport  PWM8_PERIOD_REG:    0x025                  //DR1 Period register
BYTE            PWM8_PERIOD_REG;
#pragma ioport  PWM8_COMPARE_REG:   0x026                  //DR2 Compare register
BYTE            PWM8_COMPARE_REG;
#pragma ioport  PWM8_CONTROL_REG:   0x027                  //Control register
BYTE            PWM8_CONTROL_REG;
#pragma ioport  PWM8_FUNC_REG:  0x124                      //Function register
BYTE            PWM8_FUNC_REG;
#pragma ioport  PWM8_INPUT_REG: 0x125                      //Input register
BYTE            PWM8_INPUT_REG;
#pragma ioport  PWM8_OUTPUT_REG:    0x126                  //Output register
BYTE            PWM8_OUTPUT_REG;
#pragma ioport  PWM8_INT_REG:       0x0e1                  //Interrupt Mask Register
BYTE            PWM8_INT_REG;


//-------------------------------------------------
// PWM8 Macro 'Functions'
//-------------------------------------------------

#define PWM8_Start_M \
   PWM8_CONTROL_REG |=  PWM8_CONTROL_REG_START_BIT

#define PWM8_Stop_M  \
   PWM8_CONTROL_REG &= ~PWM8_CONTROL_REG_START_BIT

#define PWM8_EnableInt_M   \
   M8C_EnableIntMask(PWM8_INT_REG, PWM8_INT_MASK)

#define PWM8_DisableInt_M  \
   M8C_DisableIntMask(PWM8_INT_REG, PWM8_INT_MASK)

#endif
// end of file PWM8.h
