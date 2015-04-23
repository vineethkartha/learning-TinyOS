#include<Timer.h>
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration task1AppC
{
}
implementation
{
components MainC;
components LedsC;
components task1C as App;
components new TimerMilliC() as Timer0;
components ActiveMessageC;
components new AMSenderC(5);
components new AMReceiverC(5);
  components PrintfC;
  components SerialStartC;
  components CC2420ActiveMessageC;

App.Boot ->MainC;
App.Leds -> LedsC;
App.Timer0 ->Timer0;
App.Packet -> AMSenderC;
App.AMPacket -> AMSenderC;
App.AMSend -> AMSenderC;
App.AMControl -> ActiveMessageC;
App.Receive -> AMReceiverC;
 App -> CC2420ActiveMessageC.CC2420Packet;
}
