;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME:   UARTINT.asm
;;  Version: 5.3, Updated on 2011/6/28 at 6:10:17
;;  Generated by PSoC Designer 5.1.2306
;;
;;  DESCRIPTION:  UART Interrupt Service Routine.
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2011. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************


include "UART.inc"
include "memory.inc"
include "m8c.inc"

;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------
export  _UART_TX_ISR
export  _UART_RX_ISR

IF (UART_RXBUF_ENABLE)
export  UART_aRxBuffer
export _UART_aRxBuffer
export  UART_bRxCnt
export _UART_bRxCnt
export  UART_fStatus
export _UART_fStatus
ENDIF


;-----------------------------------------------
; Variable Allocation
;-----------------------------------------------
AREA InterruptRAM (RAM, REL, CON)

IF (UART_RXBUF_ENABLE)
 UART_fStatus:
_UART_fStatus:      BLK  1
 UART_bRxCnt:
_UART_bRxCnt:       BLK  1
AREA UART_RAM (RAM, REL, CON)
 UART_aRxBuffer:
_UART_aRxBuffer:    BLK UART_RX_BUFFER_SIZE
ENDIF

AREA InterruptRAM (RAM, REL, CON)

;@PSoC_UserCode_INIT@ (Do not change this line.)
;---------------------------------------------------
; Insert your custom declarations below this banner
;---------------------------------------------------

;------------------------
;  Includes
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


AREA UserModules (ROM, REL, CON)

;-----------------------------------------------------------------------------
;  FUNCTION NAME: _UART_TX_ISR
;
;  DESCRIPTION:
;     UART TX interrupt handler for instance UART.
;
;     This is a place holder function.  If the user requires use of an interrupt
;     handler for this function, then place code where specified.
;-----------------------------------------------------------------------------

_UART_TX_ISR:
   ;@PSoC_UserCode_BODY_1@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom assembly code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.
   
   ;---------------------------------------------------
   ; Insert your custom assembly code above this banner
   ;---------------------------------------------------
   
   ;---------------------------------------------------
   ; Insert a lcall to a C function below this banner
   ; and un-comment the lines between these banners
   ;---------------------------------------------------
   
   ;PRESERVE_CPU_CONTEXT
   ;lcall _My_C_Function
   ;RESTORE_CPU_CONTEXT
   
   ;---------------------------------------------------
   ; Insert a lcall to a C function above this banner
   ; and un-comment the lines between these banners
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
   reti


;-----------------------------------------------------------------------------
;  FUNCTION NAME: _UART_RX_ISR
;
;  DESCRIPTION:
;     UART RX interrupt handler for instance UART.
;     This ISR handles the background processing of received characters if
;     the buffer is enabled.
;
;
;  The following assumes that the RX buffer feature has been enabled.
;
;  SIDE EFFECTS:
;     There are 3 posible errors that may occur with the serial port.
;      1) Parity Error
;      2) Framing Error
;      3) OverRun Error
;
;  This user module check for parity and framing error.  If either of these
;  two errors are detected, the data is read and ignored.  When an overRun
;  error occurs, the last byte was lost, but the current byte is valid.  For
;  this reason this error is ignored at this time.  Code could be added to
;  this ISR to set a flag if an error condition occurs.
;
;  THEORY of OPERATION:
;     When using the RX buffer feature, the ISR collects received characters
;     in a buffer until the user defined command terminator is detected.  After
;     the command terminator is detected, the command bit is set and all other
;     characters will be ignored until the command bit is reset.  Up to
;     buffer_size - 1 characters will be collected waiting for a command
;     terminator.  After that, the characters will be discarded, although
;     a command determinator will still cause the command bit to be set.
;
;-----------------------------------------------------------------------------
_UART_RX_ISR:

   ;@PSoC_UserCode_BODY_2@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom assembly code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.
   
   ; JWHONG: I dropped this into assembly because it's a very critical loop
   ; and needs to be tight.
   ;
   ; NOTE:  For some reason, pushing A and X to the stack and popping them after causes an intermittent bug...
   ; Don't ask me why.  I was just following the auto-generated recommendations above.
   ;push A
   ;push X
   mov  A,REG[UART_RX_BUFFER_REG]    ; Read the received data
   cmp  [_bytes_received], 0x00		 ; Were we waiting for the start of a packet?
   jz   packet_start
