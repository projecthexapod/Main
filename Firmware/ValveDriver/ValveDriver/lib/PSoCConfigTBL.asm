;  Generated by PSoC Designer 5.1.2306
;
include "m8c.inc"
;  Personalization tables 
export LoadConfigTBL_ValveDriver
AREA psoc_config(rom, rel)
LoadConfigTBL_ValveDriver:
	M8C_SetBank0
;  Global Register values Bank 0
	mov	reg[60h], 00h		; AnalogColumnInputSelect register (AMX_IN)
	mov	reg[66h], 00h		; AnalogComparatorControl1 register (CMP_CR1)
	mov	reg[63h], 17h		; AnalogReferenceControl register (ARF_CR)
	mov	reg[65h], 00h		; AnalogSyncControl register (ASY_CR)
	mov	reg[e6h], 00h		; DecimatorControl_0 register (DEC_CR0)
	mov	reg[e7h], 00h		; DecimatorControl_1 register (DEC_CR1)
	mov	reg[d6h], 00h		; I2CConfig register (I2CCFG)
	mov	reg[b0h], 00h		; Row_0_InputMux register (RDI0RI)
	mov	reg[b1h], 00h		; Row_0_InputSync register (RDI0SYN)
	mov	reg[b2h], 00h		; Row_0_LogicInputAMux register (RDI0IS)
	mov	reg[b3h], 33h		; Row_0_LogicSelect_0 register (RDI0LT0)
	mov	reg[b4h], 33h		; Row_0_LogicSelect_1 register (RDI0LT1)
	mov	reg[b5h], 29h		; Row_0_OutputDrive_0 register (RDI0SRO0)
	mov	reg[b6h], 20h		; Row_0_OutputDrive_1 register (RDI0SRO1)
;  Instance name PWM8_1, User Module PWM8
;       Instance name PWM8_1, Block Name PWM8(DBB00)
	mov	reg[23h], 00h		;PWM8_1_CONTROL_REG(DBB00CR0)
	mov	reg[21h], ffh		;PWM8_1_PERIOD_REG(DBB00DR1)
	mov	reg[22h], 00h		;PWM8_1_COMPARE_REG(DBB00DR2)
;  Instance name PWM8_2, User Module PWM8
;       Instance name PWM8_2, Block Name PWM8(DBB01)
	mov	reg[27h], 00h		;PWM8_2_CONTROL_REG(DBB01CR0)
	mov	reg[25h], ffh		;PWM8_2_PERIOD_REG(DBB01DR1)
	mov	reg[26h], 00h		;PWM8_2_COMPARE_REG(DBB01DR2)
;  Instance name UART, User Module UART
;       Instance name UART, Block Name RX(DCB03)
	mov	reg[2fh], 00h		;UART_RX_CONTROL_REG(DCB03CR0)
	mov	reg[2dh], 00h		;UART_(DCB03DR1)
	mov	reg[2eh], 00h		;UART_RX_BUFFER_REG (DCB03DR2)
;       Instance name UART, Block Name TX(DCB02)
	mov	reg[2bh], 00h		;UART_TX_CONTROL_REG(DCB02CR0)
	mov	reg[29h], 00h		;UART_TX_BUFFER_REG (DCB02DR1)
	mov	reg[2ah], 00h		;UART_(DCB02DR2)
	M8C_SetBank1
;  Global Register values Bank 1
	mov	reg[61h], 00h		; AnalogClockSelect1 register (CLK_CR1)
	mov	reg[69h], 00h		; AnalogClockSelect2 register (CLK_CR2)
	mov	reg[60h], 04h		; AnalogColumnClockSelect register (CLK_CR0)
	mov	reg[62h], 00h		; AnalogIOControl_0 register (ABF_CR0)
	mov	reg[67h], 33h		; AnalogLUTControl0 register (ALT_CR0)
	mov	reg[68h], 00h		; AnalogLUTControl1 register (ALT_CR1)
	mov	reg[63h], 00h		; AnalogModulatorControl_0 register (AMD_CR0)
	mov	reg[66h], 00h		; AnalogModulatorControl_1 register (AMD_CR1)
	mov	reg[d1h], 00h		; GlobalDigitalInterconnect_Drive_Even_Input register (GDI_E_IN)
	mov	reg[d3h], 00h		; GlobalDigitalInterconnect_Drive_Even_Output register (GDI_E_OU)
	mov	reg[d0h], 00h		; GlobalDigitalInterconnect_Drive_Odd_Input register (GDI_O_IN)
	mov	reg[d2h], 00h		; GlobalDigitalInterconnect_Drive_Odd_Output register (GDI_O_OU)
	mov	reg[e1h], 2fh		; OscillatorControl_1 register (OSC_CR1)
	mov	reg[e2h], 00h		; OscillatorControl_2 register (OSC_CR2)
	mov	reg[dfh], bbh		; OscillatorControl_3 register (OSC_CR3)
	mov	reg[deh], 01h		; OscillatorControl_4 register (OSC_CR4)
	mov	reg[ddh], 00h		; OscillatorGlobalBusEnableControl register (OSC_GO_EN)
