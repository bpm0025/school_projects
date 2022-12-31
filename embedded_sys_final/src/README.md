# Embedded Systems Final Project (Programmable Function Generator)
## By Basil Moledina


  This folder contains all of my source code, libraries, and "equates/equ" files for my final project in my embedded systems class. The project was to design and write a software-based function generator that outputs digital signals. For this project, I did not use any outside help or external libraries, designing and writing the entire project and its supporting functions all by myself from scratch. As this was created for an embedded systems class, the project is written in assembly language. This is to prove that I am fluent in assembly language and incredibly proficient with low-level computing concepts in general. The project and all its code files are written using the ARM Thumb instruction set. The microcontroller used for the project is a STM32F411. Program files are linked, assembled, and flashed onto the board using Keil Microvision. The following is a list of libraries and program files I wrote, as well as a brief description of them: <br/>
  
  
  * prgm_final.s - The main driver program. Performs setup, then concurrently generates waveform signals in a control loop while monitoring user input.
  * LED_control.s - A library for setting up and controlling built-in LEDs on the microcontroller. LEDs are used for displaying info about signal being generated.
  * TIMER_INITIALIZATION.s - A library for enabling timer interrupts and setting up the amount of time between clock interrupts.
  * EXTI_SETUP.s - A library for initializing and setting up external interrupts. A button on the microcontroller is used for input, and interrupts main program.


