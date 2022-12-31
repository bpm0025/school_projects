;	Basil Moledina
;	April 10th, 2022
;	Setup file containing subroutines to set up system interrupts


;	This file is intended to be adjustable as needed
;   If you import this file with get, no need to export any labels



	AREA INTER_SETUP, CODE
	



;	------------------------------------------------------------------------------------------------------------------------------
;	Setup Labels and Constants

		
SYSCONFIG EQU 0x40013800 			;	Start of SYSCONFIG memory block, 0x4001 3800 
CR1	EQU 0x08						;	Offset to Control register 1 (Lets you set interrupts for pins 0 - 3)
									;	From there, load int and adjust bits 0 - 3 (corresponding to EXTI0 and which pin 0 will interrupt)
							
							
							
							
EXTI EQU 0x40013C00					;	Start of EXTI memory block, 0x4001 3C00
IMR EQU 0x00						;	Offset of interrupt mask register (IMR, AKA "Enable") is 0
									;   Load int (possibly byte if there's an access violation) and change bit 0 to HIGH
							
							
							
							
FTSR EQU 0x0C						;	Offset to Falling Trigger Selection Register, 0x0C
									;	Load integer, Set bit 0 to HIGH
							
									
PR EQU 0x14							;   Pending bit register offset, update bit 0 to HIGH.									

									
									
							
NVIC EQU 0xE000E000					;	Start of NVIC memory block, 0xE000E100
ISER0 EQU 0x100						;	Offset to interrupt set-enable register 0
									;	To set EXTI0, load integer and write bit 6 to HIGH (FROM NVIC Table in RM, CH. 10)
									
									

NVIC_ICPR0 EQU 0XE000E280			;	Interrupt clear register 0
									;	load int, write bit 6 to HIGH



							
;	--------------------------------------------------------------------------------------------------------------------------------
							
							
							
							
							
					
							





; --------------------------------------------------------------------------------------------------------------
;	EXTI_SETUP - Sets up interrupt line 0 to be activated by push button
;
;	Inputs - None
;	Outputs - Modifies various EXTI-related registers (see labels and constants)
;
;	Note: Does not save registers (advised to run at start of main program)
; -------------------------------------------------------------------------------------------------------------

EXTI_SETUP ldr r0, =SYSCONFIG				; r0 points to SYSCONFIG
	ldr r1, [r0, #CR1]						; r1 = SYSCONFIG_CR1
	AND r1, #0xFFFFFFF0						; Mask to get 0x#######0 (EXIT0 uses port A)
	str r1, [r0, #CR1]						; Write new Port-to-Interrupt configuration back
	
	
	
	ldr r0, =EXTI							; r0 -> points to EXTI memory block
	ldr r1, [r0, #IMR]						; r1 = EXTI_IMR
	ORR r1, #0x00000001						; Mask to get 0x#######1
	str r1, [r0, #IMR]						; write pattern back to interrupt (enable) mask register
	
	
	
	ldr r1, [r0, #FTSR]						; r1 = EXTI_RTSR
	ORR r1, #0x00000001						; Set bit 0 of RTSR to HIGH
	str r1, [r0, #FTSR]						; Write new Rising Trigger code back to RTS register
	
	
	
	ldr r0, =NVIC							; r0 -> points to NVIC memory block
	ldr r1, [r0, #ISER0]					; r1 = NVIC_ISER0
	ORR r1, #0x00000040						; Set bit 6 to HIGH
	str r1, [r0, #ISER0]					; Write new pattern back to interrupt set-enable register



	bx lr;

















	END							;		End of EXTI0_SETUP file
							
						