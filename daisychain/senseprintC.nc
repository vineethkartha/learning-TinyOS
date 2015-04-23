#include "Timer.h"
#include "printf.h"

module senseprintC
{
  uses{
  interface Boot;
  interface Leds;
  interface Timer<TMilli>;
  interface Read<uint16_t>;
}
}

implementation
{
	event void Boot.booted()
	{
		call Timer.startPeriodic(1000);
	}
	
	event void Timer.fired()
	{
		printf("Hi I am Reading\n");	
		printfflush();
		call Read.read();
	}

	event void Read.readDone(error_t result, uint16_t data)
	{
		if(result==SUCCESS)
		{
			data*=0.01;
			data=data-39.6;
			printf("Hi the data is %u\n",data);
			
		}
	}
}
