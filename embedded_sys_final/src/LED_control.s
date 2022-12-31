;	Basil Moledina
;	LED Control File
;   March 31st, 2022

;	A File that contains subroutines and address labels for setting/Controlling LEDS on the STM32F411VETx board
;	onboard LEDs are at port D

;	The pins for the LEDs are on port D
;	Pins corresponding to LEDs are 12-15

	
	
	
	
	
	
	
	









	AREA LED_CONTROL, CODE

	
	
	
	
	
	


;----------------------------------------------------------------------------------------------------------------------------------------
; Constants and address label list


;	______Clock Setting Addresses________________:

RCC EQU 0x40023800;		Starting address of Reset & Clock Control Registers
RCC_AHB1ENR EQU 0x30;		OFFSET from RCC, gives you the 32-bit register which enables port D's clock	
;							From here, you can just read the clock register, modify bit 3 (set it to 1), and overwrite back to register




;	_______Pin Mode Register Adresses____________:


GPIOD EQU 0x40020C00;		Starting address for all registers pertaining to Port D
		
;		No offset needed to access Port D mode register (offset = 0x00), just LDR GPIOD. 
;			See subroutine for more info.



;	______Addresses for Writing to pins __________:

; Still uses GPIOD address to access Port D's pins
ODR_D EQU 0x14;			OFFSET to access the output data register of port D. See subroutine for more info.
	
	
	
	


;----------------------------------------------------Label List End-------------------------------------------------------------------------














;---------------------------------------------------------------------------------------------------------
; SET_LCLK  -  (Set LED clock) Activate the clock on PORT D, allowing the on-board LEDs to be modified.
;
;	Input:	None
;
;	Output: Updates the RCC register to actiavte GPIO port D
;
;	Note:	Does not save registers 
;
;---------------------------------------------------------------------------------------------------------




SET_LCLK ldr r0, =RCC;  						; Load start address of the RCC "partition"
		ldr r1, [r0, #RCC_AHB1ENR];				; Read clock register data that controls port d into r1.
		ORR r1, #0x08;							; Use Mask 0x08 ( binary 1000) to set bit 3 (enable bit) to 1.
		str r1, [r0, #RCC_AHB1ENR];				; Write new data to the clock register
		bx lr; 									; Return to main program



;----------------------------------------------------------------------------------------------------------
















;----------------------------------------------------------------------------------------------------------------
; LED_WMODE - (LED Write Mode) - Sets the mode of the LED pins to "write," (instead of reading data on the pins)
;
;	Input:	None
;
;	Output: Updates Mode Register on port D
;
;	Notes: Does not save registers
;
;----------------------------------------------------------------------------------------------------------------



LED_WMODE	ldr r0, =GPIOD 							;	Load starting address of Port D data area
			ldr r1, [r0] 							; 	Read Port D's mode register data (no offset needed)
			bic r1, #0xFF000000						;	Clear bits (please note that each pin mode is 2 bits wide)
			orr r1, #0x55000000						;	Set bits with the following 32 bit mask ( Binary 0101 0101 ... LSB ) 
			str r1, [r0] 							;	Write new mode data to Port D's mode register
			bx lr									;	Branch back to main program




;---------------------------------------- END -------------------------------------------------------------------

















;--------------------------------------------------------------------------------------------------------------
;  L_WRITE - (LED Write)  Writes an LED pattern to all 4 LEDs, turning them on or off as specified.
;
;		Input:	
;				STACK (Push in this order):
;				1) 4-bit code to be written to LEDs (pin 15 -> pin 12) 							
;				
;
;		Output:
;				Updates the output data register of port D
;				LED lights light up or are turned off on the board.
;
;
;		Notes:	For the code, 1 = ON and 0 = OFF. Does not save registers
;
;--------------------------------------------------------------------------------------------------------------


L_WRITE POP {r0}						; r0 = 4-bit LED code
	LSL r0, #12							; Shift the 4-bit code 12 bits to the left.
	ldr r1, =GPIOD						; Load start of port D's data area into r1
	ldrh r2, [r1, #ODR_D]				; Read (half-word) Port D's data register
	bic r2, #0xF000						; Clear last four pins (15 - 12)
	orr r2, r0							; Use the shifted parameter as a mask to set bits
	str r2, [r1, #ODR_D]				; Write the new output data to the ODR
	bx lr;								; Return to main program or whatever



;------------------------------------- END -----------------------------------------------------------------













;----------------------------------------------------------------------------------------------------------
;	For Activating and Reading Buttons																	   |
;																										   |
;----------------------------------------------------------------------------------------------------------


GPIOA EQU 0x40020000	; Starting Address of GPIO A data area
IDR_A EQU 0x10			; OFFSET to access the input data register of PORT A.


;---------------------------------------------------------------------------------------------------------
; SET_BCLK  -  (Set button clock) Activate the clock on PORT A, allowing on-board button to be read.
;
;	Input:	None
;
;	Output: Updates the RCC register to actiavte GPIO port A
;
;	Note:	Does not save registers 
;
;---------------------------------------------------------------------------------------------------------




SET_BCLK ldr r0, =RCC;  						; Load start address of the RCC "partition"
		ldr r1, [r0, #RCC_AHB1ENR];				; Read clock register data that controls port A into r1.
		ORR r1, #0x01;							; Use Mask 0x01 ( binary 0001) to set bit 0 (enable bit) to 1.
		str r1, [r0, #RCC_AHB1ENR];				; Write new data to the clock register
		bx lr; 									; Return to main program



;----------------------------------------------------------------------------------------------------------











;----------------------------------------------------------------------------------------------------------------
; BTN_RMODE - (Button Read Mode) - Sets the mode of the button pin to "read" (instead of writing data on the pin)
;
;	Input:	None
;
;	Output: Updates Mode Register on port A
;
;	Notes: Does not save registers
;
;----------------------------------------------------------------------------------------------------------------



BTN_RMODE	ldr r0, =GPIOA 							;	Load starting address of Port A data area
			ldr r1, [r0] 							; 	Read Port A's mode register data (no offset needed)
			bic r1, #0x03							;	Clear first 2 bits (please note that each pin mode is 2 bits wide) 
			str r1, [r0] 							;	Write new mode data to Port A's mode register (pin mode 00 = Read)
			bx lr									;	Branch back to main program




;---------------------------------------- END -------------------------------------------------------------------










;--------------------------------------------------------------------------------------------------------------
;  B_READ - ()	Reads data from the button pin.
;
;		Input:	
;					INPUT data register from Port A							
;					Onboard pin 0 associated with GPIO A
;
;		Output:
;					STACK (pop in this order)			
;					1) on (pressed) or off (not being pressed) status of button
;
;
;		Notes:	For the code, 1 = ON and 0 = OFF. Does not save registers
;
;--------------------------------------------------------------------------------------------------------------


B_READ
	ldr r1, =GPIOA						; Load start of port A's data area into r1
	ldrh r2, [r1, #IDR_A]				; Read (half-word) Port A's  INPUT DATA REGISTER
	AND r2, 0x0001						; Use bit-clearing mask (binary 0000 0000 0000 0001) since we only care about bit 0
	PUSH {r2}							; Push R2 onto stack to return the button status

	bx lr;								; Return to main program or whatever



;------------------------------------- END -----------------------------------------------------------------























	END; End of assembly program.
