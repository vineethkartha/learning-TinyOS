#define NEW_PRINTF_SEMANTICS
#include "printf.h"
configuration sensorAppC
{
}

implementation
{
	components sensorC,MainC,LedsC;
	components new TimerMilliC() as T0;
	components new SensirionSht11C() as temp;
	//components new SensirionSht11C() as humid;
	components new HamamatsuS1087ParC() as ir;
	components new HamamatsuS10871TsrC() as vis;
	components PrintfC;
	components SerialStartC;
	sensorC.Boot ->MainC;
	sensorC.Leds ->LedsC;
	sensorC.T0   ->T0;
	sensorC.Temp ->temp.Temperature;
	sensorC.Hum  ->temp.Humidity;
	sensorC.IR   ->ir;
	sensorC.VIS  ->vis;
	
}