; Basil Moledina
; TIMER INITIALIZATION FILE (FINAL PROJECT)
; April 24th, 2022



; A file that includes all subroutines, addresses, and offsets to set up the timer for the final project
; Note: 5 ms is a multiple of every period's time between samples

;	Timer Period calculation
;
; Tout = (ARR + 1) x (PSC + 1) x (Tclk)
;
; Tout = (799 + 1) x (99 + 1) x (1 / 16 MHz)
; 5 ms = 


; Process:
;
;	Turn on clock in RCC
;	Set UIE bit (bit 0) in TIMx_DIER		- ENABLE 1
;	Set enable bit in NVIC (NVIC_ISERx)		- ENABLE 2
;	SET CPU enable, CSSIE (done in main program)

;	Set counter, prescaler, and autoreload 

;	Set counter enable (TIMx_CR1)









	AREA TIMER_INIT, CODE














;	--------------------------------------------------------------------------------------------------
;	Addresses, Constants, and Offsets
;

RCC_APB1ENR EQU 0x40023840		;	RCC Advanced Peripheral Bus 1 Enable register
								;	Change bit 2 (TIM4 enable)
								
								
								
TIM4_DIER EQU 0x4000080C		;	Timer 4 Interrupt enable register
								;	Update bit 0
								
								
NVIC_ISER0 EQU 0xE000E100		;   Interrupt set-enable register
								;	Set bit 30
								
								
TIM4_PSC EQU 0x40000828			;	Timer 4 prescaler register
								;	16 bits
								
								
TIM4_CNT EQU 0x40000824			;	Timer 4 current count (load 16 bits)
	
	
TIM4_ARR EQU 0x4000082C			;	Timer 4 Auto-reload value (16 bits)
	
	
TIM4_CR1 EQU 0x40000800			;   TIMER 4 control register 1
								; 	Set bit 0 to HIGH
								
								
								
TIM4_SR EQU 0x40000810			;	TIMER 4 STATUS REGISTER
								;	clear bit 0 when interrupt is handled
								


;		---- Constants ---

PRESCALAR EQU 0x63					; Prescaler Value (99 in decimal)
AUTORELOAD EQU 0x31F				; Auto-Reload Value (799 in decimal) 




; ------------------------------------------------------------------------------------------------------













; ------------------------------------------------------------------------------------------------------
; SETUP_TIM4  -  Subroutine to set up timer 4 to trigger system interrupts
;
;	Inputs:	 NONE (to update the prescale and auto-reload, adjust them above)
;
;	Outputs:
;			 No Return value
;			 Modifies some registers + clock functions (see addresses + labels)
;
; -------------------------------------------------------------------------------------------------------


SETUP_TIM4 ldr r0, =PRESCALAR				; r0 = Prescalar 
	ldr r1, =AUTORELOAD						; r1 = Autoreload
	
	
	
	ldr r2, =RCC_APB1ENR					; r2 -> points to Reset and Clock Control Register 
											; (Adv. Periph Bus 1 Enable)
											
	ldr r3, [r2]							; r3 = RCC_APB1ENR
	ORR r3, #0x04							; Set bit 2 to HIGH
	str r3, [r2]							; Write new device enable code back to register



	mov r4, lr								; Save link register
	bl CLR_TIM4_UIF							; Clear the interrupt pending bit (starts HIGH for some reason)
	mov lr, r4								; Restore link register back
	
	
	

	ldr r2, =TIM4_DIER						; r2 -> Timer 4 interrupt enable register
	ldr r3, [r2]							; r3 = TIM4_DIER
	ORR r3, #0x01							; Set bit 0 to HIGH
	str r3, [r2] 							; Write new data back to DIER
	
	
	
	
	ldr r2, =NVIC_ISER0						; r2 -> points to NVIC enable register 0
	ldr r3, [r2]							; r3 = Data in NVIC ISER0
	ORR r3, #0x40000000						; Set bit 30 to HIGH
	str r3, [r2]							; WRITE NVIC interrupt enable code back
	
	
	
	ldr r2, =TIM4_PSC						; r2 -> Timer 4 Prescalar
	strh r0, [r2]							; Store r0 to Timer 4 Prescalar register
	
	
	
	ldr r2, =TIM4_ARR						; r2 -> Timer 4 Auto-Reload Value register
	strh r1, [r2]							; Store r1 to Auto-Reload Register
	
	
	

	ldr r2, =TIM4_CNT						; r2 -> Timer 4 current count register
	mov r3, #0x00							; r3 = 0
	strh r3, [r2]							; Store r3 to the current count register (reset to 0)
	
	
	
	
	
	
	ldr r2, =TIM4_CR1						; r2 -> Timer 4 control register
	ldr r3, [r2]							; r3 = Timer 4 CR1 data
	ORR r3, #0x01							; Set bit 0 to HIGH
	str r3, [r2]							; WRITE this data back to CR1 (start the count)



; ---------------------------------------END OF SETUP---------------------------------------------------








;-----------------------------------------------------------------------------------------------------
; CLR_TIM4_UIF - Clears the timer 4 interrupt bit (SR, UIF)
;
;	Input - none
;	Output - none
;
;-------------------------------------------------------------------------------------------------------

CLR_TIM4_UIF 	ldr r2, =TIM4_SR			; r2 -> TImer 4 status register
	ldrb r3, [r2]							; r3 = SR data
	AND r3, #0xFE							; Clear bit 0 to LOW
	strb r3, [r2]							; Write SR data back

	bx lr;
	
; ---------------------------------------------------------------------------------------------------------













	

	END										; END of timer setup file