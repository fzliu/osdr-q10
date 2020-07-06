#include "udp.h"
#include "fpga.h"
#include "main.h"
#include <math.h>
#include <fcntl.h>   

#define DATA_LEN     528

uint32_t sum_rssi;
uint16_t sum_rssi_cnt;

void *thread_udp(void *arg)
{
    uint8_t *udp_buf = malloc(DATA_LEN);
    uint32_t cnt;
    udp_st *udp_data = NULL;
    struct sockaddr_in server;  
    msg_st msg_tcp_cmd;

    /* create socket */
    int fd_udp = socket(AF_INET, SOCK_DGRAM, 0); 
    setsockopt(fd_udp, SOL_SOCKET, SO_REUSEADDR, NULL, 1);

    fpga_init();
    fpga_enable();
    fpga_rst();

    while(1) {
        int res = msgrcv(msg_cmd, (void *)&msg_tcp_cmd,
                         sizeof(msg_tcp_cmd.pdata), 0, IPC_NOWAIT);

        /* received a massage */
        if (res > 0) {           
            udp_data = (udp_st *)msg_tcp_cmd.pdata;
            if (udp_data->flag == UDP_FLAG_DATA) {
                /* setup socket */
                server.sin_family = AF_INET;
                server.sin_addr.s_addr = udp_data->addr;
                server.sin_port = htons(udp_data->port);
                /* reset fpga when received data command */
                fpga_rst();
                cnt = 0;
            } else if (udp_data->flag == UDP_FLAG_ADDR) {
                /* setup socket */
                server.sin_family = AF_INET;
                server.sin_addr.s_addr = udp_data->addr;
                server.sin_port = htons(udp_data->port);

                sendto(fd_udp, ip_str, strlen(ip_str), 0,
                        (struct sockaddr *)&server, sizeof(server)); 
            }
        }

        /* check data flag and done signal */
        if (udp_data != NULL && udp_data->flag == UDP_FLAG_DATA 
            && true == fpga_wait_done()) {

            fpga_led(DATA_LED, 1);

            /* read rf data */
            memcpy(udp_buf, ebi_ctrl.mem, DATA_LEN);

            if (++cnt % 100) {
                #if 0
                /* read temperature and voltage */
                uint16_t temp = *(uint16_t *)(ebi_ctrl.mem + TEMP_OFFSET);
                uint16_t volt = *(uint16_t *)(ebi_ctrl.mem + VOLT_OFFSET);

                fpga_led(TEMP_LED, temp > 90);
                fpga_led(TEMP_LED, volt > 90);
                #endif
            }

            if (verbose) {
                printf("%d \r\n", cnt);                
                for (uint16_t i = 0; i < 20; i++) {  // 512 - 528
                    // printf("%03d ", udp_buf[i]);
                    printf("%02x ", udp_buf[i]);
                }
                printf("\r\n");
            }

            if (rssi == true) {
                int16_t *ptr_16 = (int16_t *)udp_buf;
                uint32_t ch_rssi[4];

                uint16_t len = DATA_LEN / 8;
                memset(ch_rssi, 0, 4);
                for (uint16_t i = 0; i < len; i+=8) {
                    for (uint8_t j = 0; j < 4; j++) {
                        int16_t a = (int16_t)(ptr_16[i+2*j] << 4) >> 4;
                        int16_t b = (int16_t)(ptr_16[i+2*j+1] << 4) >> 4;
                        ch_rssi[j] += sqrt(a * a + b * b);               
                    }
                }

                printf("rssi: \r\n");
                for (uint8_t i = 0; i < 4; i++) {
                    ch_rssi[i] /= (len >> 3);
                    printf("%-7d", ch_rssi[i]);
                }
                printf("\r\n");

                if (ch_rssi[3] < 500) {
                    sum_rssi += ch_rssi[3];
                    if (++sum_rssi_cnt >= 1000) {
                        sum_rssi /= sum_rssi_cnt;
                        printf("avg_rssi = %d \r\n", sum_rssi);
                        exit(EXIT_SUCCESS);
                    }
                }
            }            

            sendto(fd_udp, udp_buf, DATA_LEN, 0,
                    (struct sockaddr *)&server, sizeof(server)); 

            fpga_led(DATA_LED, 0);
        } else {
            usleep(100);
        }
    }

    close(fd_udp); 
    pthread_exit("udp thread end ");
}
