#define NEW_PRINTF_SEMANTICS
#include"printf.h"

configuration clockAppC
{
}

implementation
{
	components clockC;
	components MainC;
	components LedsC;
	components new TimerMilliC() as clk;
	//components new Msp430TimerC() as T0;
	components PrintfC;
	components SerialStartC;

	clockC.Boot ->MainC;
	clockC.Leds ->LedsC;
	clockC.sec ->sec;
	clockC.min ->min;
	clockC.Hour ->hr;
	//clockC.T0 ->T0;
}
