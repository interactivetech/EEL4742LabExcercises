{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Consolas;}{\f1\fnil\fcharset0 Calibri;}}
{\colortbl ;\red63\green127\blue95;\red0\green0\blue0;\red42\green0\blue255;\red127\green0\blue85;}
{\*\generator Msftedit 5.41.21.2510;}\viewkind4\uc1\pard\sa200\sl276\slmult1\cf1\lang9\f0\fs20 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\cf0\par
\cf1 ;This program converts an 8-bit bin number to Hex\cf0\par
\cf1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\cf0\par
\par
\cf2\tab .cdecls C,LIST,\cf3 "msp430fg4618.h"\cf0\par
\cf2\tab\cf1 ; cdecls tells assembler to allow the device header file\cf0\par
\cf2\tab .bss label, 4 \cf1 ; allocates 4 bytes of uninitialized memory with the name label\cf0\par
\cf2\tab\cf4\b .word\cf2\b0  0x1234 \cf1 ; example of defining a 16 bit word\cf0\par
\cf2\tab .sect \cf3 ".const"\cf2  \cf1 ; initialized data rom\cf0\par
\cf2\tab\cf4\b .text\cf2\b0  \cf1 ; program start\cf0\par
\cf2\tab\cf4\b .global\cf2\b0  _START \cf1 ; define entry point\cf0\par
\par
\cf2 START mov.w #300h,SP \cf1 ; Initialize 'x1121 stackpointer\cf0\par
\cf2 StopWDT mov.w #WDTPW+WDTHOLD,&WDTCTL \cf1 ; Stop WDT\cf0\par
\cf2 SetupP1 call #Init_UART \cf1 ; go initialize the uart\cf0\par
\par
\cf2 Mainloop mov #0x08, R6\tab\cf1 ;initalize counter for loop\cf0\par
\cf2\tab mov #0x0, R9\tab\tab\cf1 ;Initialize R9 to zero\cf0\par
\par
\cf2 input call #INCHAR_UART\tab\cf1 ;call INCHAR_UART function to receive char\cf0\par
\cf2\tab mov R4, R8\tab\tab\tab\cf1 ;save input in R8\cf0\par
\cf2\tab call #OUTA_UART\tab\tab\cf1 ;call OUTA_UART function to display input\cf0\par
\cf2\tab sub #0x31, R8\tab\tab\cf1 ;Check if input LSB it is 0 or 1\cf0\par
\cf2\tab jn zero\tab\tab\tab\tab\cf1 ;if its neg, then its zero\cf0\par
\cf2\tab rla R8\tab\tab\tab\tab\cf1 ;shift left to add space for new LSB bit\cf0\par
\cf2\tab add #0x01, R9\tab\tab\cf1 ;add one to fill in new LSB bit\cf0\par
\cf2\tab jmp one\cf0\par
\par
\cf2 zero\cf0\par
\cf2\tab rla R9\tab\tab\tab\tab\cf1 ;if condition was zero, shift \cf0\par
\cf2 one\cf0\par
\cf2\tab dec R6\tab\tab\tab\tab\cf1 ;decrement R6 - counter\cf0\par
\cf2\tab jnz input\tab\tab\tab\cf1 ;Continue to loop: will loop a total of 8 times\cf0\par
\par
\cf2\tab mov #0x0A, R4\tab\tab\cf1 ;store new Newline character into R4 \cf0\par
\cf2\tab call #OUTA_UART\tab\tab\cf1 ;call OUTA_UART function to display new line\cf0\par
\cf2\tab mov #0x0D, R4\tab\tab\cf1 ;store carriage return character\cf0\par
\cf2\tab call #OUTA_UART\tab\tab\cf1 ;call OUTA_UART function to display carriage return\cf0\par
\par
\cf2\tab mov.b R9, R10 \cf1 ;R9 and R10 get converted from bin to hex and then print\cf0\par
\par
\cf2\tab mov #0xF0, R11\tab\cf1 ;set bit mask\cf0\par
\cf2\tab and.b R11, R9\tab\cf1 ;AND R9 to mask, which gets first digit(4 bits) alone\cf0\par
\cf2\tab rra R9\tab\tab\tab\cf1 ;shift right a total of 4 bits to remove excess zeros\cf0\par
\cf2\tab rra R9\tab\tab\tab\cf0\par
\cf2\tab rra R9\cf0\par
\cf2\tab rra R9\cf0\par
\cf2\tab mov #0x02, R14\tab\cf1 ;initalize counter for loop\cf0\par
\cf2\tab jmp BinThex\cf0\par
\par
\cf2 next\cf0\par
\cf2\tab mov R9, R4\tab\tab\cf1 ;store resulkt into R4 to print\cf0\par
\cf2\tab call #OUTA_UART\tab\cf1 ;call OUTA_UART function to display result\cf0\par
\cf2\tab dec R14\tab\tab\tab\cf1 ;decrement R14 for loop (will loop only twice)\cf0\par
\cf2\tab jz print\tab\tab\cf1 ;once counter is zero,jump when zero status to go print LF and CR\cf0\par
\cf2\tab mov #0x0F, R12\tab\cf1 ;set bit mask for second digit (high 4 bytes)\cf0\par
\cf2\tab and.b R12, R10\tab\cf1 ;AND R10 to mask, which gets second digit(high 4 bits) alone\cf0\par
\cf2\tab mov R10, R9\tab\tab\cf1 ;Move to R9 ti convert\cf0\par
\par
\cf2 BinThex\cf0\par
\cf2\tab mov R9, R12\tab\tab\cf1 ;preserve R9\cf0\par
\cf2\tab sub #0xA, R12 \tab\cf1 ;call subtract function to check if output is a letter\cf0\par
\cf2\tab jn Number \tab  \tab\cf1 ;if negative, jump to Number because the result was a number\cf0\par
\cf2\tab add #0x37, R9\tab\cf1 ;else, convert to letter by adding offest\cf0\par
\cf2\tab jmp next\tab\tab\cf1 ;next, jump back to next function\cf0\par
\par
\cf2 Number add #0x30, R9\tab\cf1 ;call add function to convert to a number between 0-9\cf0\par
\cf2\tab jmp next\tab\tab\tab\cf1 ;next jump back up to next function\cf0\par
\cf1 ;--------------------------------------------------------------------------------\cf0\par
\par
\cf2 print\cf0\par
\cf2 mov #0x0A, R4\tab\tab\cf1 ;store new Newline character into R4 \cf0\par
\cf2\tab call #OUTA_UART\tab\tab\cf1 ;call OUTA_UART function to display new line\cf0\par
\cf2\tab mov #0x0D, R4\tab\tab\cf1 ;store carriage return character\cf0\par
\cf2\tab call #OUTA_UART\tab\tab\cf1 ;call OUTA_UART function to display carriage return\cf0\par
\cf2\tab jmp Mainloop \cf1 ;Loop forever\cf0\par
\par
\par
\cf2 OUTA_UART \cf1 ; prints value stored in register 4 and uses register 5 as a temp value\cf0\par
\cf2\tab push R5\cf0\par
\cf2 lpa mov.b &IFG2,R5\cf0\par
\cf2\tab and.b #0x02,R5\cf0\par
\cf2\tab cmp.b #0x00,R5\cf0\par
\cf2\tab jz lpa\cf0\par
\cf2\tab\cf1 ; send the data to the transmit buffer UCA0TXBUF = A;\cf0\par
\cf2\tab mov.b R4,&UCA0TXBUF\cf0\par
\cf2\tab pop R5\cf0\par
\cf2\tab ret\cf0\par
\par
\cf2 INCHAR_UART \cf1 ; returns the ASCII value in register 4\cf0\par
\cf1 ; wait for the receive buffer is full before getting the data\cf0\par
\cf2\tab push R5\cf0\par
\cf2 lpb mov.b &IFG2,R5\cf0\par
\cf2\tab and.b #0x01,R5\cf0\par
\cf2\tab cmp.b #0x00,R5\cf0\par
\cf2\tab jz lpb\cf0\par
\cf2\tab mov.b &UCA0RXBUF,R4\cf0\par
\cf2\tab pop R5\cf0\par
\cf2\tab ret \tab\cf1 ; go get the char from the receive buffer\cf0\par
\par
\cf2 Init_UART\cf0\par
\cf2\tab mov.b #0x30,&P2SEL \cf1 ; transmit and receive to port 2 b its 4 and 5\cf0\par
\cf2\tab mov.b #0x00,&UCA0CTL0 \cf1 ;8 data, no parity 1 stop, uart, async\cf0\par
\cf2\tab mov.b #0x41,&UCA0CTL1 \cf1 ;UART mode, (0) 0 = async, UCA0CTL1= 0x41;\cf0\par
\cf2\tab mov.b #0x00,&UCA0BR1 \cf1 ;UCA0BR1=0 upper byte of divider clock word\cf0\par
\cf2\tab mov.b #0x03,&UCA0BR0 \cf1 ;clock divide from a clock to bit clock 32768/9600 = 3.413\cf0\par
\cf2\tab mov.b #0x06,&UCA0MCTL \cf1 ;for the baud rate\cf0\par
\cf2\tab mov.b #0x00,&UCA0STAT \cf1 ;do not loop the transmitter back to the receiver for echoing\cf0\par
\cf2\tab mov.b #0x40,&UCA0CTL1 \cf1 ; take UART out of reset\cf0\par
\cf2\tab mov.b #0x00,&IE2 \cf1 ; turn transmit interrupts off\cf0\par
\cf2\tab ret\cf0\par
\cf2\tab .sect \cf3 ".reset"\cf2  \cf1 ; MSP430 RESET Vector\cf0\par
\cf2\tab\cf4\b .short\cf2\b0  START \cf1 ;\cf0\par
\cf2\tab .end\cf0\par
\f1\fs22\par
}
 