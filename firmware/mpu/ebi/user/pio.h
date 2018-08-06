#include <unistd.h>   
#include <stdio.h>   
#include <stdint.h> 
#include <stdlib.h>   
#include <string.h>   
#include <fcntl.h>   
#include <linux/fb.h>   
#include <sys/mman.h>   
#include <sys/ioctl.h> 

#define SYSC_BASE     0xFFFFC000
#define PIOA_OFFSET   0x3200
#define PIOB_OFFSET   0x3400
#define PIOC_OFFSET   0x3600
#define PIOD_OFFSET   0x3800
#define PIOE_OFFSET   0x3A00

#define MMAP_SYSC_LEN   0x4000  /* PIOA - PIOE */

#define PIO_PER		0x00	/* Enable Register */
#define PIO_PDR		0x04	/* Disable Register */
#define PIO_PSR		0x08	/* Status Register */
#define PIO_OER		0x10	/* Output Enable Register */
#define PIO_ODR		0x14	/* Output Disable Register */
#define PIO_OSR		0x18	/* Output Status Register */
#define PIO_IFER	0x20	/* Glitch Input Filter Enable */
#define PIO_IFDR	0x24	/* Glitch Input Filter Disable */
#define PIO_IFSR	0x28	/* Glitch Input Filter Status */
#define PIO_SODR	0x30	/* Set Output Data Register */
#define PIO_CODR	0x34	/* Clear Output Data Register */
#define PIO_ODSR	0x38	/* Output Data Status Register */
#define PIO_PDSR	0x3c	/* Pin Data Status Register */
#define PIO_IER		0x40	/* Interrupt Enable Register */
#define PIO_IDR		0x44	/* Interrupt Disable Register */
#define PIO_IMR		0x48	/* Interrupt Mask Register */
#define PIO_ISR		0x4c	/* Interrupt Status Register */
#define PIO_MDER	0x50	/* Multi-driver Enable Register */
#define PIO_MDDR	0x54	/* Multi-driver Disable Register */
#define PIO_MDSR	0x58	/* Multi-driver Status Register */
#define PIO_PUDR	0x60	/* Pull-up Disable Register */
#define PIO_PUER	0x64	/* Pull-up Enable Register */
#define PIO_PUSR	0x68	/* Pull-up Status Register */
#define PIO_ASR		0x70	/* Peripheral A Select Register */
#define PIO_BSR		0x74	/* Peripheral B Select Register */
#define PIO_ABSR	0x78	/* AB Status Register */
#define PIO_OWER	0xa0	/* Output Write Enable Register */
#define PIO_OWDR	0xa4	/* Output Write Disable Register */
#define PIO_OWSR	0xa8	/* Output Write Status Register */



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

int fpga_init(void);
void fpga_close(void);
void fpga_rst(void);
void fpga_led(uint8_t value);
void fpga_wait_done(void);
void fpga_din_set(uint8_t value);
void fpga_cclk_set(uint8_t value);
void fpga_prog_set(uint8_t value);
uint8_t fpga_done_get(void);
uint8_t fpga_init_get(void);


