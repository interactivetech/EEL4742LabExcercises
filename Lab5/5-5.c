//---------------------------------------------------------------------
// LCD Driver for the for MSP 430X4XXX experimenter board using
// Softbaugh LCD
// Davies book pg. 259, 260
//---------------------------------------------------------------------

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
volatile unsigned char d;
volatile unsigned int i, j[20], x[5], temp[3]; // volatile to prevent optimization
volatile unsigned int a, b, c, e;

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



for (;;){

//letter input 1
				a=INCHAR_UART();
				OUTA_UART(a);

//Check if it's a digit or a character and transform to binary
				if((a>=0x30) && (a<=0x39)){
					a = a-0x30;
				}
				else{
					a = a-0x37;
				}

//letter input 2
				b=INCHAR_UART();
				OUTA_UART(b);


//Check if it's a digit or a character and transform to binary
				if((b>=0x30) && (b<=0x39)){
					b = b-0x30;
				}
				else{
					b = b-0x37;
				}


//Multiply a by 16 because of Hex, add together to obtain final number
				temp[1] = (a*16)+(b);
	
				d=INCHAR_UART();
				OUTA_UART(d);

//letter input 3
				a=INCHAR_UART();
				OUTA_UART(a);
//letter input 4
				b=INCHAR_UART();
				OUTA_UART(b);
				OUTA_UART(0x3D);


//Repeat procedure for the next two characters
				if((a>=0x30) && (a<=0x39)){
					a = a-0x30;
					}
				else{
					a = a-0x37;
				}

				if((b>=0x30) && (b<=0x39)){
					b = b-0x30;
				}
				else{
					b = b-0x37;
				}


//Multiply a by 16 because of Hex, add together to obtain final number
				temp[2] = (a*16)+(b);

//Addition
if(d=='+'){
	e = temp[1]+temp[2];
	LCDSeg[4]=0x00;
}

//Subtraction
else if(d=='-'){
//If the first number is bigger simply subtract
	if(temp[1]==temp[2]){
		e = 0;
		LCDSeg[4]=0x00;
}
	else if(temp[1]>temp[2]){
		e = temp[1]-temp[2];
		LCDSeg[4]=0x00; //reset LCD
	}

//If second number is bigger, invert numbers and add (-) before answer
	else{
		e=temp[2]-temp[1];
		OUTA_UART(0X2D);
		LCDSeg[4]=0x20;
	}
}

else{
//Multiply
				e = temp[1]*temp[2];
}

//The next few steps will be used to display our output
				x[4] = e/4096;
				temp[0]=e%4096;

				x[3]=temp[0]/256;
				temp[0]=temp[0]%256;

				x[2]=temp[0]/16;
				temp[0]=temp[0]%16;

				x[1]= temp[0];

//Print on LCD
				LCDSeg[3] = j[x[4]];
				LCDSeg[2] = j[x[3]];
				LCDSeg[1] = j[x[2]];
				LCDSeg[0] = j[x[1]];

//Convert our decimal characters back to ascii
				if(x[4]<=9)
					x[4]=x[4] + 0x30;
				else
					x[4]=x[4] + 0x37;

				if(x[3]<=9)
					x[3]=x[3] + 0x30;
				else
					x[3]=x[3] + 0x37;

				if(x[2]<=9)
					x[2]=x[2] + 0x30;
				else
					x[2]=x[2] + 0x37;

				if(x[1]<=9)
					x[1]=x[1] + 0x30;
				else
					x[1]=x[1] + 0x37;


//print the characters onto the Hyperterminal
				OUTA_UART(x[4]);
				OUTA_UART(x[3]);
				OUTA_UART(x[2]);
				OUTA_UART(x[1]);
//Print New line
				OUTA_UART(0X0A);
				OUTA_UART(0X0D);


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
