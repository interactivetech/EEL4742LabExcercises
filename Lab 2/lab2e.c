//C Program Lab 2 : Part 5
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
    
    
    volatile unsigned char a[40]=" SW1=1,SW2=0 P"; // string that displays first case
    volatile unsigned char b[40]=" SW1=0, SW2=1 P"; // string that displays second case
    volatile unsigned char c[40]=" SW1=1, SW2=1 P ";// string that displays third case
    
    
    volatile unsigned int i=0; // volatile to prevent optimization
    
    P2DIR |= 0x06; // Set P2.0 to output direction, which are the LEDs
    P1DIR |= 0x00; // Set P1.0 to output direction, which are the buttons
    WDTCTL = WDTPW + WDTHOLD; // Stop watchdog timer
    
    Init_UART();//initalize MSP430 UART comm
    //int i;
    int state=0;//initalize variable to be checking different button states
    
    
    P2OUT=0x00;//initalize LED's to be off
    for(;;){
        
        //a= INCHAR_UART();
        
        if(P1IN==0x01 && state !=1){//check condition when button two is down
            i=0;
            while(b[i]!='P'){//print string of first case, end when found "P" to terminate loop
                OUTA_UART(b[i]);
                
                
                i++;//increment string index
            }
            OUTA_UART(0x0A);//send newline character to hyperterminal
            OUTA_UART(0x0D);//send carriage return character to hyperterminal
            state=1;
        }
        
        else if(P1IN==0x02 && state !=2){// check condition when button one is down
            i=0;
            while(a[i]!='P'){//print string of second case, end when found "P" to terminate loop
                OUTA_UART(a[i]);
                
                i++;//increment index
            }
            OUTA_UART(0x0A);//send newline character to hyperterminal
            OUTA_UART(0x0D);//send carriage return character to hyperterminal
            state=2;
        }
        else if(P1IN==0x00 && state!=3){//check condition when both buttons are down
            i=0;
            while(c[i]!='P'){//print string of third case, end when found "P" to terminate loop
                OUTA_UART(c[i]);
                i++;//increment index
            }
            OUTA_UART(0x0A);//send newline character to hyperterminal
            OUTA_UART(0x0D);//send carriage return character to hyperterminal
            state=3;
        }
        
        else//none of the buttons are being pressed
            state=5;
        
        
        
        
        
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