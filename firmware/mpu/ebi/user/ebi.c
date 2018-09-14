/* EBI1 */
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

#include "pio.h"

#define MEM_ADDR        0x70000000   //FPGA
#define MMAP_MEM_LEN    0X200000

#define CHANNEL_LEN     0X20000

#define CHANNEL0_ADDR   0X70000000
#define CHANNEL1_ADDR   0X70020000
#define CHANNEL2_ADDR   0X70040000
#define CHANNEL3_ADDR   0X70060000
#define CHANNEL4_ADDR   0X70080000
#define CHANNEL5_ADDR   0X700A0000
#define CHANNEL6_ADDR   0X700C0000
#define CHANNEL7_ADDR   0X700E0000

#define FPGA_RAM_LEN    0x100000  // 708606  // 0xACFFE

int main(void)
{ 
    fpga_init();

    int fd = open("/dev/mem", O_RDWR | O_SYNC);  
    printf("fd = %d \r\n", fd);

    uint16_t *mem = (uint16_t *)mmap(NULL, MMAP_MEM_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, MEM_ADDR);
    //printf("mem = 0x%x \r\n", mem); 


#if 0
    long time;
    struct timeval tv_begin, tv_end;
    uint16_t dat;
    uint32_t err_cnt = 0;
    gettimeofday(&tv_begin, NULL);
            fpga_rst();
            fpga_wait_done();
    //while(1) {
        for (uint32_t j = 0; j < 5; j++) {  //5400
            printf("\r\n");
#if 1
            for (uint32_t k = 0; k < 1; k++) {
                fpga_rst();
                fpga_wait_done();
            }
#endif
            err_cnt = 0;
            for (uint32_t i = 0; i < FPGA_RAM_LEN; i++) {
                //printf("[addr, data] 0x%x, 0x%x \r\n", i, dat); 
                dat = *(mem + i);
                if (dat != (i & 0xffff)) {
                    err_cnt++;
                    printf("[addr, data] 0x%x, 0x%x \r\n", i, dat); 
                    if (err_cnt > 39) {
                        break;
                    }
                }
            }
        }

        gettimeofday(&tv_end, NULL);
        time = (tv_end.tv_sec * 1000000 + tv_end.tv_usec) - (tv_begin.tv_sec * 1000000 + tv_begin.tv_usec);
        printf("%d.%d s   ", time / 1000000, time % 1000000);    
        printf("err_cnt = %d \r\n", err_cnt);        
        //if ((tv_end.tv_sec - tv_begin.tv_sec) > 60 * 60 * 18) {
        if ((tv_end.tv_sec - tv_begin.tv_sec) > 2) {
            //break;
        }
    //}
    printf("completed \r\n");
#endif

#if 0
    uint32_t err_cnt = 0;
    fpga_rst();
    fpga_wait_done();
    //while(1) {
        for (uint32_t i = 0; i < 1; i++) {  //5400
            printf("\r\n");
#if 1
            for (uint32_t k = 0; k < 1; k++) {
                fpga_rst();
                fpga_wait_done();
            }
#endif
            
            for (uint32_t j = 0; j < 8 ; j++) {
                printf("addr: 0x%x \r\n", MEM_ADDR + j * CHANNEL_LEN);
                err_cnt = 0;
                for (uint32_t i = 0; i < CHANNEL_LEN; i++) {  // CHANNEL_LEN    
                    uint16_t dat = (uint16_t)(*(mem + j * CHANNEL_LEN + i));    
                    if (dat != (i & 0xffff)) {
                    //if (dat != i) {
                        err_cnt++;
                        printf("[addr, data] 0x%x, 0x%x \r\n", i, dat); 
                        if (err_cnt > 9) {
                            break;
                        }
                    }
                }
                printf("err_cnt = %d \r\n", err_cnt); 
            }
        }  
           
    //}
    printf("completed \r\n");
#endif

#if 1
    int fc = open("/home/root/all_data.bin", O_RDWR | O_SYNC | O_CREAT);
    printf("fc = %d \r\n", fc);

    fpga_rst();

    

//for (uint32_t k = 0; k < 4; k++)
{
    fpga_wait_done();

    //sleep(1);
    //printf("0x%04x  ", (uint16_t)(*(mem + 60)));

    for (uint32_t j = 0; j < 8; j++) {
        printf("addr: 0x%x \r\n", MEM_ADDR + j * CHANNEL_LEN);

    #if 1
        //uint32_t sum = 0;
        for (uint32_t i = 0; i < 50; i++) {  // CHANNEL_LEN    
            //sum += (uint16_t)(*(mem + j * CHANNEL_LEN + i));    
            printf("0x%04x  ", (uint16_t)(*(mem + j * CHANNEL_LEN + i)));
        }
        //printf("avg = 0x%x \r\n", sum / 200);
    #endif

        write(fc, mem + j * CHANNEL_LEN, 0x19E10);  // CHANNEL_LEN
        //write(fc, mem + j * CHANNEL_LEN, 0xCFBC);  //0xCFBC

    }  
}
#endif

    munmap(mem, MMAP_MEM_LEN);
}


