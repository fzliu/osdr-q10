/******************************************************************************
*

* Xilinx, Inc.
* XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
* COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
* ONE POSSIBLE    IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
* STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION 
* IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
* FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION
* XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
* THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
* ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
* FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
* AND FITNESS FOR A PARTICULAR PURPOSE.
*
* (c) Copyright 2012 Xilinx, Inc. All rights reserved.
*
******************************************************************************/

#include <stdint.h>
#include <stdio.h>
#include <unistd.h>    
#include <stdlib.h>   
#include <string.h>   
#include <fcntl.h>   

#include "platform.h"


/* Macros used to control printing to stdout */
#define VERBOSE // Print some details about target bitstream to stdout
//#define DEBUG   // Print some of the target bistream to stdout
//#define DEBUG2  // Print out all the bits being transmitted, very slow 

#define BLOCK_LEN   1000

#define xil_printf fprintf

/******************************************************************************
* This is the main function Slave Serial configuration example
*
* @param    None.
*
* @return   0 indicate success, otherwise 1.
*
* @note     None.
*
******************************************************************************/
int main(int argc, char** argv)
{
    uint32_t i; 
#ifdef DEBUG
    uint32_t j; 
#endif
    uint8_t buf_zero[8] = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};

    xil_printf(stderr, "Configuring target FPGA via Slave Serial \r\n");

    if (argc < 2) {
        xil_printf(stderr, "Enter filename \n\r");
        return -1;
    }
    char *file_name = argv[1];

    int fpga_fd = fpga_init();

    fpga_led(0);

    int fd = open(file_name, O_RDONLY);
    if (fd < 0) {
        xil_printf(stderr, "Open file error %d \n\r", fd);
    }

    uint32_t file_len = lseek(fd, 0, SEEK_END);     
    xil_printf(stderr,"%s  %d \n\r", file_name, file_len);

    char *file_buf = malloc(file_len);
    lseek(fd, 0, SEEK_SET); 
    read(fd, file_buf, file_len);

    /* xsvf file handle */
    uint32_t bits_start =  (uint32_t)file_buf + 4;
    /* xsvf file size */
    uint32_t bits_size = file_len;

#ifdef DEBUG
    xil_printf(stderr, "\n\r");
    xil_printf(stderr, "Size target bitstream:\n\r");
    xil_printf(stderr, "0x%08X: 0x%08X\n\r",
               bits_start - 4, *(uint32_t *)(bits_start - 4));
    xil_printf(stderr, "\n\r");
    xil_printf(stderr, "First part of target bitstream:\n\r");
    for (i = 0; i < 64; i += 4) {
        xil_printf(stderr, "0x%08X: 0x%08X\n\r",
                bits_start + i,*(uint32_t *)(bits_start + i));
    }

    xil_printf(stderr, "\n\r");
    xil_printf(stderr, "Last part of target bitstream:\n\r");
    j = bits_start + bits_size - 32;

    for (i = j; i < j + 32; i+=4) {
        xil_printf(stderr, "0x%08X: 0x%08X\n\r", i, *(uint32_t *)i );
    }
    xil_printf(stderr, "\n\r");
#endif // DEBUG

    /* Configuration Reset */
    gpio_set_value(GPIO_PROG, 0);
    delay(1);
    gpio_set_value(GPIO_PROG, 1);
  
    /* Wait for Device Initialization */
    i = 0;
    while (gpio_get_value(GPIO_INIT) == 0) {
        /* Timeout and error if INIT_B is slow to goes High */
        ++i;
        if (i > 0x00002000 ) {
#ifdef VERBOSE
            xil_printf(stderr, "\n\rINIT_B has not gone high\n\r");
#endif // VERBOSE
            return 1;
        }
    }

    /* Configuration (Bitstream) Load */
#ifdef VERBOSE
    xil_printf(stderr, "Downloading Bitstream to target FPGA \n\r");
#endif // VERBOSE

    for (i = 0; i < bits_size; i += BLOCK_LEN){

        spi_write_then_read(fpga_fd, (uint8_t *)(bits_start + i), BLOCK_LEN, NULL, 0);

        if ((gpio_get_value(GPIO_INIT) == 0) && ((i % 10) == 0)) {
#ifdef VERBOSE
            xil_printf(stderr, "\n\rINIT_B error\n\r");
#endif // VERBOSE
            return 1;
        }

    }

    /* Check INIT_B */
    if (gpio_get_value(GPIO_INIT) == 0) {
#ifdef VERBOSE
        xil_printf(stderr, "\n\rINIT_B error\n\r");
#endif // VERBOSE
        return 1;
    }

    /* Compensate for Special Startup Conditions */
    i = 0;
    while(gpio_get_value(GPIO_DONE) == 0) {    
        spi_write_then_read(fpga_fd, buf_zero, 1, NULL, 0);
        /* Timeout and error if DONE fails to go High */
        ++i;
        if (i > 0x00000100 ) {
#ifdef VERBOSE
            xil_printf(stderr, "\n\rDONE has not gone high\n\r");
#endif // VERBOSE
            return 1;
        }
    }

    spi_write_then_read(fpga_fd, buf_zero, 8, NULL, 0);
#ifdef VERBOSE
    xil_printf(stderr, "\n\rDownloading Complete\n\r");
#endif // VERBOSE

    fpga_led(1);

    fpga_close(fpga_fd);
    
    return 0;
}


