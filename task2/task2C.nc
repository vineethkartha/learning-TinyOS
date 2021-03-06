#include<Timer.h>
#define TX 3
#define RX 4
#define fin 5

typedef nx_struct message
{
nx_uint16_t nodeid;
nx_uint16_t counter;
} message;


module task2C
{
uses interface Boot;
uses interface Leds;
uses interface Timer<TMilli> as Timer0;
uses interface Timer<TMilli> as Timer1;
uses interface Timer<TMilli> as Timer2;
uses interface Packet;
uses interface AMPacket;
uses interface AMSend;
uses interface SplitControl as AMControl;
uses interface Receive;
}

implementation 
{
bool tbusy = FALSE;
bool rbusy=FALSE;
message_t tpkt,rpkt;

uint16_t counter=1;
uint16_t value=0;

event void Boot.booted()
{
	call AMControl.start();
}

event void Timer1.fired()
{
	if(TOS_NODE_ID==RX)
	{
	if(!rbusy)
	{
		message *btrpkt =(message*)(call Packet.getPayload(&rpkt,sizeof(message)));
		btrpkt ->nodeid =TOS_NODE_ID;
		btrpkt ->counter=value+1;
		if (call AMSend.send(fin, &rpkt, sizeof(message)) == SUCCESS) 
		{
		      rbusy = TRUE;
    		}
	}
	}
}

event void Timer0.fired()
{
	if(TOS_NODE_ID==TX)
	{
	if(!tbusy)
	{
		message *btrpkt =(message*)(call Packet.getPayload(&tpkt,sizeof(message)));
		btrpkt ->nodeid =TOS_NODE_ID;
		btrpkt ->counter=counter;
		if (call AMSend.send(RX, &tpkt, sizeof(message)) == SUCCESS) 
		{
		      tbusy = TRUE;
    		}
	}
	counter ++;
	//call Leds.set(btrpkt->counter);
	}
}

event void Timer2.fired()
{
	if(TOS_NODE_ID==fin)
	{
	if(!tbusy)
	{
		message *btrpkt =(message*)(call Packet.getPayload(&tpkt,sizeof(message)));
		btrpkt ->nodeid =TOS_NODE_ID;
		btrpkt ->counter=counter;
		if (call AMSend.send(TX, &tpkt, sizeof(message)) == SUCCESS) 
		{
		      tbusy = TRUE;
    		}
	}
	counter ++;
	//call Leds.set(btrpkt->counter);
	}
}

event void AMControl.startDone(error_t err)
{
	if(err==SUCCESS)
	{	
		call Timer0.startPeriodic(1000);
		call Timer1.startPeriodic(1200);
		call Timer2.startPeriodic(1500);
	}
	else
	{	
		call AMControl.start();
	}
}

event void AMControl.stopDone(error_t err) { }
event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&tpkt == msg) {
      tbusy = FALSE;
    }
    if (&rpkt == msg) {
      rbusy = FALSE;
    }
  }

event message_t* Receive.receive(message_t* msg, void* payload,uint8_t len)
{
	
	if(TOS_NODE_ID==TX)
	{
		if(len==sizeof(message))
		{
			message* btrpkt =(message*)payload;
			if(btrpkt->nodeid==fin)
			{
				//value=btrpkt->counter;
				call Leds.set(btrpkt->counter);
			}
		}
		return msg;
	}
	if(TOS_NODE_ID==fin)
	{
		if(len==sizeof(message))
		{
			message* btrpkt =(message*)payload;
			if(btrpkt->nodeid==RX)
			{
				//value=btrpkt->counter;
				call Leds.set(btrpkt->counter);
			}
		}
		return msg;
	}
	
	if(TOS_NODE_ID==RX)
	{
		if(len==sizeof(message))
		{
			message* btrpkt =(message*)payload;
			if(btrpkt->nodeid==TX)
			{
				value=btrpkt->counter;
				call Leds.set(btrpkt->counter);
			}
		}
	return msg;
	}

}

}
