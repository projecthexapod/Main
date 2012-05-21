;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: PWM8_2INT.asm
;;   Version: 2.60, Updated on 2012/3/2 at 9:15:10
;;  Generated by PSoC Designer 5.2.2551
;;
;;  DESCRIPTION: PWM8 Interrupt Service Routine
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2012. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"
include "PWM8_2.inc"
include "memory.inc"


;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------
export  _PWM8_2_ISR


AREA InterruptRAM (RAM,REL,CON)

;@PSoC_UserCode_INIT@ (Do not change this line.)
;---------------------------------------------------
; Insert your custom declarations below this banner
;---------------------------------------------------

;------------------------
; Includes
;------------------------

	
;------------------------
;  Constant Definitions
;------------------------


;------------------------
; Variable Allocation
;------------------------


;---------------------------------------------------
; Insert your custom declarations above this banner
;---------------------------------------------------
;@PSoC_UserCode_END@ (Do not change this line.)


AREA UserModules (ROM, REL)

;-----------------------------------------------------------------------------
;  FUNCTION NAME: _PWM8_2_ISR
;
;  DESCRIPTION: Unless modified, this implements only a null handler stub.
;
;-----------------------------------------------------------------------------
;

_PWM8_2_ISR:

   ;@PSoC_UserCode_BODY@ (Do not change this line.)
   push A
   mov A, [_m_to_s_mem+1]
   mov reg[PWM8_2_COMPARE_REG], A
   pop A
   ;@PSoC_UserCode_END@ (Do not change this line.)

   reti


; end of file PWM8_2INT.asm
