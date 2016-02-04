;****************************************************************

; Console I/O through the on board UART for MSP 430X4XXX


; experimenter board RAM at 0x1100 - 0x30ff, FLASH at 0x3100;


; - 0xfbff


;****************************************************************



		.cdecls C,LIST,"msp430fg4618.h"


; cdecls tells assembler to allow the device header file



;----------------------------------------------------------------

; Main Code



LCD_SIZE .byte 11 ; eleven bytes needed by the LCD

;Array of hex values that coorespond the correct 0-F display on LCD


num	.byte 0x5F,0x06,0x6B,0x2F,0x36




	.byte 0x3D,0x7D,0x07,0x7F,0x3F


	.byte 0x77,0x07C,0x59,0x6E,0x79,0x71

;----------------------------------------------------------------------


;----------------------------------------------------------------



			.text ; program start



			.global _START ; define entry point


;----------------------------------------------------------------



START 		mov.w #300h,SP ; Initialize 'x1121


; stackpointer



StopWDT 	mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT




			call #Init_UART




			call #Init_LCD		; go initialize the LCD Display



Mainloop

			call #HEX8IN

			mov.w R10,R6
			mov.w R11,R7

			;call# DISPLAY_TO_LCD
			mov.w #'+',R4 ;add a plus


			call #OUTA_UART


			call#HEX8IN


			;call# DISPLAY_TO_LCD



			mov.w #'=',R4 ;add a plus


			call #OUTA_UART

			;combine to 8 bit values
			rla R6
			rla R6
			rla R6
			rla R6

			add.b R6,R7

			rla R10
			rla R10
			rla R10
			rla R10

			add.b R10,R11

			;add together

			add.w R7,R11

			;	swap bytes

			;swpb R11
			push.w R11
			rra R11
			rra R11
			rra R11

			rra R11
			rra R11
			rra R11
			rra R11

			rra R11

			mov.b R11,R7 ; INDEX FOR lcd TO PRINT
			and.w #0X000F,R8

			call #HEX10UT ; PRINT 4TH BIT



			pop.w R11



			push.w R11
			rra R11
			rra R11
			rra R11
			rra R11

			mov.b R11,R8 ; INDEX FOR lcd TO PRINT
			and.w #0X000F,R8
			call #HEX10UT ;PRINT 3RD BIT


			pop.w R11


			mov.b R11,R9 ; INDEX FOR lcd TO PRINT
			and.w #0X000F,R9

			call #HEX10UT ; PRINT LAST BIT


			call #DISPLAY_TO_LCD_CHAR





			mov.b #0X0A,R4








			call #OUTA_UART



			mov.w #0X0D,R4







			call #OUTA_UART



			jmp Mainloop

HEX10UT  ; this function displays a 4 bit character
	push.w R11

	and.w #0x000F,R11

	cmp.b #0x0A, R11

	jhs Letter2

	add.b #0x30, R11

	mov.b R11,R4

	call #OUTA_UART

	jmp LP2

Letter2 add.b #0x37,R11

		mov.b R11,R4

		call #OUTA_UART

LP2		pop.w R11

		ret









HEX8IN	call #INCHAR_UART



			call #OUTA_UART



			mov.w R4, R10



			call #Convert



			mov.w R10,R8





			call #INCHAR_UART



			call #OUTA_UART


			mov.w R4, R10



			call #Convert



			mov.w R10, R11 ; store 1st character



			mov.w R8, R10; store second character












			ret


		;mov.w R11,R4







		;call #OUTA_UART






DISPLAY_TO_LCD_CHAR	; INPUT R4-LAST CHAR PRINTED IN HYPERTERMINAL




	mov.w #LCDM3, R5	;set up LCD memory pointer to R5







	;add.w #0x30,R5







	;mov.b #0x00, R7	;move the current number to temp



lpt1




	;enter the number 2







; move 0xff into R7 to turn on all LCD segments the LCD memory







	;mov.b num(R7), 0(R5)		;send element in num arraty to LCD



	;and.w #0x000F,R10



		;and.w #0x000F,R11







	mov.b num(R7), R7	   ;send b to LCD memory for display
	mov.b num(R8), R8	   ;send b to LCD memory for display
	mov.b num(R9), R9	   ;send b to LCD memory for display







	mov.b R9 , 0(R5) ; display first character in
	mov.b R8 , 1(R5) ; display first character in
	mov.b R7 , 2(R5) ; display first character in







	;and.b #0x0000,R14




; Increment R5 to point to the next seven segment display







; Increment R8 for the next count inthe loop



	;inc.b R8			;increment R8 for next number in array



	;inc.b R7


	mov.w #0xFFFF,R15 ;Delay to R15


L1



	dec.w R15 ; Decrement R15



	jnz L1


	mov.w #0xFFFF,R15 ;Delay to R15



L2


	dec.w R15 ; Decrement R15




	jnz L2



	;cmp.b 0xLCD_SIZE, R8		;check if loop is done



	;cmp.w #0x10,R8 ;check if all 16 values are printed






	;jnz lpt1		;if not loop again





	;pop.w R5



	;pop.w R6



	;pop.w R7



	;pop.w R8







	ret











Convert




			mov.w #0x2F, R9







			cmp.w R10,R9







			jge  if







			cmp.w #0x3A,R10







			jge  if







			sub.w #0x30,R10















