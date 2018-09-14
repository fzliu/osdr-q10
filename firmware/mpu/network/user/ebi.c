#include <fcntl.h>   
#include <linux/fb.h>   
#include <sys/mman.h>   
#include <sys/ioctl.h> 

#include <pthread.h>
#include <sys/types.h> 
#include <sys/socket.h> 
#include <unistd.h> 
#include <netinet/in.h> 
#include <arpa/inet.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <errno.h> 
#include <netdb.h> 
#include <stdarg.h> 
#include <string.h> 
#include <sys/msg.h>

#include "ebi.h"
#include "gpio.h"

#define MEM_ADDR       0x70000000   // FPGA
#define MMAP_MEM_LEN   0x1000

void fpga_init(void) {
	gpio_init(RST_PIN);
	gpio_init(DONE_PIN);

	gpio_direction(RST_PIN, OUT);
	gpio_direction(DONE_PIN, IN);
}

void fpga_send_reset(void) {
	gpio_set_data(RST_PIN, 0);
	sleep(1);
	gpio_set_data(RST_PIN, 1);
}

void flga_wait_done(void) {
	while (!gpio_get_data(DONE_PIN));
}

#define DATA_LEN 1024

void *thread_fpga(void *arg) {
    int fd;
    char *mem; 
    char buf[DATA_LEN];

    fd = open("/dev/mem", O_RDWR | O_SYNC);  
    printf("fd = %d \r\n", fd);

    mem = (char *)mmap(NULL, MMAP_MEM_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, MEM_ADDR);
    printf("mem = 0x%x \r\n", mem); 
/*
    #if 1
    printf("mem @ 0x%x: ", MEM_ADDR);
    for(uint16_t i = 0; i < 8; i++)
    {
        printf("0x%02x ", mem[i]);
    }
    printf("\r\n");
    #endif
*/

    fpga_init();
    while(1) {
    	fpga_send_reset();

    	/* copy from fpgaRam */
    	memcpy(buf, mem, DATA_LEN);

    	flga_wait_done();
        /* send to eth */
    }

    munmap(mem, MMAP_MEM_LEN); 
}



