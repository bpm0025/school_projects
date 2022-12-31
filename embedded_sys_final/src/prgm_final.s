;	Basil Moledina
;	ELEC 2220, Final Project
;   April 29th, 2022


;	A program that turns the STM32F11 into a function generator, capable of different periods and waveforms.







;	Program (main function) Setup, starts at 0x08000000 _______________________________________________________________________




;	GET TIMER_INITIALIZATION.s
	
	EXPORT __main
	EXPORT TIM4_IRQHandler
	EXPORT EXTI0_IRQHandler
		
	GET TIMER_INITIALIZATION.s
	GET EXTI_SETUP.s
	GET LED_control.s

	AREA PROGRAM25, CODE
	THUMB
	ENTRY
	
	





;	Driver Function here _________________________________________________________________________

__main
	
	
	
;------------ GLOBAL VAR INITIALIZATION -----------------
	
	ldr r0, =TIM4_cnt		;   timer-interrupt count starts at 0 
	mov r1, #0x00			;
	str r1, [r0];			;


	ldr r0, =btn_cnt		;	button-press count starts at 0
	mov r1, #0				;
	str r1, [r0]			;




	ldr r0, =DACvalue		;	waveform starts at 0 
	mov r1, #0x00			;
	str r1, [r0]			;



	ldr r0, =saw_slope		;	Saw Tooth Slope = 00
	mov r1, #0x00			;	
	str r1, [r0]			;


	ldr r0, =plot_delay		;   # of timed delays between samples = 0
	mov r1, #0x00			;
	str r1, [r0]			;


	ldr r0, =current_wave	;   current wave = sawtooth, 0
	mov r1, #0x00			;
	str r1, [r0]			;



	ldr r0, =btn_tmr		;   button timer = 0
	mov r1, #0x00			;
	str r1, [r0]			;
	
	
	ldr r0, =chng_wav		;   change wave = 0
	mov r1, #0x00			;
	str r1, [r0]			;
	
	
	ldr r0, =tri_slope		;   triangle slope = 0
	mov r1, #0x00			;
	str r1, [r0]			;
	
	
	ldr r0, =LED_pattern	;   LED_pattern = 0000
	mov r1, #0				;
	str r1, [r0]			;
	
	

;--------------------------------------------------

	bl EXTI_SETUP		;
	bl SET_LCLK			;
	bl LED_WMODE		;
	bl SETUP_TIM4 		;




	

	
; -----------------------MAIN CONTROL LOOP---------------------------	
	
main_loop 

main_sawtooth	bl gen_saw;



main_triangle	bl gen_tri;
	


	b main_loop 
	
	
; -------------------------------------------------------------------

here b here;	End of main program
















;	Supporting subroutines _______________________________________________________________________







;----------------------------------------------------------------------
; gen_saw- generate sawtooth - A subroutine that generates a sawtooth waveform
;	
;			inputs: none (as far as parameters go)
;			outputs: updates global var waveform
;
;----------------------------------------------------------------------


gen_saw	ldr r0, =TIM4_cnt			; r0 -> address of TIM4_cnt
	ldr r1, [r0]					; r1 = TIM4_cnt, an interrupt counter

	ldr r0, =plot_delay				; r0 -> address of plot_delay
	ldr r2, [r0]					; r2 = plot_delay, interrupts between two samples



; -----IF Statement------------------
	cmp r1, r2						;
	blo saw_IF2						;
;------------------------------------
	
