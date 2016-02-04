Assembly Program 1:Part 2 Step 6
;****************************************************************

.cdecls C,LIST,"msp430fg4618.h" ;cdecls tells assembler to allow the device header file

.bss label, 4 	;allocates 4 bytes of allocates 4 bytes of uninitialized memory 

.word 0x1234 	;example of defining a 16 bit

.byte 0x0d,0x0a ; add a CR and a LF to the string
.byte 0x00 ; null terminate the string

.sect ".const" ; initialized data rom for constants

strg1 .string "Laboratory #2 for EEL4742 embedded Systems"  ;Define string one to be printed
.byte 0x0d,0x0a		;CR and LF
.byte 0x00 		;null terminate the string with

.text 		;program start
.global _START  ;define entry point

;----------------------------------------------------------------

START mov.w #300h,SP ; Initialize 'x1121 stackpointer

StopWDT mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT
SetupP1 bis.b #02h,&P2DIR 	;P2.2 output
  
call #Init_UART 		;initialize the uart

Mainloop 

	xor.b #02h,&P2OUT	;Toggle P2.2, flashes LED

Wait 
	mov.w #0A000h,R15	;Delay to R15

L1 
	dec.w R15 ; Decrement R15
	jnz L1

	mov #strg1,R6 		;set up string pointer, string1 to register 6
	call #send		;send string to be outputed

getStuck jmp getStuck ; infinite loop

;loop to send in characters to OUTA
send
	mov.b @R6, R4		;move 1 char of string1 to R4 for OUTA
	cmp.b #0, R4		;check null, if so return
	jeq L3

	call #OUTA_UART		;output character
	inc R6 			;increment string pointer to next char
	

	mov.b @R6, R7	  	;move next character into R7
	cmp.b #0x00, R7		;check for NULL character unless repeat
	jnz send

L3 ret


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