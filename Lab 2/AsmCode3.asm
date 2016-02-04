Assembly Program 3:Part 2 Step 8
;****************************************************************

.cdecls C,LIST,"msp430fg4618.h" ;cdecls tells assembler to allow the device header file

.bss label, 4 	;allocates 4 bytes of allocates 4 bytes of uninitialized memory 

.word 0x1234 	;example of defining a 16 bit

.byte 0x0d,0x0a ; add a CR and a LF to the string
.byte 0x00 ; null terminate the string

.sect ".const" ; initialized data rom for constants

;strings for SW1,SW2, none, or both
strg1 .string "SW1 = 1,SW2 = 0";
.byte 0x00
strg2 .string "SW1 = 0,SW2 = 1";
.byte 0x00
strg3 .string "SW1 = 1,SW2 = 1";
.byte 0x00
strg4 .string "SW1 = 0,SW2 = 0";
.byte 0x00

.byte 0x0d,0x0a
.byte 0x00 ; null terminate the string with

.text 		;program start
.global _START  ;define entry point

;----------------------------------------------------------------

START mov.w #300h,SP ; Initialize 'x1121 stackpointer

StopWDT mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT
SetupP1 bis.b #02h,&P2DIR 	;P2.2 output
  
	call #Init_UART 		;initialize the uart

	mov.b #0x00,&P2OUT 		;turn off the LEDs
	mov.b #0x00, R8			;intiate counter register 8 to 0

Mainloop

  	cmp.b #0x02, &P1IN 		;check if SW1 is pressed, if so jump to S1
  	jeq S1
  
   	cmp.b #0x01, &P1IN 		;check if SW2 is pressed, if so jump to S2
   	jeq S2
  
   	cmp.b #0x00, &P1IN 		;check if both switches are pressed
   	jeq Both

	jmp Neither			;default is neither are pressed


S1
	cmp.b #0x01, R8			;check if counter is one, if so SW1 is
	jeq Mainloop			;already pressed and printed, jump to main

	mov #strg1,R6 			;if not set up string pointer	
	call #send			;send char to send, set counter to 1 meaning SW1 
	mov.b #0x01, R8			;was last pressed switch
   	jmp Mainloop

S2
	cmp.b #0x02, R8			;check if counter is two, if so SW2 is
	jeq Mainloop			;already pressed and printed, jump to main

	mov #strg2,R6 			;if not set up string pointer	
	call #send			;send char to send, set counter to 2 meaning SW2 
	mov.b #0x02, R8			;was last pressed switch
   	jmp Mainloop
  
Both
	cmp.b #0x03, R8			;same thing for both,
	jeq Mainloop			;use 3 for counter

	mov #strg3,R6 			;if not send in string3 and set counter to 3
	call #send
	mov.b #0x03, R8
  	jmp Mainloop
  	
Neither
	cmp.b #0x00, R8			;if nothing is pressed, mainloop comes here
	jeq Mainloop			;checks if neither was already printed, if so jmp main

	mov #strg4,R6 			;otherwise print and change counter
	call #send
	mov.b #0x00, R8
   	jmp Mainloop



;loop to send in characters to OUTA
send
	mov.b @R6, R4			;move 1 char of string1 to R4 for OUTA
	cmp.b #0, R4			;check null, if so return
	jeq L3

	call #OUTA_UART			;output character
	inc R6 				;increment string pointer


	mov.b @R6, R7			;move next character into R7
	cmp.b #0x00, R7			;check for NULL character unless repeat
	jnz send

	mov.b #0x0D, R4			;go to next line and
	call #OUTA_UART			;move cursor to beginnning of line
	mov.b #0x0A, R4
	call #OUTA_UART

L3 	ret



OUTA_UART
;----------------------------------------------------------------
; prints to the screen the ASCII value stored in register 4 and
; uses register 5 as a temp value
;----------------------------------------------------------------

	push R5

;buffer delay
lpa 	mov.b &IFG2,R5
	and.b #0x02,R5
	cmp.b #0x00,R5
	jz lpa

	mov.b R4,&UCA0TXBUF
	pop R5
	ret

INCHAR_UART
;----------------------------------------------------------------
; returns the ASCII value in register 4
;----------------------------------------------------------------

	push R5
lpb 	mov.b &IFG2,R5
	and.b #0x01,R5
	cmp.b #0x00,R5	
	jz lpb
	mov.b &UCA0RXBUF,R4
	pop R5
; go get the char from the receive buffer
	ret



Init_UART
;----------------------------------------------------------------
; Initialization code to set up the uart on the experimenter board to 8 data,
; 1 stop, no parity, and 9600 baud, polling operation
;----------------------------------------------------------------

 	mov.b #0x30,&P2SEL

	mov.b #0x00,&UCA0CTL0

	mov.b #0x41,&UCA0CTL1

	mov.b #0x00,&UCA0BR1

	mov.b #0x03,&UCA0BR0

	mov.b #0x06,&UCA0MCTL

	mov.b #0x00,&UCA0STAT

	mov.b #0x40,&UCA0CTL1

	mov.b #0x00,&IE2


;----------------------------------------------------------------
;****************************************************************
;----------------------------------------------------------------
	ret
;----------------------------------------------------------------
; Interrupt Vectors
;----------------------------------------------------------------
	.sect ".reset" ; MSP430 RESET Vector
	.short START
	.end 