if			cmp.w R10, R9







			jge else







			cmp.w #0x3A, R10







			jge else







			sub.w #0x30,R10







			jmp continue




else		mov.w #0x40, R9







			cmp.w R10,R9







			jge continue







			cmp.w #0x47, R10







			jge continue







			sub.w #0x37,R10





continue	;rla.w R10







			;rla.w R10







			;rla.w R10







			;rla.w R10







			;add.w R10, R11















			;mov.w R10,R4







			;call #OUTA_UART







		;mov.w R11,R4







		;call #OUTA_UART





			ret



;Mainloop 	xor.b #02h,&P2OUT ; Toggle P2.2







;Wait 		mov.w #0A000h,R15 ; Delay to R15







;L1 			dec.w R15 ; Decrement R15







;			jnz L1 ; Delay over?







; go print a character to the screen from the keyboard







;			call #INCHAR_UART







;			call #OUTA_UART







;			jmp Mainloop ; Again







;







OUTA_UART







;----------------------------------------------------------------







; prints to the screen the ASCII value stored in register 4 and







; uses register 5 as a temp value







;----------------------------------------------------------------







; IFG2 register (1) = 1 transmit buffer is empty,







; UCA0TXBUF 8 bit transmit buffer







; wait for the transmit buffer to be empty before sending the







; data out







			push R5







lpa 		mov.b &IFG2,R5







			and.b #0x02,R5







			cmp.b #0x00,R5







			jz lpa







; send the data to the transmit buffer UCA0TXBUF = A;







			mov.b R4,&UCA0TXBUF







			pop R5







			ret







INCHAR_UART







;----------------------------------------------------------------







; returns the ASCII value in register 4







;----------------------------------------------------------------







; IFG2 register (0) = 1 receive buffer is full,







; UCA0RXBUF 8 bit receive buffer







; wait for the receive buffer is full before getting the data







			push R5







lpb 		mov.b &IFG2,R5







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















;P2SEL=0x30;







; transmit and receive to port 2 b its 4 and 5







			mov.b #0x30,&P2SEL







; Bits p2.4 transmit and p2.5 receive UCA0CTL0=0







; 8 data, no parity 1 stop, uart, async







			mov.b #0x00,&UCA0CTL0







; (7)=1 (parity), (6)=1 Even, (5)= 0 lsb first,







; (4)= 0 8 data / 1 7 data, (3) 0 1 stop 1 / 2 stop, (2-1) --







; UART mode, (0) 0 = async







; UCA0CTL1= 0x41;







			mov.b #0x41,&UCA0CTL1







; select ALK 32768 and put in software reset the UART







; (7-6) 00 UCLK, 01 ACLK (32768 hz), 10 SMCLK, 11 SMCLK







; (0) = 1 reset







;UCA0BR1=0;







; upper byte of divider clock word







			mov.b #0x00,&UCA0BR1







;UCA0BR0=3; ;







; clock divide from a clock to bit clock 32768/9600 = 3.413







			mov.b #0x03,&UCA0BR0







; UCA0BR1:UCA0BR0 two 8 bit reg to from 16 bit clock divider







; for the baud rate







;UCA0MCTL=0x06;







; low frequency mode module 3 modulation pater used for the bit







; clock







			mov.b #0x06,&UCA0MCTL







;UCA0STAT=0;







; do not loop the transmitter back to the receiver for echoing







			mov.b #0x00,&UCA0STAT







; (7) = 1 echo back trans to rec







; (6) = 1 framing, (5) = 1 overrun, (4) =1 Parity, (3) = 1 break







; (0) = 2 transmitting or receiving data







;UCA0CTL1=0x40;







; take UART out of reset







			mov.b #0x40,&UCA0CTL1







;IE2=0;







; turn transmit interrupts off







			mov.b #0x00,&IE2







; (0) = 1 receiver buffer Interrupts enabled







; (1) = 1 transmit buffer Interrupts enabled







;----------------------------------------------------------------







;****************************************************************







;----------------------------------------------------------------







; IFG2 register (0) = 1 receiver buffer is full, UCA0RXIFG







; IFG2 register (1) = 1 transmit buffer is empty, UCA0RXIFG







; UCA0RXBUF 8 bit receiver buffer, UCA0TXBUF 8 bit transmit







; buffer







			ret







;----------------------------------------------------------------







; Initialize the LCD system


;----------------------------------------------------------------------


Init_LCD







	push.w R5



	push.w R6



	push.w R7







	mov.b #0x00, R6







; R5 points to the beginning memory for the LCD







; Turn on all of the segments







	mov.w #LCDM3, R5







	mov.b #0x00, R7











lpt mov.b R7, 0(R5)











	inc.w R5











	inc.b R6







; See if the loop is finished











	cmp.b LCD_SIZE, R6











	jnz lpt











	mov.b #0x1C, &P5SEL







	mov.b #0x00, &LCDAVCTL0







	mov.b #0x7E, &LCDAPCTL0







	mov.b #0x7d, &LCDACTL











	pop.w R5



	pop.w R6



	pop.w R7







	ret











;----------------------------------------------------------------------











; Interrupt Vectors







;----------------------------------------------------------------







			.sect ".reset" ; MSP430 RESET Vector







			.short START ;