;  Instance name PWM8_1, User Module PWM8
;       Instance name PWM8_1, Block Name PWM8(DBB00)
	mov	reg[20h], 21h		;PWM8_1_FUNC_REG(DBB00FN)
	mov	reg[21h], 14h		;PWM8_1_INPUT_REG(DBB00IN)
	mov	reg[22h], 07h		;PWM8_1_OUTPUT_REG(DBB00OU)
;  Instance name PWM8_2, User Module PWM8
;       Instance name PWM8_2, Block Name PWM8(DBB01)
	mov	reg[24h], 21h		;PWM8_2_FUNC_REG(DBB01FN)
	mov	reg[25h], 14h		;PWM8_2_INPUT_REG(DBB01IN)
	mov	reg[26h], 05h		;PWM8_2_OUTPUT_REG(DBB01OU)
;  Instance name UART, User Module UART
;       Instance name UART, Block Name RX(DCB03)
	mov	reg[2ch], 05h		;UART_RX_FUNC_REG   (DCB03FN)
	mov	reg[2dh], e5h		;UART_RX_INPUT_REG  (DCB03IN)
	mov	reg[2eh], 40h		;UART_RX_OUTPUT_REG (DCB03OU)
;       Instance name UART, Block Name TX(DCB02)
	mov	reg[28h], 0dh		;UART_TX_FUNC_REG   (DCB02FN)
	mov	reg[29h], 05h		;UART_TX_INPUT_REG  (DCB02IN)
	mov	reg[2ah], 44h		;UART_TX_OUTPUT_REG (DCB02OU)
	M8C_SetBank0
;  Ordered Global Register values
	M8C_SetBank0
	mov	reg[00h], 00h		; Port_0_Data register (PRT0DR)
	M8C_SetBank1
	mov	reg[00h], abh		; Port_0_DriveMode_0 register (PRT0DM0)
	mov	reg[01h], 54h		; Port_0_DriveMode_1 register (PRT0DM1)
	M8C_SetBank0
	mov	reg[03h], 50h		; Port_0_DriveMode_2 register (PRT0DM2)
	mov	reg[02h], a5h		; Port_0_GlobalSelect register (PRT0GS)
	M8C_SetBank1
	mov	reg[02h], 00h		; Port_0_IntCtrl_0 register (PRT0IC0)
	mov	reg[03h], 00h		; Port_0_IntCtrl_1 register (PRT0IC1)
	M8C_SetBank0
	mov	reg[01h], 00h		; Port_0_IntEn register (PRT0IE)
	mov	reg[04h], 00h		; Port_1_Data register (PRT1DR)
	M8C_SetBank1
	mov	reg[04h], 10h		; Port_1_DriveMode_0 register (PRT1DM0)
	mov	reg[05h], efh		; Port_1_DriveMode_1 register (PRT1DM1)
	M8C_SetBank0
	mov	reg[07h], efh		; Port_1_DriveMode_2 register (PRT1DM2)
	mov	reg[06h], 10h		; Port_1_GlobalSelect register (PRT1GS)
	M8C_SetBank1
	mov	reg[06h], 00h		; Port_1_IntCtrl_0 register (PRT1IC0)
	mov	reg[07h], 00h		; Port_1_IntCtrl_1 register (PRT1IC1)
	M8C_SetBank0
	mov	reg[05h], 00h		; Port_1_IntEn register (PRT1IE)
	mov	reg[08h], 00h		; Port_2_Data register (PRT2DR)
	M8C_SetBank1
	mov	reg[08h], 80h		; Port_2_DriveMode_0 register (PRT2DM0)
	mov	reg[09h], 7fh		; Port_2_DriveMode_1 register (PRT2DM1)
	M8C_SetBank0
	mov	reg[0bh], 7fh		; Port_2_DriveMode_2 register (PRT2DM2)
	mov	reg[0ah], 80h		; Port_2_GlobalSelect register (PRT2GS)
	M8C_SetBank1
	mov	reg[0ah], 00h		; Port_2_IntCtrl_0 register (PRT2IC0)
	mov	reg[0bh], 00h		; Port_2_IntCtrl_1 register (PRT2IC1)
	M8C_SetBank0
	mov	reg[09h], 00h		; Port_2_IntEn register (PRT2IE)
	M8C_SetBank0
	ret


; PSoC Configuration file trailer PsocConfig.asm
