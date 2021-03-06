{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Consolas;}{\f1\fnil\fcharset0 Calibri;}}
{\colortbl ;\red63\green127\blue95;\red0\green0\blue0;\red42\green0\blue255;\red127\green0\blue85;}
{\*\generator Msftedit 5.41.21.2510;}\viewkind4\uc1\pard\sa200\sl276\slmult1\cf1\lang9\f0\fs20 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\cf0\par
\cf1 ;This program converts lower-case to upper-case or vice-versa\cf0\par
\cf1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\cf0\par
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
\cf2 Mainloop\cf0\par
\cf2\tab call #INCHAR_UART\tab\cf1 ;receive character\cf0\par
\cf2\tab mov R4, R9\tab\tab\tab\cf1 ;save in R9\cf0\par
\cf2\tab mov R9, R10\tab\tab\tab\cf1 ;copy to R10\cf0\par
\cf2\tab call #OUTA_UART\tab\tab\cf1 ;Display input\cf0\par
\cf2\tab mov #0x0A, R4\tab\tab\cf1 ;store Newline\cf0\par
\cf2\tab call #OUTA_UART\tab\tab\cf1 ;Display new line\cf0\par
\cf2\tab mov #0x0D, R4\tab\tab\cf1 ;store Carriage Return\cf0\par
\cf2\tab call #OUTA_UART\cf0\par
\par
\cf2\tab sub #0x61, R10\tab\tab\cf1 ;check if upper-case\cf0\par
\cf2\tab jn makeLowercase  \cf1 ;jump to lowerCase function if result is negative\cf0\par
\cf2\tab jmp makeUppercase \cf1 ;else jump to Uppercase function\cf0\par
\par
\cf2 makeLowercase add #0x20, R9\tab\cf1 ;converts to lower-case\cf0\par
\cf2\tab jmp print \cf1 ; jump to print function\cf0\par
\par
\cf2 makeUppercase sub #0x20, R9\tab\cf1 ;converts to upper-case\cf0\par
\par
\par
\cf2 print\cf0\par
\cf2\tab mov R9, R4\tab\tab\cf1 ;Load value to print\cf0\par
\cf2\tab call #OUTA_UART\tab\cf1 ;call OUTA_UART to display char\cf0\par
\cf2\tab mov #0x0A, R4\tab\cf1 ;store Newline character \cf0\par
\cf2\tab call #OUTA_UART\tab\cf1 ;call OUTA_UART to display new line\cf0\par
\cf2\tab mov #0x0D, R4\tab\cf1 ;store Carriage Return\cf0\par
\cf2\tab call #OUTA_UART \cf1 ;call OUTA_UART to display Carriage Return\cf0\par
\par
\cf2\tab jmp Mainloop \tab\cf1 ;Loop back to beggining of main loop\cf0\par
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