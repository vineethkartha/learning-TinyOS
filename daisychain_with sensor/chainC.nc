#include<Timer.h>
#include "printf.h"

#define M1 3
#define M2 4
#define M3 5
#define M4 6

typedef nx_struct msg
{
	nx_uint16_t nodeid;
	nx_uint16_t data;
} message;

module chainC
{
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
	uses interface Read<uint16_t>;	
}

implementation
{
	message_t pkt,pkt2,pkt3;
	uint16_t value=0;
	bool busy_m1=TRUE;
	bool busy_m2=FALSE;
	bool busy_m3=FALSE;

	event void Boot.booted()
	{
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err)
	{
		if(err==SUCCESS)
		{
			call Timer0.startPeriodic(3000);
		}
		else
		{
			call AMControl.start();
		}
	}

	event void Timer0.fired()
	{

		if(TOS_NODE_ID==3)
		{
			call Read.read();		
		}
		
	}
	
	event void AMControl.stopDone(error_t err)
	{
	}
	
	event void AMSend.sendDone(message_t* msg,error_t err)
	{
		if(&pkt==msg &&busy_m1==TRUE)
		{
			busy_m1=FALSE;
		}
		if(&pkt2==msg&&busy_m2==TRUE)
		{
			busy_m2=FALSE;
		}
		if(&pkt3==msg&&busy_m3==TRUE)
		{
			busy_m3=FALSE;
		}
	} 
	event void Read.readDone(error_t result, uint16_t data)
	{
		if(result==SUCCESS)
		{
			data*=0.01;
			data-=39.6;
			value=data;
			busy_m1=FALSE;
			
		}
		if(TOS_NODE_ID==M1 && busy_m1==FALSE)
		{
			message* btrpkt=(message*)(call Packet.getPayload(&pkt,sizeof(message)));
			btrpkt ->nodeid=TOS_NODE_ID;
			btrpkt ->data=value;
			if(call AMSend.send(M2,&pkt,sizeof(message))==SUCCESS)
			{
				busy_m1=TRUE;
			}
		}
	}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
	{
		if(TOS_NODE_ID==M2)
		{
			printf("Hi this is mote 2\n");
			if(len==sizeof(message))
			{
				message* btrpkt=(message*)payload;
				if(btrpkt ->nodeid==M1)
				{
					call Leds.set(btrpkt->data);
					printf("Hi this is mote 2 and temperature is %u degC\n",btrpkt->data);
					value=btrpkt->data;
					printfflush();
				}
			}
			if(busy_m2==FALSE)
			{
				message* btrpkt=(message*)(call Packet.getPayload(&pkt2,sizeof(message)));
				printf("m2 in sending mode\n");
				printfflush();
				btrpkt ->nodeid=TOS_NODE_ID;
				btrpkt ->data=value;
				if(call AMSend.send(M3,&pkt2,sizeof(message))==SUCCESS)
				{
					busy_m2=TRUE;
				}
			}	
		}
		if(TOS_NODE_ID==M3)
		{
			printf("Hi this is mote 3\n");
			if(len==sizeof(message))
			{
				message* btrpkt=(message*)payload;
				if(btrpkt ->nodeid==M2)
				{
					call Leds.set(btrpkt->data);
					printf("Hi this is mote 3 and temperature is %u degC\n",btrpkt->data);
					value=btrpkt->data;
					printfflush();
				}
			}
			if(busy_m3==FALSE)
			{
				message* btrpkt=(message*)(call Packet.getPayload(&pkt3,sizeof(message)));
				printf("m3 in sending mode\n");
				printfflush();
				btrpkt ->nodeid=TOS_NODE_ID;
				btrpkt ->data=value;
				if(call AMSend.send(M4,&pkt3,sizeof(message))==SUCCESS)
				{
					busy_m3=TRUE;
				}
			}	
		}

		if(TOS_NODE_ID==M4)
		{
			printf("Hi this is mote 4\n");
			if(len==sizeof(message))
			{
				message* btrpkt=(message*)payload;
				if(btrpkt ->nodeid==M3)
				{
					call Leds.set(btrpkt->data);
					printf("Hi this is mote 4 and temperature is %u degC\n",btrpkt->data);
					printfflush();
				}
			}	
		}
		
		return msg;
	}
}
