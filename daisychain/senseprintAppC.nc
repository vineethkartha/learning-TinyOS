#define NEW_PRINTF_SEMANTICS
#include"printf.h"

configuration senseprintAppC
{
}

implementation{
	components senseprintC;
	components MainC;
	components LedsC;
	components new TimerMilliC();
	components PrintfC; 	
	components SerialStartC;
	components new SensirionSht11C() as Sensor;

	senseprintC.Boot->MainC;
	senseprintC.Leds->LedsC;
	senseprintC.Timer->TimerMilliC;
	senseprintC.Read->Sensor.Temperature;
}
