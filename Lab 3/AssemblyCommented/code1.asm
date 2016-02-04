{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Consolas;}{\f1\fnil\fcharset0 Calibri;}}
{\colortbl ;\red63\green127\blue95;\red0\green0\blue0;\red42\green0\blue255;\red127\green0\blue85;}
{\*\generator Msftedit 5.41.21.2510;}\viewkind4\uc1\pard\sa200\sl276\slmult1\cf1\lang9\f0\fs20 ;****************************************************************\cf0\par
\cf1 ; Console I/O through the on board UART for MSP 430X4XXX\cf0\par
\cf1 ; experimenter board RAM at 0x1100 - 0x30ff, FLASH at 0x3100;\cf0\par
\cf1 ; - 0xfbff\cf0\par
\cf1 ;****************************************************************\cf0\par
\cf2\tab\tab .cdecls C,LIST,\cf3 "msp430fg4618.h"\cf0\par
\cf1 ; cdecls tells assembler to allow the device header file\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ; Main Code\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\par
\cf2\tab\tab\tab\cf4\b .text\cf2\b0  \cf1 ; program start\cf0\par
\cf2\tab\tab\tab\cf4\b .global\cf2\b0  _START \cf1 ; define entry point\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\par
\cf2 START \tab\tab mov.w #300h,SP \cf1 ; Initialize 'x1121\cf0\par
\cf1 ; stackpointer\cf0\par
\cf2 StopWDT \tab mov.w #WDTPW+WDTHOLD,&WDTCTL \cf1 ; Stop WDT\cf0\par
\par
\cf2\tab\tab\tab call #Init_UART\cf0\par
\par
\cf2 Mainloop\cf0\par
\par
\cf2\tab\tab\tab call #INCHAR_UART\cf0\par
\cf2\tab\tab\tab call #OUTA_UART\cf0\par
\cf2\tab\tab\tab mov.w R4, R10 \cf1 //input the first hexidecimal number in a register\cf0\par
\cf2\tab\tab\tab\cf0\par
\par
\cf2\tab\tab\tab call #INCHAR_UART\cf0\par
\cf2\tab\tab\tab call #OUTA_UART\cf0\par
\cf2\tab\tab\tab mov.w R4, R11 \cf1 //input the second hexidecimal number in a register\cf0\par
\cf2\tab\tab\tab\cf0\par
\par
\cf2\tab\tab\tab mov.w #0x0A, R4\cf0\par
\cf2\tab\tab\tab call #OUTA_UART\cf1 ;print out carriage return\cf0\par
\par
\cf2\tab\tab\tab mov.w #0x0D, R4\cf0\par
\cf2\tab\tab\tab call #OUTA_UART\cf1 ;print new line\cf0\par
\cf2\tab\tab\tab mov.w #0x2F, R9 \cf1 ;load value 0x2F to check variable\cf0\par
\cf2\tab\tab\tab\cf0\par
\cf2\tab\tab\tab\cf1 ;section compares the first hex number is between '0'-'9'\cf0\par
\cf2\tab\tab\tab cmp.w R10,R9 \cf0\par
\cf2\tab\tab\tab jge  if \cf0\par
\cf2\tab\tab\tab cmp.w #0x3A,R10\cf0\par
\cf2\tab\tab\tab jge  if\cf0\par
\cf2\tab\tab\tab sub.w #0x30,R10 \cf0\par
\par
\cf2\tab\tab\tab\cf1 ;section compares the second hex number is between '0'-'9'\cf0\par
\cf2 if\tab\tab\tab cmp.w R11, R9 \cf1 ;\cf0\par
\cf2\tab\tab\tab jge else\cf0\par
\cf2\tab\tab\tab cmp.w #0x3A, R11\cf0\par
\cf2\tab\tab\tab jge else\cf0\par
\cf2\tab\tab\tab sub.w #0x30,R11\cf0\par
\cf2\tab\tab\tab jmp continue \cf1 ; subtract 0x30\cf0\par
\cf2\tab\tab\tab\cf0\par
\cf2\tab\tab\tab\cf1 ;section compares the second hex number is between 'A'-'F'\cf0\par
\cf2 else\tab\tab mov.w #0x40, R9\cf0\par
\cf2\tab\tab\tab cmp.w R11,R9\cf0\par
\cf2\tab\tab\tab jge continue\cf0\par
\cf2\tab\tab\tab cmp.w #0x47, R11\cf0\par
\cf2\tab\tab\tab jge continue\cf0\par
\cf2\tab\tab\tab sub.w #0x37,R11 \cf1 ; subtract 0x37\cf0\par
\par
\cf1 ;shift first processed hex number to the left by 4 bits\cf0\par
\cf2 continue\tab rla.w R10\cf0\par
\cf2\tab\tab\tab rla.w R10\cf0\par
\cf2\tab\tab\tab rla.w R10\cf0\par
\cf2\tab\tab\tab rla.w R10\cf0\par
\cf2\tab\tab\tab add.w R10, R11\cf1 ;add both processed hex numbers together to get result\cf0\par
\par
\cf2\tab\tab\tab mov.w R11,R4 \cf1 ;move result to register 4\cf0\par
\cf2\tab\tab\tab call #OUTA_UART\cf1 ;print result\cf0\par
\cf2\tab\tab\tab\cf1 ;print new line\cf0\par
\cf2\tab\tab\tab mov.w #0x0A, R4\cf0\par
\cf2\tab\tab\tab call #OUTA_UART\cf0\par
\par
\cf2\tab\tab\tab mov.w #0x0D, R4\cf0\par
\cf2\tab\tab\tab call #OUTA_UART\cf0\par
\par
\cf2\tab\tab\tab jmp Mainloop\cf0\par
\par
\par
\par
\par
\par
\par
\par
\cf1 ;Mainloop \tab xor.b #02h,&P2OUT ; Toggle P2.2\cf0\par
\cf1 ;Wait \tab\tab mov.w #0A000h,R15 ; Delay to R15\cf0\par
\cf1 ;L1 \tab\tab\tab dec.w R15 ; Decrement R15\cf0\par
\cf1 ;\tab\tab\tab jnz L1 ; Delay over?\cf0\par
\cf1 ; go print a character to the screen from the keyboard\cf0\par
\cf1 ;\tab\tab\tab call #INCHAR_UART\cf0\par
\cf1 ;\tab\tab\tab call #OUTA_UART\cf0\par
\cf1 ;\tab\tab\tab jmp Mainloop ; Again\cf0\par
\cf1 ;\cf0\par
\cf2 OUTA_UART\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ; prints to the screen the ASCII value stored in register 4 and\cf0\par
\cf1 ; uses register 5 as a temp value\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ; IFG2 register (1) = 1 transmit buffer is empty,\cf0\par
\cf1 ; UCA0TXBUF 8 bit transmit buffer\cf0\par
\cf1 ; wait for the transmit buffer to be empty before sending the\cf0\par
\cf1 ; data out\cf0\par
\cf2\tab\tab\tab push R5\cf0\par
\cf2 lpa \tab\tab mov.b &IFG2,R5\cf0\par
\cf2\tab\tab\tab and.b #0x02,R5\cf0\par
\cf2\tab\tab\tab cmp.b #0x00,R5\cf0\par
\cf2\tab\tab\tab jz lpa\cf0\par
\cf1 ; send the data to the transmit buffer UCA0TXBUF = A;\cf0\par
\cf2\tab\tab\tab mov.b R4,&UCA0TXBUF\cf0\par
\cf2\tab\tab\tab pop R5\cf0\par
\cf2\tab\tab\tab ret\cf0\par
\cf2 INCHAR_UART\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ; returns the ASCII value in register 4\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ; IFG2 register (0) = 1 receive buffer is full,\cf0\par
\cf1 ; UCA0RXBUF 8 bit receive buffer\cf0\par
\cf1 ; wait for the receive buffer is full before getting the data\cf0\par
\cf2\tab\tab\tab push R5\cf0\par
\cf2 lpb \tab\tab mov.b &IFG2,R5\cf0\par
\cf2\tab\tab\tab and.b #0x01,R5\cf0\par
\cf2\tab\tab\tab cmp.b #0x00,R5\cf0\par
\cf2\tab\tab\tab jz lpb\cf0\par
\cf2\tab\tab\tab mov.b &UCA0RXBUF,R4\cf0\par
\cf2\tab\tab\tab pop R5\cf0\par
\cf1 ; go get the char from the receive buffer\cf0\par
\cf2\tab\tab\tab ret\cf0\par
\cf2 Init_UART\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ; Initialization code to set up the uart on the experimenter board to 8 data,\cf0\par
\cf1 ; 1 stop, no parity, and 9600 baud, polling operation\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\par
\cf1 ;P2SEL=0x30;\cf0\par
\cf1 ; transmit and receive to port 2 b its 4 and 5\cf0\par
\cf2\tab\tab\tab mov.b #0x30,&P2SEL\cf0\par
\cf1 ; Bits p2.4 transmit and p2.5 receive UCA0CTL0=0\cf0\par
\cf1 ; 8 data, no parity 1 stop, uart, async\cf0\par
\cf2\tab\tab\tab mov.b #0x00,&UCA0CTL0\cf0\par
\cf1 ; (7)=1 (parity), (6)=1 Even, (5)= 0 lsb first,\cf0\par
\cf1 ; (4)= 0 8 data / 1 7 data, (3) 0 1 stop 1 / 2 stop, (2-1) --\cf0\par
\cf1 ; UART mode, (0) 0 = async\cf0\par
\cf1 ; UCA0CTL1= 0x41;\cf0\par
\cf2\tab\tab\tab mov.b #0x41,&UCA0CTL1\cf0\par
\cf1 ; select ALK 32768 and put in software reset the UART\cf0\par
\cf1 ; (7-6) 00 UCLK, 01 ACLK (32768 hz), 10 SMCLK, 11 SMCLK\cf0\par
\cf1 ; (0) = 1 reset\cf0\par
\cf1 ;UCA0BR1=0;\cf0\par
\cf1 ; upper byte of divider clock word\cf0\par
\cf2\tab\tab\tab mov.b #0x00,&UCA0BR1\cf0\par
\cf1 ;UCA0BR0=3; ;\cf0\par
\cf1 ; clock divide from a clock to bit clock 32768/9600 = 3.413\cf0\par
\cf2\tab\tab\tab mov.b #0x03,&UCA0BR0\cf0\par
\cf1 ; UCA0BR1:UCA0BR0 two 8 bit reg to from 16 bit clock divider\cf0\par
\cf1 ; for the baud rate\cf0\par
\cf1 ;UCA0MCTL=0x06;\cf0\par
\cf1 ; low frequency mode module 3 modulation pater used for the bit\cf0\par
\cf1 ; clock\cf0\par
\cf2\tab\tab\tab mov.b #0x06,&UCA0MCTL\cf0\par
\cf1 ;UCA0STAT=0;\cf0\par
\cf1 ; do not loop the transmitter back to the receiver for echoing\cf0\par
\cf2\tab\tab\tab mov.b #0x00,&UCA0STAT\cf0\par
\cf1 ; (7) = 1 echo back trans to rec\cf0\par
\cf1 ; (6) = 1 framing, (5) = 1 overrun, (4) =1 Parity, (3) = 1 break\cf0\par
\cf1 ; (0) = 2 transmitting or receiving data\cf0\par
\cf1 ;UCA0CTL1=0x40;\cf0\par
\cf1 ; take UART out of reset\cf0\par
\cf2\tab\tab\tab mov.b #0x40,&UCA0CTL1\cf0\par
\cf1 ;IE2=0;\cf0\par
\cf1 ; turn transmit interrupts off\cf0\par
\cf2\tab\tab\tab mov.b #0x00,&IE2\cf0\par
\cf1 ; (0) = 1 receiver buffer Interrupts enabled\cf0\par
\cf1 ; (1) = 1 transmit buffer Interrupts enabled\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ;****************************************************************\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ; IFG2 register (0) = 1 receiver buffer is full, UCA0RXIFG\cf0\par
\cf1 ; IFG2 register (1) = 1 transmit buffer is empty, UCA0RXIFG\cf0\par
\cf1 ; UCA0RXBUF 8 bit receiver buffer, UCA0TXBUF 8 bit transmit\cf0\par
\cf1 ; buffer\cf0\par
\cf2\tab\tab\tab ret\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf1 ; Interrupt Vectors\cf0\par
\cf1 ;----------------------------------------------------------------\cf0\par
\cf2\tab\tab\tab .sect \cf3 ".reset"\cf2  \cf1 ; MSP430 RESET Vector\cf0\par
\cf2\tab\tab\tab\cf4\b .short\cf2\b0  START \cf1 ;\cf0\par
\f1\fs22\par
}
 