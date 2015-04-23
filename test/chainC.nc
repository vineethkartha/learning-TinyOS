#include<Timer.h>
#include "printf.h"

#define M1 101
#define M2 102
#define M3 103
#define M4 104

typedef nx_struct msg
{
	nx_uint16_t nodeid;
	nx_uint16_t data;
	nx_uint16_t time;
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
	message_t pkt,pkt2,pkt3,pkt4;
	uint16_t value=0;
	uint16_t sec=0;
	uint16_t s1=0;
	bool busy_m1=FALSE;
	bool busy_m2=FALSE;
	bool busy_m3=FALSE;
	bool busy_m4=FALSE;

	event void Boot.booted()
	{
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err)
	{
		if(err==SUCCESS)
		{
			call Timer0.startPeriodic(1000);
		}
		else
		{
			call AMControl.start();
		}
	}

	event void Timer0.fired()
	{
		
		
		if(TOS_NODE_ID==M1 && busy_m1==FALSE)
		{
			message* btrpkt=(message*)(call Packet.getPayload(&pkt,sizeof(message)));
			sec++;
			if(sec>3)
			{
			sec=1;
			}
			
			call Leds.set(7);
			btrpkt ->nodeid=TOS_NODE_ID;
			btrpkt ->data=1;
			btrpkt ->time=sec;
			if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(message))==SUCCESS)
			{
				busy_m1=TRUE;
			}
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
		if(&pkt4==msg&&busy_m4==TRUE)
		{
			busy_m4=FALSE;
		}
	}
	event void Read.readDone(error_t result, uint16_t data)
	{
		if(result==SUCCESS)
		{
			value=data;
			//busy_m1=FALSE;
			
		}
		
	}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
	{
		call Leds.led2On();
		if(TOS_NODE_ID==M2)
		{	
			
			printf("Hi this is mote 2\n");
			if(len==sizeof(message))
			{
				message* btrpkt=(message*)payload;
				if(btrpkt ->nodeid==M1 && btrpkt->time==1)
				{
					call Read.read();
					s1=btrpkt->time;	
					printf("Hi this is mote 2 and temperature is %u degC\n",value);
					printfflush();
				}
			}
			if(busy_m2==FALSE && s1==1)
			{				
				message* btrpkt=(message*)(call Packet.getPayload(&pkt2,sizeof(message)));
				call Leds.led2Off();
				printf("m2 in sending mode\n");
				printfflush();
				btrpkt ->nodeid=TOS_NODE_ID;
				btrpkt ->data=value;
				if(call AMSend.send(M1,&pkt2,sizeof(message))==SUCCESS)
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
				if(btrpkt ->nodeid==M1 && btrpkt->time==2)
				{
					call Read.read();
					s1=btrpkt->time;	
					printf("Hi this is mote 3 and temperature is %u degC\n",value);
					printfflush();
				}
			}
			if(busy_m3==FALSE && s1==2)
			{
				
				message* btrpkt=(message*)(call Packet.getPayload(&pkt3,sizeof(message)));
				call Leds.led2Off();
				printf("m3 in sending mode\n");
				printfflush();
				btrpkt ->nodeid=TOS_NODE_ID;
				btrpkt ->data=value;
				if(call AMSend.send(M1,&pkt3,sizeof(message))==SUCCESS)
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
				if(btrpkt ->nodeid==M1 && btrpkt->time==3)
				{
					call Read.read();
					s1=btrpkt->time;	
					printf("Hi this is mote 4 and temperature is %u degC\n",value);
					printfflush();
				}
			}
			if(busy_m4==FALSE && s1==3)
			{
				
				message* btrpkt=(message*)(call Packet.getPayload(&pkt4,sizeof(message)));
				call Leds.led2Off();
				printf("m4 in sending mode\n");
				printfflush();
				btrpkt ->nodeid=TOS_NODE_ID;
				btrpkt ->data=value;
				if(call AMSend.send(M1,&pkt4,sizeof(message))==SUCCESS)
				{
					busy_m4=TRUE;
				}
			}	
		}

		if(TOS_NODE_ID==M1)
		{
			//printf("Hi this is mote 1\n");
			//printfflush();
			call Leds.set(0);
			if(len==sizeof(message))
			{
				message* btrpkt=(message*)payload;
				printf("Master receved from %u and data is %u\n",btrpkt->nodeid,btrpkt->data);
				printfflush();
			}	
		}
		
		return msg;
	}
}
