
void Init_UART(void);
void OUTA_UART(unsigned char A);
void OUTA_UART_2(unsigned char A,unsigned char B);
void OUTA_UART_string(char B[]);
unsigned char INCHAR_UART(void);
unsigned char INCHAR_UART_2(void);


#include "msp430fg4618.h"
#include "stdio.h"
#include "string.h"
#include <ctype.h>
void Init_LCD(void);

unsigned char *LCDSeg = (unsigned char *) &LCDM3;

int LCD_SIZE=11;
int main(void){
volatile unsigned char a, b;
volatile unsigned int i, j[20], x; // volatile to prevent optimization

WDTCTL = WDTPW + WDTHOLD; // Stop watchdog timer

P2DIR |= 0x02; // Set P1.0 to output direction

Init_UART();
Init_LCD();

j[0] = 0x5F;
j[1] = 0X06;
j[2] = 0X6B;
j[3] = 0X2F;
j[4] = 0X36;
j[5] = 0X3D;
j[6] = 0X7D;
j[7] = 0X07;
j[8] = 0X7F;
j[9] = 0X37;
j[10] = 0X77;
j[11] = 0X7C;
j[12] = 0X68;
j[13] = 0X6E;
j[14] = 0X79;
j[15] = 0X71;


//Run indefinitely
for (;;){

				//letter input 1
				a=INCHAR_UART();
				OUTA_UART(a);

				//Check if input is digit or character and print
				//onto the board's LCD screen
				if(isdigit(a)){
					a = a - 0x30;
					LCDSeg[1]=j[a];
				}
				else{
					a = a - 0x37;
					LCDSeg[1]= j[a];
				}
				//letter input 2
				b=INCHAR_UART();
				OUTA_UART(b);
				
				//Repeat procedure followed for input a
				if(isdigit(b)){
					b = b - 0x30;
					LCDSeg[0]=j[b];
				}
				else{
					b = b - 0x37;
					LCDSeg[0]= j[b];
				}

				Print New line
				OUTA_UART(0X0A);
				OUTA_UART(0X0D);

				
P2OUT ^= 0x02; // Toggle P1.0 using exclusive-OR
i = 10000; // SW Delay
do i--;
while (i != 0);
}
}

void Init_LCD(void){

int n;
for (n=0;n<LCD_SIZE;n++){

*(LCDSeg+n) = 0;

}
P5SEL = 0x1C; // BIT4 | BIT3 |BIT2 = 1 P5.4, P.3, P5.2 = 1
LCDAVCTL0 = 0x00;
LCDAPCTL0 = 0x7E;
LCDACTL = 0x7d;
}

void OUTA_UART(unsigned char A){

		do{
		}while ((IFG2&0x02)==0);
		// send the data to the transmit buffer
		UCA0TXBUF = A;

}

unsigned char INCHAR_UART(void){
		do{
		}while ((IFG2&0x01)==0);
		return (UCA0RXBUF);
}
void Init_UART(void){
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

