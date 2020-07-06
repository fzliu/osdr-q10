#ifndef _UDP_H_
#define _UDP_H_


#include "main.h"


#define UDP_BUF_MAX  (65535-20-8)

#define UDP_PORT  2207

#define UDP_FLAG_NONE   0
#define UDP_FLAG_STOP   1
#define UDP_FLAG_DATA   2
#define UDP_FLAG_ADDR   3

typedef struct {
	// struct in_addr addr;
    unsigned long addr;
	uint16_t port;
	int8_t flag;
} udp_st;


void *thread_udp(void *arg);





#endif


