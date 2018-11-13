#ifndef _EBI_H_
#define _EBI_H_


#include "main.h"


#define MEM_ADDR        0x70000000   //FPGA
#define MMAP_MEM_LEN    0X200000
#define MMAP_SYSC_LEN   0x4000  /* PIOA - PIOE */

#define SYSC_BASE     0xFFFFC000
#define PIOA_OFFSET   0x3200
#define PIOB_OFFSET   0x3400
#define PIOC_OFFSET   0x3600
#define PIOD_OFFSET   0x3800
#define PIOE_OFFSET   0x3A00

#define PIN_EBI_RST    16
#define PIN_EBI_RDST   15
#define PIN_EBI_DONE   14
#define PIN_EBI_RDSTV  18

typedef struct {
	uint32_t per;    /* 0x0000 */
	uint32_t pdr;    /* 0x0004 */
	uint32_t psr;    /* 0x0008 */
	uint32_t res0;   /* 0x000c */
	uint32_t oer;    /* 0x0010 */
	uint32_t odr;    /* 0x0014 */
	uint32_t osr;    /* 0x0018 */
	uint32_t res1;   /* 0x0001c */
	uint32_t ifer;   /* 0x00020 */
	uint32_t ifdr;    /* 0x0024 */
	uint32_t ifsr;    /* 0x0028 */
	uint32_t res2;    /* 0x002c */
	uint32_t sodr;    /* 0x0030 */
	uint32_t codr;    /* 0x0034 */
	uint32_t odsr;    /* 0x0038 */
	uint32_t pdsr;    /* 0x003c */
	uint32_t ier;    /* 0x0040 */
	uint32_t idr;    /* 0x0044 */
	uint32_t imr;    /* 0x0048 */
	uint32_t isr;    /* 0x004c */
	uint32_t mder;    /* 0x0050 */
	uint32_t mddr;    /* 0x0054 */
	uint32_t mdsr;    /* 0x0058 */
	uint32_t res3;   /* 0x005c */
	uint32_t pudr;    /* 0x0060 */
	uint32_t puer;    /* 0x0064 */
	uint32_t pusr;    /* 0x0068 */
	uint32_t res4;    /* 0x006c */
	uint32_t asr;    /* 0x0070 */
	uint32_t bsr;    /* 0x0074 */
	uint32_t absr;    /* 0x0078 */
	uint32_t res5;   /* 0x007c */
	uint32_t res6;   /* 0x0080 */
	uint32_t res7;   /* 0x0084 */
	uint32_t res8;   /* 0x0088 */
	uint32_t res9;   /* 0x008c */
	uint32_t res10;   /* 0x0090 */
	uint32_t res11;   /* 0x0094 */
	uint32_t res12;   /* 0x0098 */
	uint32_t res13;   /* 0x009c */
	uint32_t ower;    /* 0x00a0 */
	uint32_t owdr;    /* 0x00a4 */
	uint32_t owsr;    /* 0x00a8 */
	uint32_t res14;   /* 0x00ac */
} pio_reg;

typedef struct {
	int fd;
	uint16_t *mem;
	int *sysc;
	pio_reg *pioa;
} ebi_st;

extern ebi_st ebi_ctrl;


int fpga_init(void);
void fpga_close(void);
void fpga_rst(void);
bool fpga_wait_done(void);
void fpga_led(uint8_t num, int value);

#endif