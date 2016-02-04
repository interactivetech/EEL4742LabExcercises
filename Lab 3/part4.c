//---------------------------------------------------------------
// Console I/O through the on board UART for MSP 430X4XXX
//---------------------------------------------------------------
void Init_UART(void);
void OUTA_UART1(unsigned char A);
void OUTA_UART(unsigned char A, char binary[], int count);
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

		char binary[8];
		int j=0;

		while(x != 0){

			for(j=0;j<8;j++)
			{
				binary[j]=INCHAR_UART();
				//This function does the work
				OUTA_UART(binary[j], binary, j);
			}

			j=0;
			//New line
			OUTA_UART1(0X0A);
			OUTA_UART1(0X0D);


		}

}

void OUTA_UART1(unsigned char A){
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

		UCA0TXBUF = A;
}

void OUTA_UART(unsigned char A, char binary[], int count){
		do{
		}while ((IFG2&0x02)==0);
		// send the data to the transmit buffer

		UCA0TXBUF = A;

		if(count>=7){

			do{
			}while ((IFG2&0x02)==0);


			//calculations binary->decimal->hex
			int byte1_a = 8*(binary[0]-'0') + 4*(binary[1]-'0') + 2*(binary[2]-'0') + 1*(binary[3]-'0');
			int byte2_a = 8*(binary[4]-'0') + 4*(binary[5]-'0') + 2*(binary[6]-'0') + 1*(binary[7]-'0');

			char byte1, byte2;

			if(byte1_a <= 9)
				byte1 = (char)(byte1_a + 48);
			else
				byte1 = (char)(byte1_a + 55);

			if(byte2_a <= 9)
				byte2 = (char)(byte2_a + 48);
			else
				byte2 = (char)(byte2_a + 55);


			OUTA_UART1(0X0A);
			OUTA_UART1(0X0D);


			do{
			}while ((IFG2&0x02)==0);

			UCA0TXBUF = byte1;

			do{
			}while ((IFG2&0x02)==0);

			UCA0TXBUF = byte2;

			}

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
