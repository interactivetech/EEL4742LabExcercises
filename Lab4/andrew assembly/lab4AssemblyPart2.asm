;----------------------------------------------------------------------
; LCD Driver for the for MSP 430X4XXX experimenter board using
; Softbaugh LCD
; Davies book pg 259, 260
; setup a pointer to the area of memory of the TMS430 that points to
; the segments
; of the softbaugh LCD LCDM3 = the starting address
;----------------------------------------------------------------------
	.cdecls C,LIST,"msp430fg4618.h" ; cdecls tells assembler
; to allow
; the device header file
;----------------------------------------------------------------------
; #LCDM3 is the start of the area of memory of the TMS430 that points
; to the segments
; of the softbaugh LCD LCDM3 = the starting address
; each of the seven segments for each display is store in memory
; starting at address LCDM3
; which is the right most seven segment of the LCD
; The bit order in each byte is
; dp, E, G, F, D, C, B, A or
; :, E, G, F, D, C, B, A
; after the seven segments these memory locations are used to turn on
; the special characters
; such as battery status, antenna, f1-f4, etc.
; there are 7 seven segment displays
; data area ram starts 0x1100
;----------------------------------------------------------------------
; the .sect directives are defined in lnk_msp430f4618.cmd
; .sect ".stack" ; data ram for the stack
; .sect ".const" ; data rom for initialized data
; constants
; .sect ".text" ; program rom for code
; .sect ".cinit" ; program rom for global inits
; .sect ".reset" ; MSP430 RESET Vector
	.sect ".sysmem" ; data ram for initialized
; variables







LCD_SIZE .byte 11 ; eleven bytes needed by the LCD







;Array of hex values that coorespond the correct 0-F display on LCD



numbers	.byte 0x5F,0x06,0x6B,0x2F,0x36



	.byte 0x3D,0x7D,0x07,0x7F,0x3F



	.byte 0x77,0x07C,0x59,0x6E,0x79,0x71



;----------------------------------------------------------------------



; Main Code



;----------------------------------------------------------------------



	.text ; program start



	.global _START ; define entry point



;----------------------------------------------------------------------



START mov.w #300h,SP ; Initialize 'x1121



; stackpointer



StopWDT mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT



SetupP1 bis.b #04h,&P2DIR ; P2.2 output







Mainloop







	call #Init_LCD		; go initialize the LCD Display






; R8 is a loop counter to cover all of the segments. This count
; counts up from 0
	mov.b #0x00, R8		;loop counter to go through all numbers



	mov.w #LCDM3, R5	;set up LCD memory pointer to R5







lpt1



	mov.b #0x6B, R7	;move the current number to temp


; move 0xff into R7 to turn on all LCD segments the LCD memory


	mov.b R7, 0(R5)		;send number to LCD





; Increment R5 to point to the next seven segment display
; Increment R8 for the next count inthe loop

	inc R8			;increment R8 for next number in array

	inc R5





	mov.w #0x00,R15 ;Delay to R15



L1



	;dec.w R15 ; Decrement R15



	jnz L1







;	mov.w #0h,R15 ;Delay to R15



;L2



;	dec.w R15 ; Decrement R15



;	jnz L2











	cmp.b #LCD_SIZE, R8		;check if loop is done



	jnz lpt1		;if not loop again











	jmp Mainloop		;if so start from main again







;rest unmodified



;----------------------------------------------------------------------



; Initialize the LCD system



;----------------------------------------------------------------------



Init_LCD



	mov.b #0x00, R6


; R5 points to the beginning memory for the LCD
; Turn on all of the segments
	mov.w #LCDM3, R5



	mov.b #0x00, R7



lpt mov.b R7, 0(R5)



	inc.w R5



	inc.b R6
;


; See if the loop is finished



	cmp.b LCD_SIZE, R6



	jnz lpt



	mov.b #0x1C, &P5SEL



	mov.b #0x00, &LCDAVCTL0



	mov.b #0x7E, &LCDAPCTL0



	mov.b #0x7d, &LCDACTL



	ret



;----------------------------------------------------------------------



; Interrupt Vectors



;----------------------------------------------------------------------



	.sect ".reset" ; MSP430 RESET Vector



	.short START ;



	.end
