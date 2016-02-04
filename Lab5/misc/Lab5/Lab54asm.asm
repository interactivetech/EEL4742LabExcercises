.include "msp430g2553.inc"

    org 0xf800
start:
    mov.w #WDTPW|WDTHOLD, &WDTCTL
    ;Initialize stack pointer
    mov.w #300h , SP 
    ;Calibrate DCO
    mov.b &CALBC1_1MHZ , &BCSCTL1
    mov.b &CALDCO_1MHZ , &DCOCTL          
    ;Initialize LED's    
    mov.w #0x0041 , &P1DIR
    mov.b #0x01 , &P1OUT
    call #initUart
main:
	;;	call #INCHAR_UART
	;; 	mov.w #0x2D,R4	add a plus
	;; 	call #OUTA_UART
;  call #uartGetChar
	;; call #switchCase
	;; call #uartPutChar
	;;  xor.b #0x41 ,  &P1OUT


			call #HEX8IN ; get first number

			mov.w R10,R6
			mov.w R11,R7

			;call# DISPLAY_TO_LCD
			mov.w #0x2D,R4 ;add a minus


			call #OUTA_UART


			call #HEX8IN ;get second character


			;call# DISPLAY_TO_LCD



			mov.w #0x3D,R4 ;add a equal


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

			;subtract together

			;compare two values to subtract bigger num from smaller num
			cmp.b R7,R11

			jhs SUB1 ;jump if R7 > R11
					; else R7< R11




			sub.w R11,R7
			mov.w R7,R11   ; store result in r11 register to be printed
			mov.b #0x00,R7 ; INDEX FOR lcd TO PRINT
			and.w #0x000F,R7
			jmp PRINT

			;	swap bytes

SUB1:	sub.w R7,R11
			mov.b #0xFF,R7 ; INDEX FOR lcd TO PRINT

			mov.w #0x2D,R4 ;add a minus


			call #OUTA_UART; PRINT NEGATIVE SIGN



			;swpb R11
PRINT:	;print the resulting 8 bits



			push.w R11
			rra R11
			rra R11
			rra R11
			rra R11

			mov.b R11,R8 ; INDEX FOR lcd TO PRINT
			and.w #0x000F,R8
			call #HEX10UT ;PRINT 3RD BIT


			pop.w R11


			mov.b R11,R9 ; INDEX FOR lcd TO PRINT
			and.w #0x000F,R9

			call #HEX10UT ; PRINT LAST BIT


			;;; call #DISPLAY_TO_LCD_CHAR





			mov.b #0x0A,R4








			call #OUTA_UART



			mov.w #0x0D,R4







			call #OUTA_UART



			jmp main


HEX10UT:	; this function displays a 4 bit character
	push.w R11

	and.w #0x000F,R11

	cmp.b #0x0A, R11

	jhs Letter2

	add.b #0x30, R11

	mov.b R11,R4

	call #OUTA_UART

	jmp LP2

Letter2:	add.b #0x37,R11

		mov.b R11,R4

		call #OUTA_UART

LP2:	pop.w R11

		ret

HEX8IN:	call #INCHAR_UART



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

Convert:	




			mov.w #0x2F, R9
			cmp.w R10,R9
			jge  if
			cmp.w #0x3A,R10
			jge  if
			sub.w #0x30,R10

if:	cmp.w R10, R9
			jge else
			cmp.w #0x3A, R10
			jge else
			sub.w #0x30,R10
			jmp continue




else:	mov.w #0x40, R9
		cmp.w R10,R9
			jge continue
			cmp.w #0x47, R10
			jge continue
			sub.w #0x37,R10





continue:	;rla.w R10
		;rla.w R10
			;rla.w R10







			;rla.w R10
			;add.w R10, R11
			;mov.w R10,R4
			;call #OUTA_UART
			;mov.w R11,R4
			;call #OUTA_UART
			ret







;Subprocess that creates a delay
delay:
    push R5
    mov.w #0xFFFF , R5
delay_loop:
    dec R5
    jn delay_loop
delay_done:
    pop R5
    ret

;Subprocess that initilizes the uart 
initUart:
    push R5
    ;Use P1.1 and P1.2 as USCI_A0
    ;P1SEL |= 0x06; 
    bis.b #0x06 , &P1SEL
    ;Use P1.1 and P1.2 as USCI_A0
    ;P1SEL2|= 0x06;                    
    bis.b #0x06 , &P1SEL2
    ;Set 1.2 as output
    ;P1DIR |= 0x04;                      
    bis.w #0x04 , &P1DIR
    ;Use SMCLK / DCO 
    ;UCA0CTL1 = UCSSEL_2;               
    mov.b &UCSSEL_2 , &UCA0CTL1
    ;1 MHz -> 9600   N=Clock/Baud
    ;UCA0BR0 = 104;                      
    mov.w #0x68 , &UCA0BR0
    ;1 MHz -> 9600
    ;UCA0BR1 = 0;                        
    mov.b #0x00 , &UCA0BR1
    ;Modulation UCBRSx = 1
    ;UCA0MCTL = UCBRS1
    mov.w &UCBRS1 , &UCA0MCTL  
    ;Initialize USCI  
    ;UCA0CTL1 &= ~UCSWRST
    bic.b &UCSWRST , UCA0CTL1
    pop R5
    ret

;Displays a character on the terminal
;R4 -> UART
OUTA_UART:
    push R5
uartPutChar_loop:
    mov.b IFG2 , R5
    and.w &UCA0TXIFG , R5
    cmp.w #0x00 , R5
    jz uartPutChar_loop
    mov.b R4 , &UCA0TXBUF
    pop R5
    ret

;Gets a character entered on the terminal
;UART -> R4
INCHAR_UART:
    push R5
uartGetChar_loop:  
    mov.b IFG2 , R5
    and.b #0x01 , R5
    cmp.w #0x00 , R5
    jz uartGetChar_loop
    mov.b &UCA0RXBUF , R4
    pop R5
    ret

;Switch case
;Params -> R4(character that gets switched)
;R4->R4 
switchCase:
    ;R4 < 'A'
    cmp.b #0x41 , R4
    jnc switchCase_return
    ;R4 < ('Z' + 1)
    cmp.b #0x5B , R4
    jnc switchCase_isUpper
    ;R4 >= ('z' + 1)
    cmp.b #0x7B , R4
    jc switchCase_return
    ;R4 >= 'a'
    cmp.b #0x61 , R4
    jc switchCase_isLower
    jmp switchCase_return
switchCase_isUpper:
    add.b #0x20 , R4
    jmp switchCase_return
switchCase_isLower:
    sub.b #0x20 , R4
switchCase_return:
    ret

end:
    org 0xfffe
    dw start