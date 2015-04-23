#include<Timer.h>

configuration task2AppC
{
}
implementation
{
components MainC;
components LedsC;
components task2C as App;
components new TimerMilliC() as Timer0;
components new TimerMilliC() as Timer1;
components new TimerMilliC() as Timer2;
components ActiveMessageC;
components new AMSenderC(2);
components new AMReceiverC(2);

App.Boot ->MainC;
App.Leds -> LedsC;
App.Timer0 ->Timer0;
App.Timer1 ->Timer1;
App.Timer2 ->Timer2;
App.Packet -> AMSenderC;
App.AMPacket -> AMSenderC;
App.AMSend -> AMSenderC;
App.AMControl -> ActiveMessageC;
App.Receive -> AMReceiverC;
}
