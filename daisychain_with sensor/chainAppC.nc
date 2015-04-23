#define NEW_PRINTF_SEMANTICS

#include<Timer.h>
#include"printf.h"

configuration chainAppC
{ }

implementation
{
	components MainC;
	components LedsC;
	components chainC as App; //my program
	
	//For serial communication
	components PrintfC;
	components SerialStartC;
	
	components new DemoSensorC() as Sensor;
	
	components new TimerMilliC() as Timer0;
	
	//For Communication
	components ActiveMessageC;
	components new AMSenderC(6);
	components new AMReceiverC(6);

	App.Boot        ->MainC;
	App.Leds        ->LedsC;
	App.Timer0      ->Timer0;
	App.Packet      ->AMSenderC;
	App.AMPacket    ->AMSenderC;
	App.AMSend      ->AMSenderC;
	App.AMControl   ->ActiveMessageC;
	App.Receive     ->AMReceiverC;
	App.Read ->Sensor;
}