not_packet_start:
   cmp  [_target_address], 0x00      ; Load the target address
   jnz  forward_data				 ; If we are not the targeted device, forward the data
   cmp  [_m_to_s_offset], 0x80       ; Is the m_to_s flag set?
   jc   m_to_s_flag_not_set          ; Jump if the last packet we received was NOT a write address
   and  [_m_to_s_offset], 0x1F       ; Mask the index and clear the flag. Since our buffer is only 32 wide, cap max value
   mov  X, [_m_to_s_offset]          ; Load the offset
   mov  [X+_m_to_s_mem], A           ; Master is writing to the slave
   inc  X                            ; Send the requested address+1 back to the master
   jmp load_s_to_m_X
m_to_s_flag_not_set:
   cmp  A, 0x80                      ; Is this an address for a m_to_s write?
   jc   received_s_to_m_address
   mov  [_m_to_s_offset], A          ; Store the index the master wants to write to.  We will write the next received byte there.
   and  A, 0x7F                      ; Mask the address so we can give the master back some data
received_s_to_m_address:
   mov  X, A						 ; A is the index requested by the master
load_s_to_m_X:
   mov  A, [X+_s_to_m_mem]			 ; Load the requested address
   jmp  forward_data                 ; Fire it off
packet_start:
   mov  [_expected_bytes], A         ; Borrowing expected_bytes for storage
   and  A, 0x0F
   jnz  skip_lock_acquire            ; If we are the selected node, lock our external memory until we're done with this transaction
   mov  [_ext_mem_locked], 0x01      ; Lock the memory while we're reading from it
skip_lock_acquire:
   mov  [_target_address], A         ; Save the target address
   dec  A                            ; Decrement the address we will forward
   and  A, 0x0F
   and  [_expected_bytes], 0xF0      ; Mask the top 4 bits
   or   A, [_expected_bytes]
   mov  REG[UART_TX_BUFFER_REG], A   ; Forward the data
   mov  A, [_expected_bytes]         ; Reload expected bytes
   asr  A                            ; shift right 4 bits
   asr  A
   asr  A
   asr  A
   and  A, 0x0F						 ; Mask out top 4 bits
   mov  [_expected_bytes], A		 ; Save expected bytes
   jmp check_if_packet_done
forward_data:
   mov REG[UART_TX_BUFFER_REG], A
check_if_packet_done:
   mov  A, [_bytes_received]
   cmp  A, [_expected_bytes]
   jnz packet_continues
packet_end:
   mov  [_bytes_received], 0x00      ; Re-zero the received bytes
   mov  [_ext_mem_locked], 0x00      ; Release the lock
   jmp finish
packet_continues:
   inc [_bytes_received]
finish:
   ;pop X
   ;pop A
   reti
   
   ;---------------------------------------------------
   ; Insert your custom assembly code above this banner
   ;---------------------------------------------------
   
   ;---------------------------------------------------
   ; Insert a lcall to a C function below this banner
   ; and un-comment the lines between these banners
   ;---------------------------------------------------
   
   ;PRESERVE_CPU_CONTEXT
   ;lcall _My_C_Function
   ;lcall _rx_int_handler
   ;RESTORE_CPU_CONTEXT
   
   ;---------------------------------------------------
   ; Insert a lcall to a C function above this banner
   ; and un-comment the lines between these banners
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)

IF (UART_RXBUF_ENABLE)
   push A
   push X
   
   IF SYSTEM_LARGE_MEMORY_MODEL
      REG_PRESERVE IDX_PP
   ENDIF
   
   mov  X,[UART_bRxCnt]                                    ; Load X with byte counter
   mov  A,REG[UART_RX_CONTROL_REG]                         ; Read the control register
   push A                                                  ; Store copy for later test
                                                           ; IF real RX interrupt
   and  A,UART_RX_REG_FULL                                 ; Did really really get an IRQ
   jnz  .UARTRX_ReadRx                                     ; Data ready, go get it
   pop  A                                                  ; Restore stack
   jmp  .RESTORE_IDX_PP

