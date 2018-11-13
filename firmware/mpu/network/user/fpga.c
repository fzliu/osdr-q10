#include <unistd.h>   
#include <stdio.h>   
#include <stdint.h>
#include <stdlib.h>   
#include <string.h>   
#include <fcntl.h>   
#include <linux/fb.h>   
#include <sys/mman.h>   
#include <sys/ioctl.h> 
#include <time.h>
#include "fpga.h"
#include "main.h"

ebi_st ebi_ctrl;

int fpga_init(void) {
    /* open memery device */
    ebi_ctrl.fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (ebi_ctrl.fd < 0) {
        return ebi_ctrl.fd;
    }

    /* access ebi1 address @ 0x70000000 */
    ebi_ctrl.mem = (uint16_t *)mmap(NULL, MMAP_MEM_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, ebi_ctrl.fd, MEM_ADDR);

    ebi_ctrl.sysc = (int *)mmap(NULL, MMAP_SYSC_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, ebi_ctrl.fd, SYSC_BASE);

    /* get register address */
    ebi_ctrl.pioa = (pio_reg *)(ebi_ctrl.sysc + PIOA_OFFSET / 4);
    /* set pin as pio */
    ebi_ctrl.pioa->per = (1 << PIN_EBI_RST) | (1 << PIN_EBI_RDST) | (1 << PIN_EBI_RDSTV) | (1 << PIN_EBI_DONE);
    /* set output */
    ebi_ctrl.pioa->oer = (1 << PIN_EBI_RST) | (1 << PIN_EBI_RDST) | (1 << PIN_EBI_RDSTV);
    /* set input */
    ebi_ctrl.pioa->odr = (1 << PIN_EBI_DONE);

    return 0;
}

void fpga_rst(void) {
    ebi_ctrl.pioa->codr |= (1 << PIN_EBI_RST);
    ebi_ctrl.pioa->sodr |= (1 << PIN_EBI_RST);
    ebi_ctrl.pioa->codr |= (1 << PIN_EBI_RST);
}

bool fpga_wait_done(void) {

    for (uint16_t i = 0; i < 100; i++) {
        if ((ebi_ctrl.pioa->pdsr & (1 << PIN_EBI_DONE))) {
            return true;
        }
        usleep(1000);
    }
    return false;
}

void fpga_close(void) {
    munmap(ebi_ctrl.mem, MMAP_MEM_LEN);
    munmap(ebi_ctrl.sysc, MMAP_SYSC_LEN);
    close(ebi_ctrl.fd);   
}

void fpga_led(uint8_t num, int value)
{
    char str[100];
    
    sprintf(str, "/sys/class/leds/d%d/brightness", num);
    int fd =  open(str, O_WRONLY);
    if (fd < 0) {
        printf("%s: Can't set led value\n\r", __func__);
        return;
    }    

    if (value) {
        write(fd, "1", 2);
    } else {
        write(fd, "0", 2);
    }

    close(fd);
}