;	If (#_interrupts_occurred >= #_interrupts_between_plots) 


	ldr r0, =DACvalue				; r0 -> address of DACvalue
	ldr r1, [r0]					; r1 = DACvalue, current value of the digital waveform
	
	ldr r0, =saw_slope					; r0 -> address of slope
	ldr r2, [r0]					; 	r2 = slope, the change in the waveform
	
	add r1, r2						; Increase waveform by slope (DAC + m)
	
	ldr r0, =DACvalue				; r0 -> address of DACvalue
	str r1, [r0]					; Write new DACvalue to memory
	
	ldr r0, =TIM4_cnt				; r0 -> TIM4_cnt addrs.
	mov r1, #0						; r1 = 0
	str r1, [r0]					; Reset TIM4_cnt ( = 0)







	

; -----IF Statement------------------
saw_IF2	ldr r0, =DACvalue			; 	r0 -> DACvalue Addrs.
	ldr r1, [r0]					; 	r1 = DACvalue
									;
	mov r0, #0xFFF					; 	r0 = 0xFFF, 4095 (decimal)
									;
									;
	cmp r1, r0					    ;
	blo	saw_IF3					    ;
;------------------------------------

;	if (current waveform >= MAX_VALUE)


	ldr r0, =DACvalue				; r0 -> DACvalue addr.
	mov r1, #0x00					; r1 = 0
	str r1, [r0]					; write DACvalue = 0 to memory
	
	
	ldr r0, =LED_pattern		; Toggle blue LED
	ldr r1, [r0]				; r1 = LED_pattern
	EOR r1, #0x08				;
	str r1, [r0]				; write back to LED_pattern
	
	push {r1}					; pass LED_pattern as a parameter
	ldr r0, =lr_copy			; Store copy of link register
	str lr, [r0]				;
	bl L_WRITE					; subroutine to update LEDs onboard
	ldr r0, =lr_copy			;
	ldr lr, [r0]				; Restore link register




; if (chng_wav == 1)

 ;-----IF STATEMENT---------------
saw_IF3	ldr r0, =chng_wav	     ;	r0 -> chng_wav addrs		
	ldr r1, [r0] 				 ;	r1 = chng_wav	
	mov r0, #0x01				 ;	r0 = #1		
	cmp r1, r0					 ;	if (chng_wav == 1)	
	bleq wave_setup				 ;	branch to wave_setup function	
 ;--------------------------------


			
;	Otherwise

	b gen_saw						; Go back to top, generate another waveform



;---------------------------------------END------------------------------------------------------



















;----------------------------------------------------------------------------------------------
;	TIM4_IRQHandler - Timer 4 interrupt Handler
;
;		Purpose: responsible for timing data plots and button-presses in an interval
;	
;
;		Inputs:	 None 
;
;		Outputs: 
;					Modifies TIM4_cnt
;					Modifies btn_timer (elapsed time between button presses)
;					Modifies change_wave boolean
;
;
;		Notes: Tested with break points in debug mode, works
;-----------------------------------------------------------------------------------------------

TIM4_IRQHandler	mov r4, lr			; Reset Timer interrupt-pending bit
	bl CLR_TIM4_UIF;				; 
	mov lr, r4;						; 
	
	
	ldr r0, =TIM4_cnt				; r0 -> address of tmr_cnt
	ldr r1, [r0]					; r1 = tmr_cnt
	add r1, #1						; tmr_cnt++
	str r1, [r0]					; write new tmr_cnt back to memory
	
	
	
;	 if (btn_cnt > 0), add to btn_timer
		
;--------------IF/ELSE statement--------------------------------	
	ldr r0, =btn_cnt				; r0 -> btn_cnt addrs
	ldr r1, [r0]					; r1 = btn_cnt
	cmp r1, #0						; if (btn_cnt == 0)
	beq TIM4_IF2 					; skip to next IF statement
;--------------------------------------------------------------

;			btn_tmr++
	
	ldr r0, =btn_tmr				; r0 -> btn_tmr adrs
	ldr r1, [r0]					; r1 = btn_tmr
	add r1, #1						; btn_tmr++
	str r1, [r0]					; write new btn_tmr count back to memory








;	 if (btn_tmr == 2 seconds, ) set chng_wav == 1, reset btn_tmr (reset btn_cnt later)

;		in other words:
;
;	if 400 0.005-second-interrupts occur 

;-------------IF/ELSE statement-------------------------------
TIM4_IF2 ldr r0, =btn_tmr			; r0, -> btn_tmr address
	ldr r1, [r0]					; r1 = btn_tmr
	cmp r1, #0x190					; compare btn_tmr to 400 (in decimal)
	bxlo lr							; Skip below section if btn_tmr < 400 interrupts
	
;-------------------------------------------------------------	
	
;	Set change_wave staus to "yes"


	ldr r0, =chng_wav				; r0 -> chng_wav addrs
	mov r1, #1						; r1 = #1
	str r1, [r0]					; write #1 to chng_wav
	

;	Reset button_timer
	
	ldr r0, =btn_tmr				; r0 -> btn_tmr addrs
	mov r1, #0						; r1 = 0
	str r1, [r0]					; write #0 to btn_tmr (reset it)
	
	

	bx lr							;


; ---------------------------------------END OF INTERRUPT HANDLER--------------------------------

























; -------------------------------------------------------------------------------
; wave_setup - Modifies / sets up slope and time between analog waveform plots
;
;	input: 
;			reads several global variables
;			
;			
;	output:
;			modifies several global variables
;			
;
; -------------------------------------------------------------------------------

wave_setup add r0, #0 						; Delete me
	
	
	
	
	
	; reset chng_wav status to "NO"/0
	
	ldr r0, =chng_wav			; r0 -> chng_wav
	mov r1, #0					; r1 = 0
	str r1, [r0]				; write #0 to chng_wav

	
	
	
	
	; reset btn_cnt to 0 (r2 contains a copy of btn_cnt)
	
	ldr r0, =btn_cnt			; r0 -> btn_cnt addrs
	ldr r2, [r0]				; r2 = btn_cnt
	mov r1, #0					; r1 = 0
	str r1, [r0]				; write btn_cnt = 0 to memory
	
	
	
; if (btn_cnt >= 2) branch to new waveform (in main)
	
	cmp r2, #2					; compare btn_cnt to #2 
	blo update_graphing 		; skip section if btn_cnt < 2
	
	
	
	
		; if( current_wave == sawtooth [0])
		
	ldr r0, =current_wave		; r0 -> current_wave address
	ldr r1, [r0]				; r1 = current wave
	
	cmp r1, #0					; compare current wave to #0
	bne WAVS_ELSE1				; branch if current wave =/= 0
	
	mov r1, #1					; r1 = 1
	str r1, [r0]				; write #1 to current_wave
	b main_triangle				; branch to generating triangle
	
	
	
		; else if (current_wave == triangle [1])

WAVS_ELSE1
	
	mov r1, #0					; r1 = 0
	str r1, [r0]				; write 0 to current_wave
	b main_sawtooth				; branch to generating sawtooth
	   
	

	
	
	
	
	
	
; otherwise, update sawtooth and triangle's plot_delay and slopes.
;	NOTE: There is only 1 plot delay variable


update_graphing

;-------------------------------------------------------------------
	; if plot_delay is max (7), reset to 0. Also reset DACvalue to 0
	;	otherwise, skip the section below and increase delay. Slopes = 0
	
	ldr r0, =plot_delay			; r0 -> plot_delay addrs
	ldr r1, [r0]				; r1 = plot_delay
	cmp r1, #7					; if (plot_delay < 7)
	blo WAVS_ELSE2				; skip the below section
;------------------------------------------------------------------




	mov r1, #0					; r1 = 0
	str r1, [r0]				; Write to plot_delay addrs
	
	
	ldr r0, =DACvalue			; r0 -> DACvalue addrs
	mov r1, #0					; r1 = 0
	str r1, [r0]				; write 0 to DACvalue
	
	
	ldr r0, =LED_pattern	;  LED_pattern = 0
	mov r1, #0				;
	str r1, [r0]			;
	
	push {r1}				;
	ldr r0, =lr_copy			;
	str lr, [r0]				;
	bl L_WRITE					;
	ldr r0, =lr_copy			;
	ldr lr, [r0]				;
	
	ldr r0, =saw_slope		;	Saw Tooth Slope = 0 (decimal)
	mov r1, #0x00			;	
	str r1, [r0]			;
	
	
	ldr r0, =tri_slope		;	triangle Slope = 0 (decimal)
	mov r1, #0x00			;	
	str r1, [r0]			;


	
	
	bx	lr						; return back to wave (which is now off)
	
	
	
	; Otherwise
	; 	Increase plot delay by 1, reactivate slopes, adjust LED pattern
	
WAVS_ELSE2 
	
	ldr r0, =DACvalue			; r0 -> DACvalue addrs
	mov r1, #0					; r1 = 0
	str r1, [r0]				; write 0 to DACvalue
	
	
	
	ldr r0, =LED_pattern		; r0 -> LED_pattern addrs
	ldr r1, [r0]				; r1 = LED_pattern
	add r1, #1					; LED_pattern++
	str r1, [r0]				; write new plot_delay back
	
	
	push {r1}					;
	ldr r0, =lr_copy			;
	str lr, [r0]				;
	bl L_WRITE					;
	ldr r0, =lr_copy			;
	ldr lr, [r0]				;
	
	
	ldr r0, =plot_delay			; r0 -> plot_delay addrs
	ldr r1, [r0]				; r1 = plot_delay
	add r1, #1					; plot_delay++
	str r1, [r0]				; write new plot_delay back
	
	
	ldr r0, =saw_slope		;	Saw Tooth Slope = 0x29
	mov r1, #0x29			;	
	str r1, [r0]			;
	
	ldr r0, =tri_slope		;	triangle Slope = 0x52
	mov r1, #0x51			;	
	str r1, [r0]			;
	
	
	; Then branch back to current waveform
	bx lr;
	
	
;------------------------------------------END---------------------------------------








































; ---------------------------------------------------------------------------------------------------------------
;	EXTI0_IRQHandler - Interrupt handler for interrupt line 0
;
;	inputs - Any inputs required for pressing a button
;	outputs - none
;
; ----------------------------------------------------------------------------------------------------------------

EXTI0_IRQHandler	
	
;		Do a quick timed delay to debounce the button 
	
	mov r0, #0x00								; r0 = 0
	mov r1, #0xFFFF								; r1 = 0xFFFFF
	
	lsl r1, #1									;
	add r1, #0xFF								;
	
	
btn_dbnc cmp r0, r1								; Loop until r0 == r1
	add r0, #1									; r0++
	blo btn_dbnc								; if (r0 < r1), keep waiting
	
	
	
;		Add to btn_cnt	
	
	ldr r0, =btn_cnt							; r0 -> btn_cnt addrs.
	ldr r1, [r0]								; r1 = btn_cnt
	add r1, #1									; btn_cnt++
	str r1, [r0]								; Write new btn_cnt back to memory




;		Reset EXTI pending-bit
	
	ldr r0, =EXTI								; r0 -> points to EXTI memory block
	ldr r1, [r0, #PR]							; r1 = EXTI_PR (pending register)
	ORR r1, #0x00000001							; Reset the pending interrupt request for line 0 (by setting it to HIGH)
	str r1, [r0, #PR]							; Write the new pending register code back to the EXTI_PR
	
	
;		RESET NVIC pending bit 
	
	ldr r0, =NVIC_ICPR0							; r0 -> NVIC interrupt clear pending register 0
	ldr r1, [r0]								; r1 = NVIC interrupt clear pending register 0
	ORR r1, #0x40								; Write bit 6 to HIGH
	str r1, [r0]								; Write new NVIC interrupt clear pattern back to memory



	bx lr										; return back to stopping point



; -------------------------------------END of Subroutine -------------------------------------------------------------------





























;----------------------------------------------------------------------
; gen_tri - generate triangle - A subroutine that generates a triangle waveform
;	
;			inputs: none (as far as parameters go)
;			outputs: updates global var waveform
;
;----------------------------------------------------------------------


gen_tri	

;	// This segment is for when the triangle is increasing

	ldr r0, =TIM4_cnt			; r0 -> address of TIM4_cnt
	ldr r1, [r0]					; r1 = TIM4_cnt, an interrupt counter

	ldr r0, =plot_delay				; r0 -> address of plot_delay
	ldr r2, [r0]					; r2 = plot_delay, interrupts between two samples



; -----IF Statement------------------
	cmp r1, r2						;
	blo tri_IF2						;
;------------------------------------
	
;	If (#_interrupts_occurred >= #_interrupts_between_plots) 


	ldr r0, =DACvalue				; r0 -> address of DACvalue
	ldr r1, [r0]					; r1 = DACvalue, current value of the digital waveform
	
	ldr r0, =tri_slope				; r0 -> address of slope
	ldr r2, [r0]					; r2 = slope, the change in the waveform
	
	add r1, r2						; Increase waveform by slope (DAC + m)
	
	ldr r0, =DACvalue				; r0 -> address of DACvalue
	str r1, [r0]					; Write new DACvalue to memory
	
	ldr r0, =TIM4_cnt				; r0 -> TIM4_cnt addrs.
	mov r1, #0						; r1 = 0
	str r1, [r0]					; Reset TIM4_cnt ( = 0)







	

; -----IF Statement------------------
tri_IF2	ldr r0, =DACvalue			; 	r0 -> DACvalue Addrs.
	ldr r1, [r0]					; 	r1 = DACvalue
									;
	mov r0, #0xFFF					; 	r0 = 0xFFF, 4095 (decimal)
									;
									;
	cmp r1, r0					    ;
	blo	tri_IF3					    ;
;------------------------------------

;	if (current waveform > MAX_VALUE)


	b tri_dec						; Branch to triangle decrease loop




; if (chng_wav == 1)

 ;-----IF STATEMENT---------------
tri_IF3	ldr r0, =chng_wav	     ;	r0 -> chng_wav addrs		
	ldr r1, [r0] 				 ;	r1 = chng_wav	
	mov r0, #0x01				 ;	r0 = #1		
	cmp r1, r0					 ;	if (chng_wav == 1)	
	bleq wave_setup				 ;	branch to wave_setup function	
 ;--------------------------------


			
;	Otherwise

	b gen_tri						; Go back to top, generate another waveform
	














;	------------THE DECREASING LOOP------------------


	
tri_dec	
	
	
	
	
	
	ldr r0, =TIM4_cnt				; r0 -> address of TIM4_cnt
	ldr r1, [r0]					; r1 = TIM4_cnt, an interrupt counter

	ldr r0, =plot_delay				; r0 -> address of plot_delay
	ldr r2, [r0]					; r2 = plot_delay, interrupts between two samples


; -----IF Statement------------------
	cmp r1, r2						;
	blo saw_IF4						;
;------------------------------------
	
;	If (#_interrupts_occurred >= #_interrupts_between_plots) 


	ldr r0, =DACvalue				; r0 -> address of DACvalue
	ldr r1, [r0]					; r1 = DACvalue, current value of the digital waveform
	
	ldr r0, =tri_slope				; r0 -> address of slope
	ldr r2, [r0]					; 	r2 = slope, the change in the waveform
	
	sub r1, r2						; decrease waveform by slope (DAC - m)
	
	ldr r0, =DACvalue				; r0 -> address of DACvalue
	str r1, [r0]					; Write new DACvalue to memory
	
	ldr r0, =TIM4_cnt				; r0 -> TIM4_cnt addrs.
	mov r1, #0						; r1 = 0
	str r1, [r0]					; Reset TIM4_cnt ( = 0)







	




; if (chng_wav == 1)

 ;-----IF STATEMENT---------------
saw_IF4	ldr r0, =chng_wav	     ;	r0 -> chng_wav addrs		
	ldr r1, [r0] 				 ;	r1 = chng_wav	
	mov r0, #0x01				 ;	r0 = #1		
	cmp r1, r0					 ;	if (chng_wav == 1)	
	bleq wave_setup				 ;	branch to wave_setup function	
 ;--------------------------------




; -----IF Statement------------------
saw_IF5	ldr r0, =DACvalue			; 	r0 -> DACvalue Addrs.
	ldr r1, [r0]					; 	r1 = DACvalue					
									;
									;
	cmp r1, #0x51				    ; compare DACvalue to decreasing slope
	bgt tri_dec						; Go back to top of dec, generate another waveform				    ;
;------------------------------------

;	if (current waveform < MINIMUM)

	ldr r0, =LED_pattern		; Toggle blue LED
	ldr r1, [r0]				; r1 = LED_pattern
	EOR r1, #0x08				;
	str r1, [r0]				; write back to LED_pattern
	
	push {r1}					; pass LED_pattern as a parameter
	ldr r0, =lr_copy			; Store copy of link register
	str lr, [r0]				;
	bl L_WRITE					; subroutine to update LEDs onboard
	ldr r0, =lr_copy			;
	ldr lr, [r0]				; Restore link register

	b gen_tri						; Branch to triangle decrease loop






	
	
	
	



;---------------------------------------END------------------------------------------------------




























;	Data Area, starting at 0x20000000 ____________________________________________________


	EXPORT TIM4_cnt
	EXPORT DACvalue
	EXPORT btn_cnt
	EXPORT plot_delay
	EXPORT saw_slope
	EXPORT LED_pattern

	AREA Data1, DATA

TIM4_cnt dcd 0				; Total interrupts by Timer 4 
							;	(since this var's reset to 0)
							
btn_cnt dcd 0				; Button-press counter


plot_delay dcd 0			; Total interrupts between plots

DACvalue dcd 0				; Instantaneous/current value of the waveform (data)
saw_slope dcd 0				; Linear slope of the waveform
	


current_wave dcd 0			; current waveform
							; 0 = sawtooth
							; 1 = triangle
							
							

btn_tmr dcd 0 				; Counts the amount of interrupts after a button press
							; 	and then resets and changes waveform after 2 seconds 




chng_wav dcd 0				; Tells if ready to change the waveform (1 or 0)
							;	Rather than updating waveform solely based off btn_cnt
							
							
							
							
tri_slope dcd 0				; #0x52
	

LED_pattern dcd 0			; 4 bit LED pattern
	
	
lr_copy dcd 0				; Holds a copy of the link register


;____________________HAS YET TO BE INITIALIZED IN MAIN PROGRAM_________________________
	

							





							
							




	END; End of assembly program.
