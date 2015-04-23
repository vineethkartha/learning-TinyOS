#include<Timer.h>
#include"printf.h"

module clockC
{
	uses
	{
		interface Boot;
		interface Timer<TMilli> as clk;
		//interface Msp430Timer as T0;
		interface Leds;
	}
}
implementation
{
	uint16_t secs=0;
	uint16_t mins=0;
	uint16_t hrs=0;
	
	event void Boot.booted()
	{
		call clk.startPeriodic(1000);
	}
	event void clk.fired()
	{
		secs++;
		if(secs>59)
		{
			secs=0;
			mins++;
			if(mins>59)
			{
				mins=0;
				hrs++;
			}
		}
		printf("%u:%u:%u\n",hrs,mins,secs);
		printfflush();	
	}

}