.UARTRX_ReadRx:
   pop  A                                                  ; Restore status flags
                                                           ; IF there is no error, get data
                                                           ; Check for parity or framing error
   and  A,UART_RX_ERROR
   jz   .UARTRX_NO_ERROR                                   ; If there is not an Error go read data

   or   [UART_fStatus],A                                   ; Set error flags (parity,framing,overrun) bits
   tst  REG[UART_RX_BUFFER_REG], 0x00                      ; Read the data buffer to clear it.
   and  A,UART_RX_FRAMING_ERROR                            ; Check for framing error special case
   jz   .RESTORE_IDX_PP                                    ; Not framing error, all done

                                                           ; Disable and re-enable RX to reset after
                                                           ; framing error.
   and   REG[UART_RX_CONTROL_REG], ~UART_RX_ENABLE         ; Disable RX
   or    REG[UART_RX_CONTROL_REG],  UART_RX_ENABLE         ; Enable RX
   jmp  .RESTORE_IDX_PP                                    ; Done with framing error, leave.


.UARTRX_NO_ERROR:
   mov  A,REG[UART_RX_BUFFER_REG ]                         ; Read the data buffer

                                                           ; IF buffer not full
   tst  [UART_fStatus],UART_RX_BUF_CMDTERM                 ; Check for buffer full
   jnz  .RESTORE_IDX_PP                                    ; All done

   cmp  A,UART_CMD_TERM                                    ; Check for End of command
   jnz  .UARTRX_CHK_BACKSPACE
   or   [UART_fStatus],UART_RX_BUF_CMDTERM                 ; Set command ready bit



   RAM_SETPAGE_IDX >UART_aRxBuffer
   RAM_CHANGE_PAGE_MODE FLAG_PGMODE_10b
   mov  [X + UART_aRxBuffer],00h                           ; Zero out last data
   RAM_CHANGE_PAGE_MODE FLAG_PGMODE_00b
   jmp  .RESTORE_IDX_PP

.UARTRX_CHK_BACKSPACE:                                     ; 
IF(UART_BACKSPACE_ENABLE)                                  ; Enable if backspace/delete mode
   cmp  A,UART_BACKSPACE_ENABLE                            ; Check for backspace character
   jnz  .UARTRX_IGNORE                                     ; If not, skip the backspace stuff
   cmp  [UART_bRxCnt],00h                                  ; Check if buffer empty
   jz   .RESTORE_IDX_PP                                    ; 
   dec  [UART_bRxCnt]                                      ; Decrement buffer count by one.
   jmp  .RESTORE_IDX_PP
ENDIF                                                      ; 

.UARTRX_IGNORE:
IF(UART_RX_IGNORE_BELOW)                                   ; Ignore charaters below this value
   cmp  A,UART_RX_IGNORE_BELOW                             ; If ignore char is set to 0x00, do not
   jc   .RESTORE_IDX_PP                                    ; ignore any characters.
ENDIF

.UARTRX_CHK_OVFL:                                          ; Check for MAX String here
	
   RAM_SETPAGE_IDX >UART_aRxBuffer                         ;   using idexed address mode
   cmp  [UART_bRxCnt],(UART_RX_BUFFER_SIZE - 1)
   jc   .UARTRX_ISR_GETDATA
   RAM_CHANGE_PAGE_MODE FLAG_PGMODE_10b
   mov  [X + UART_aRxBuffer],00h                           ; Zero out last data in the buffer
   RAM_CHANGE_PAGE_MODE FLAG_PGMODE_00b
   or   [UART_fStatus],UART_RX_BUF_OVERRUN                 ; Set error flags (parity,framing,overrun) bits
   jmp  .RESTORE_IDX_PP

.UARTRX_ISR_GETDATA:                                       ; IF input data == "CR", then end of command
                                                           ; X is already loaded with pointer
   RAM_CHANGE_PAGE_MODE FLAG_PGMODE_10b
   mov  [X+UART_aRxBuffer],A                               ; store data in array
   RAM_CHANGE_PAGE_MODE FLAG_PGMODE_00b
   inc  X                                                  ; Inc the pointer
   mov  [UART_bRxCnt],X                                    ; Restore the pointer
                                                           ; ENDIF max string size
.RESTORE_IDX_PP:
   IF SYSTEM_LARGE_MEMORY_MODEL
      REG_RESTORE IDX_PP
   ENDIF

.END_UARTRX_ISR:
   pop  X
   pop  A

ENDIF

UART_RX_ISR_END:
   reti

; end of file UARTINT.asm
