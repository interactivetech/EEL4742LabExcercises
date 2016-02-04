#include "msp430fg4618.h"
#include "stdio.h"
void Init_LCD(void);

unsigned char *LCDSeg = (unsigned char *) &LCDM3;

int LCD_SIZE=11;
int main(void){
	volatile unsigned int digits[10];
	volatile unsigned int i; // volatile to prevent optimization
	volatile unsigned int y; // volatile to prevent optimization
	volatile unsigned int x; // volatile to prevent optimization
	volatile unsigned int z; // volatile to prevent optimization

	WDTCTL = WDTPW + WDTHOLD; // Stop watchdog timer
	Init_LCD();

	digits[0]=0x5F;
	digits[1]=0x06;
	digits[2]=0x6B;
	digits[3]=0x2F;
	digits[4]=0x36;
	digits[5]=0x3D;
	digits[6]=0x7D;
	digits[7]=0x07;
	digits[8]=0x7F;
	digits[9]=0x37;

	P1DIR &= 0x00;	//sets directions of sw1 and sw2 to input



	//y is the global counter that counts from 0 to 999
	//since in every iteration the y counter is updated unconditionally.
	//It is set to -1 at the beginning of the program so at the end of each iteration
	//y points to the actual number been display in the LCD screen
	y=0;

	//x is the counter keeping track of the tenth numbers, it displays numbers
	//from 1-9 in the LCDSeg[1] position, if x==0, LCDSeg[1] is overwritten to 0x00
	//to clear the LCD display at that position
	x=0;

	//y is the counter keeping track of the hundredth numbers, it displays numbers
	//from 1-9 in the LCDSeg[2] position, if z==0, LCDSeg[2] is overwritten to 0x00
	//to clear the LCD display at that position
	z=0;



	//it displays the first numbers of digits which is 0
	LCDSeg[0]=digits[0];



	for (;;){
		// Conditional statement that checks if the SW1 button
		// is being pressed
		if((P1IN & 0x01) == 0){
			//if SW1 is pressed, increase y by 1
			y++;
			if(y==1000){
			//if y==1000, the display went from 999 to 0, it overwrites x,z, and y
			//and it displays the number 0 in the LCD display right most segment
				x=0;
				z=0;
				y=0;
				LCDSeg[2]=0x00;
				LCDSeg[1]=0x00;
				LCDSeg[0]=digits[0];
			}
			else{
				//both if statements check to see if y!=0
				//that is because 0%100 or 0%10 are equal to 0 which will execute the code in each if statement
				//when y==0 is not allow to enter the if statements

				if(y%100==0 && y!=0){
				//if y%100==0 it means it went from 99 to 100 or 199 to 200 or 299 to 300...899 to 900
				//in that case, the z counter needs to increase by one and it needs to be updated
				//in the LCD screen
					z++;					//updating the z counter by 1
					LCDSeg[2]=digits[z];	//updating the LCD display
				}



				if(y%10==0 && y!=0){
				//if y%100==0 it means it went from 99 to 100 or 199 to 200 or 299 to 300...899 to 900
				//in that case, the z counter needs to increase by one and it needs to be updated
				//in the LCD screen
					x++;					//updating the x counter by 1
					LCDSeg[1]=digits[x%10];	//updating the LCD display
				}
				LCDSeg[0]=digits[y%10];		//updates the LCD display of the right most LCD segment
			}
		}

		// Conditional statement that checks if the SW2 button
		// is being pressed
		if ((P1IN & 0x02) == 0){
			//if SW2 is pressed, decrease y by 1
			y--;
			if(y==-1){
			//if y==-1, the display should went from 0 to 999, it overwrites x,z, and y counters
			//and it displays the number 999 in the LCD display
			//updates x,z, and y counters to point to the number 999
				x=99;
				z=9;
				y=999;
				//updates the display to show 999 in the LCD display
				LCDSeg[2]=digits[9];
				LCDSeg[1]=digits[9];
				LCDSeg[0]=digits[9];
			}
			else{
				LCDSeg[0]=digits[y%10];		//updates the LCD display of the right most LCD segment
				if(y%10==9 && y!=0){
				//if y%10==9, it means the display went from 10 to 9 or 20 to 19 or 30 to 29 ... or 100 to 99
				//in that case, the x counter needs to decrease by 1
					x--;			//decreasing x counter by 1
					//if x and z counters are 0, the number went from 10 to 9 and the LCDSeg[1] needs to be clear in the LCD display
					if(x==0 && z==0)
						LCDSeg[1]=0x00;	//clearing LCDSeg[1]
					//else, just displays the updated number to the LCD display
					else
						LCDSeg[1]=digits[x%10];

				}
				if(y%100==99 && y!=0){
				//if y%100==99, it means the display went from 100 to 99 or 200 to 199 or 300 to 299 ... or 900 to 899
				//in that case, the z counter needs to decrease by 1
					z--;			//decreasing z counter by 1
					//if z==0, the number went from 100 to 99 and LCDSeg[2] needs to be clear in the LCD display
					if (z==0)
						LCDSeg[2]=0x00;	//clearing LCDSeg[2]
					//else, just displays the updated number to the LCD display
					else
						LCDSeg[2]=digits[z];
				}
			}
		}
		//delays each iteration so the numbers can change at a pace
		//the human eye can see
		i = 30000; // SW Delay
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
