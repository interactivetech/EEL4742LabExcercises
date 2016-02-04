//---------------------------------------------------------------
// Console I/O through the on board UART for MSP 430X4XXX
//---------------------------------------------------------------
void Init_UART(void);
void OUTA_UART_single(char A);
void OUTA_UART_1(char chars[], int N);
unsigned char INCHAR_UART(void);
#include "msp430fg4618.h"
#include "stdio.h"
#include "string.h"
#include <ctype.h>
int main(void){
		volatile unsigned char a,b;
		volatile unsigned int i; // volatile to prevent optimization

		int x=1;

		WDTCTL = WDTPW + WDTHOLD; // Stop watchdog timer
		Init_UART();

		char chars[32];
		int q=0;

		while(x != 0){

			for(q=0;q<32;q++)
			{
				//get character
				chars[q]=INCHAR_UART();

				//output the character to screen
				OUTA_UART_single(chars[q]);

				//check if enter is pressed
				if(chars[q] == (char)(0x0D))
				{
					break;
				}

			}
//New Line
			OUTA_UART_single(0X0A);
			OUTA_UART_single(0X0D);

			//send character array and size of array
			OUTA_UART_1(chars, q);

			q=0;

		}

}


void OUTA_UART_1(char chars[], int n){
		do{
		}while ((IFG2&0x02)==0);
		// send the data to the transmit buffer

		//UCA0TXBUF = A;

		char temp;

		//sorting
		int i,j;
		for(i=0;i<n-1;i++){

			for(j=0;j<n-1;j++){

//Check if current character is bigger than next one				
if(chars[j]>chars[j+1])
				{
					temp = chars[j];
					chars[j] = chars[j+1];
					chars[j+1] = temp;
				}
			}
		}


		i=0;

		//Display output string
		for(i=0;i<n;i++){

			do{
			}while ((IFG2&0x02)==0);

			UCA0TXBUF = chars[i];

		}

		do{
			}while ((IFG2&0x02)==0);

			//new line
			UCA0TXBUF=0x0A;

		do{
			}while ((IFG2&0x02)==0);

			UCA0TXBUF=0x0D;
}

void OUTA_UART_single(char A){
		do{
		}while ((IFG2&0x02)==0);
		// send the data to the transmit buffer

		UCA0TXBUF = A;
}

unsigned char INCHAR_UART(void){
		//---------------------------------------------------------------
		//***************************************************************
		//---------------------------------------------------------------
		// IFG2 register (0) = 1 receive buffer is full,
		// UCA0RXBUF 8 bit receive buffer
		// wait for the receive buffer is full before getting the data
		do{
		}while ((IFG2&0x01)==0);
		// go get the char from the receive buffer
		return (UCA0RXBUF);
}

void Init_UART(void){
		//---------------------------------------------------------------
		// Initialization code to set up the uart on the experimenter
		// board to 8 data,
		// 1 stop, no parity, and 9600 baud, polling operation
		//---------------------------------------------------------------
		P2SEL=0x30; // transmit and receive to port 2 b its 4 and 5
		// Bits p2.4 transmit and p2.5 receive
		UCA0CTL0=0; // 8 data, no parity 1 stop, uart, async
		// (7)=1 (parity), (6)=1 Even, (5)= 0 lsb first,
		// (4)= 0 8 data / 1 7 data,
		// (3) 0 1 stop 1 / 2 stop, (2-1) -- UART mode,
		// (0) 0 = async
		UCA0CTL1= 0x41;
		// select ALK 32768 and put in
		// software reset the UART
		// (7-6) 00 UCLK, 01 ACLK (32768 hz), 10 SMCLK,
		// 11 SMCLK
		// (0) = 1 reset
		UCA0BR1=0; // upper byte of divider clock word
		UCA0BR0=3; // clock divide from a clock to bit clock 32768/9600
		// = 3.413
		// UCA0BR1:UCA0BR0 two 8 bit reg to from 16 bit
		// clock divider
		// for the baud rate
		UCA0MCTL=0x06;
		// low frequency mode module 3 modulation pater
		// used for the bit clock
		UCA0STAT=0; // do not loop the transmitter back to the
		// receiver for echoing
		// (7) = 1 echo back trans to rec
		// (6) = 1 framing, (5) = 1 overrun, (4) =1 Parity,
		// (3) = 1 break
		// (0) = 2 transmitting or receiving data
		UCA0CTL1=0x40;
		// take UART out of reset
		IE2=0; // turn transmit interrupts off
		//---------------------------------------------------------------
		//***************************************************************
		//---------------------------------------------------------------
		// IFG2 register (0) = 1 receiver buffer is full,
		// UCA0RXIFG
		// IFG2 register (1) = 1 transmit buffer is empty,
		// UCA0RXIFG
		// UCA0RXBUF 8 bit receiver buffer
		// UCA0TXBUF 8 bit transmit buffer
}
