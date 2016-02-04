//C Program Lab 2 : Part 3
//---------------------------------------------------------------
// Console I/O through the on board UART for MSP 430X4XXX
//---------------------------------------------------------------
void Init_UART(void);
void OUTA_UART(unsigned char A);
void send(char* str);			//send method declared
unsigned char INCHAR_UART(void);

#include "msp430fg4618.h"
#include "stdio.h"

int main(void){
    volatile unsigned char a[100]="Laboratory #2 for EEL4742 Embedded Systems0";//string to print
    volatile unsigned char b;
    volatile unsigned int i=0; // index of string
    WDTCTL = WDTPW + WDTHOLD; // Stop watchdog timer
    Init_UART();
    while(i>=0){//loop until entire string is printed
        b=a[i];//temp variable to hold character
        
        if(a[i]=='0'){//if null character is found, break loop
            break;//break statement
        }
        OUTA_UART(b);//display character in hyperterminal
        i++;//increment index
    }
    // go blink the light to indicate code is running
    P2DIR |= 0x02; // Set P1.0 to output direction
    // Use The LED as an indicator
    for (;;){
        P2OUT ^= 0x02; // Toggle P1.0 using exclusive-OR
        i = 10000; // SW Delay
        do i--;
        while (i != 0);
    }
}


//rest of code unmodified

void OUTA_UART(unsigned char A){
//---------------------------------------------------------------
//***************************************************************
//---------------------------------------------------------------
// IFG2 register (1) = 1 transmit buffer is empty,
// UCA0TXBUF 8 bit transmit buffer
// wait for the transmit buffer to be empty before sending the
// data out
do{
  }while ((IFG2&0x02)==0);
// send the data to the transmit buffer
UCA0TXBUF =A;
}


void Init_UART(void){
//---------------------------------------------------------------
// Initialization code to set up the uart on the experimenter
// board to 8 data,
// 1 stop, no parity, and 9600 baud, polling operation
//---------------------------------------------------------------
P2SEL=0x30; // transmit and receive to port 2 b its 4 and 5

UCA0CTL0=0; // 8 data, no parity 1 stop, uart, async

UCA0CTL1= 0x41;

UCA0BR1=0; // upper byte of divider clock word
UCA0BR0=3; // clock divide from a clock to bit clock 32768/9600

UCA0MCTL=0x06;

UCA0STAT=0; // do not loop the transmitter back to the

UCA0CTL1=0x40;

IE2=0; // turn transmit interrupts off
}