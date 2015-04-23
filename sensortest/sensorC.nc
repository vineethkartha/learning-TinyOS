#include<Timer.h>
#include<math.h>
#include"printf.h"

module sensorC
{
	uses
	{
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as T0;
		interface Read<uint16_t> as Temp;
		interface Read<uint16_t> as Hum;
		interface Read<uint16_t> as IR;
		interface Read<uint16_t> as VIS;
	}
}

implementation
{
	event void Boot.booted()
	{
		call T0.startPeriodic(1000);
	} 
	
	event void T0.fired()
	{
		call Temp.read();
		call Hum.read();
		call IR.read();
		call VIS.read();
	}
	
	event void Temp.readDone(error_t result, uint16_t data)
	{
		if(result==SUCCESS)
		{
			printf("--------------------------------------------------------\n");
			data=data*0.01-39.6;
			printf("The temperature is: %u\n",data);
		}
	}

	event void Hum.readDone(error_t result, uint16_t data)
	{
		if(result==SUCCESS)
		{
			data=-4+0.0405*data +(-2.8/1000000)*(data*data);
			printf("The humidity is: %u\n",data);
		}
	}

	event void IR.readDone(error_t result, uint16_t data)
	{
		if(result==SUCCESS)
		{
			/*data=data/4096 *1.5;
			data=data/100000;
			data=0.796*1000000*data*1000;*/	
			if(data<50)
			{
				call Leds.led1On();
			}
			else
			{
				call Leds.led1Off();
			}
			printf("The IR level is: %u\n",data);
		}
	}

	event void VIS.readDone(error_t result, uint16_t data)
	{
		if(result==SUCCESS)
		{
			/*data=data/4096 *1.5;
			data=data/100000;
			data=0.796*1000000*data*1000;*/
			printf("The visible light level is: %u\n",data);
			printfflush();
		}
	}
}