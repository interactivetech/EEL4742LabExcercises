//C Program Lab 2 : Part 4
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
    
    volatile unsigned char a; // variable to store input
    volatile unsigned int i=0; // volatile to prevent optimization
    //int on=0;
    //int on2=0;
    //P2OUT=0x04;
    
    P2DIR |= 0x06; // Set P1.0 to output direction
    WDTCTL = WDTPW + WDTHOLD; // Stop watchdog timer
    Init_UART();//initalize MSP430 UART serial comm
    
    P2OUT=0x00;
    
    for(;;){//loop continuously
        a= INCHAR_UART();//read input character from keyboard
        
        if(a=='G')//if character is G, then select the green LED
            P2OUT = P2OUT ^ 0X04;//toggle value of light: if off, then on and vice versa
        
        if(a=='Y')//if character is Y, then select the yellow LED
            P2OUT = P2OUT ^ 0X02;//toggle value of light: if off, then on and vice versa
        
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