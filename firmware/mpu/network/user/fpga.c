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

int fpga_init(void)
{
    /* open memery device */
    ebi_ctrl.fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (ebi_ctrl.fd < 0) {
        return ebi_ctrl.fd;
    }

    /* access ebi1 address */
    ebi_ctrl.mem = (uint16_t *)mmap(NULL, MMAP_MEM_LEN, PROT_READ | PROT_WRITE,
                                    MAP_SHARED, ebi_ctrl.fd, MEM_ADDR);
    /* access sysc address */
    ebi_ctrl.sysc = (int *)mmap(NULL, MMAP_SYSC_LEN, PROT_READ | PROT_WRITE,
                                MAP_SHARED, ebi_ctrl.fd, SYSC_BASE);

    /* get register address */
    ebi_ctrl.pioa = (pio_reg *)(ebi_ctrl.sysc + PIOA_OFFSET / 4);
    /* set pin function as pio */
    ebi_ctrl.pioa->per = (1 << PIN_EBI_RST) | (1 << PIN_EBI_DONE) | (1 << PIN_EBI_EN);
    /* set output */
    ebi_ctrl.pioa->oer = (1 << PIN_EBI_RST) | (1 << PIN_EBI_EN);
    /* set input */
    ebi_ctrl.pioa->odr = (1 << PIN_EBI_DONE);

    return 0;
}

void fpga_test(void)
{
  uint16_t ram_top = 0;

  //*(ebi_ctrl.mem + FPGA_RAM_WE) = 0;
  *(ebi_ctrl.mem + FPGA_RAM_RST) = 0;
  for(uint32_t i = 0; i < 2000000; i++) {}
  *(ebi_ctrl.mem + FPGA_RAM_RST) = 1;
  *(ebi_ctrl.mem + FPGA_RAM_ARG) = 0;
  //*(ebi_ctrl.mem + FPGA_RAM_WE) = 1;

  printf("WE:%d,",*(ebi_ctrl.mem + FPGA_RAM_WE));
  printf("RN:%d,",*(ebi_ctrl.mem + FPGA_RAM_RN));
  printf("RST:%d,",*(ebi_ctrl.mem + FPGA_RAM_RST));
  printf("ADDR:%d,",*(ebi_ctrl.mem + FPGA_RAM_TOP));
//  printf("TEST:%d,",*(ebi_ctrl.mem + FPGA_RAM_TOP + 1));
  printf("ARG:%d\n",*(ebi_ctrl.mem + FPGA_RAM_ARG));

  while (!(*(ebi_ctrl.mem + FPGA_RAM_RN))) {}

  //for(uint16_t i = 0; i < 1000; i++) {printf("%d-%d,",*(ebi_ctrl.mem + i),i);} printf("\n");
  while (1)
  {
   printf("WE:%d,",*(ebi_ctrl.mem + FPGA_RAM_WE));
    printf("RN:%d,",*(ebi_ctrl.mem + FPGA_RAM_RN));
    printf("RST:%d,",*(ebi_ctrl.mem + FPGA_RAM_RST));
    printf("ADDR:%d,",*(ebi_ctrl.mem + FPGA_RAM_TOP));
    printf("TEST:%d,",*(ebi_ctrl.mem + FPGA_RAM_TOP + 1));
    printf("ARG:%d\n",*(ebi_ctrl.mem + FPGA_RAM_ARG));

    while (!(*(ebi_ctrl.mem + FPGA_RAM_RN))) {}
    *(ebi_ctrl.mem + FPGA_RAM_WE) = 0;
    while (*(ebi_ctrl.mem + FPGA_RAM_TOP) > ram_top)
    {
      for (uint16_t i = 0; i < 4 ; i++){
        int16_t ebi_out_data = *(ebi_ctrl.mem + ram_top + (i*2));
        printf("q%d:%d ",(3-i),ebi_out_data);
        ebi_out_data = *(ebi_ctrl.mem + ram_top + (i*2) + 1);
        printf("i%d:%d ",(3-i),ebi_out_data);
      }
      printf("\n");
//      printf("%d---%d---%d\n",ebi_out_data,ram_top,*(ebi_ctrl.mem + FPGA_RAM_TOP));
      if(ram_top >= (FPGA_RAM_WE - 8)){ram_top = 0;} else {ram_top+=8;}
    }
    *(ebi_ctrl.mem + FPGA_RAM_WE) = 1;
    getchar();
  }
}

void fpga_enable(void)
{
    ebi_ctrl.pioa->sodr |= (1 << PIN_EBI_EN);
}

void fpga_rst(void)
{
    ebi_ctrl.pioa->codr |= (1 << PIN_EBI_RST);
    ebi_ctrl.pioa->sodr |= (1 << PIN_EBI_RST);
    ebi_ctrl.pioa->codr |= (1 << PIN_EBI_RST);
}

bool fpga_wait_done(void)
{
    if ((ebi_ctrl.pioa->pdsr & (1 << PIN_EBI_DONE))) {
        return true;
    } else {
        return false;
    }
}

void fpga_close(void)
{
    munmap(ebi_ctrl.mem, MMAP_MEM_LEN);
    munmap(ebi_ctrl.sysc, MMAP_SYSC_LEN);
    close(ebi_ctrl.fd);
}

void fpga_led(uint8_t num, bool value)
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
