#include <unistd.h>   
#include <stdio.h>   
#include <stdlib.h>   
#include <string.h>   
#include <fcntl.h>   
#include <linux/fb.h>   
#include <sys/mman.h>   
#include <sys/ioctl.h> 
#include "pio.h"


#define PIN_LED0   0
#define PIN_LED1   1
#define PIN_LED2   2
#define PIN_LED3   3
#define PIN_LED4   4
#define PIN_LED5   5

#define PIN_EBI_RST    16
#define PIN_EBI_RDST   15
#define PIN_EBI_DONE   14

pio_reg *pioa, *piob, *pioe;

int fpga_init(void) {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        /* open mmap err */
        return fd;
    }

    int *sysc = (int *)mmap(NULL, MMAP_SYSC_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, SYSC_BASE);

    pioa = (pio_reg *)(sysc + PIOA_OFFSET / 4);
    piob = (pio_reg *)(sysc + PIOB_OFFSET / 4);
    pioe = (pio_reg *)(sysc + PIOE_OFFSET / 4);

    pioa->per = (1 << PIN_EBI_RST) | (1 << PIN_EBI_DONE) | (1 << PIN_EBI_RDST);
    pioa->oer = (1 << PIN_EBI_RST) | (1 << PIN_EBI_RDST);
    pioa->odr = (1 << PIN_EBI_DONE);

    /* set led pin as pio */
    pioe->per = (1 << PIN_LED0) | (1 << PIN_LED1) | (1 << PIN_LED2) | (1 << PIN_LED3) | (1 << PIN_LED4) | (1 << PIN_LED5);
    /* set led pin output */
    pioe->oer = (1 << PIN_LED0) | (1 << PIN_LED1) | (1 << PIN_LED2) | (1 << PIN_LED3) | (1 << PIN_LED4) | (1 << PIN_LED5);

    return 0;
}

void fpga_rst(void) {
    pioa->codr |= (1 << PIN_EBI_RST);
    pioa->sodr |= (1 << PIN_EBI_RST);
    pioa->codr |= (1 << PIN_EBI_RST);
}

void fpga_wait_done(void) {
    while(!(pioa->pdsr & (1 << PIN_EBI_DONE)));
    pioa->sodr |= (1 << PIN_EBI_RDST);
    while((pioa->pdsr & (1 << PIN_EBI_DONE)));
    pioa->codr |= (1 << PIN_EBI_RDST);
}

void fpga_led(uint8_t value) {
    if (value) {
        pioe->sodr |= (1 << PIN_LED2);
    } else {
        pioe->codr |= (1 << PIN_LED2);
    }
}

void fpga_close(void) {
    //munmap(sysc, MMAP_SYSC_LEN);   
    //close(fd);   
}

