#include "udp.h"
#include "fpga.h"
#include "main.h"

#define RAM_SIZE     0x200000

void *thread_udp(void *arg)
{
    uint8_t *udp_buf = malloc(RAM_SIZE);
    uint32_t cnt;
    udp_st *udp_data;
    struct sockaddr_in server;  
    msg_st msg_tcp_cmd;

    /* create socket */
    int fd_udp = socket(AF_INET, SOCK_DGRAM, 0); 
    setsockopt(fd_udp, SOL_SOCKET, SO_REUSEADDR, NULL, 1);

    fpga_init();
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
                server.sin_addr.s_addr = udp_data->addr.s_addr;
                server.sin_port = htons(udp_data->port);
                /* reset fpga when received data command */
                fpga_rst();                     
                cnt = 0;
            }
        }

        /* check data flag and done signal */
        if (udp_data->flag == UDP_FLAG_DATA && true == fpga_wait_done()) {
            fpga_led(3, 1);
            uint32_t len = 0;
            while(1) {
                /* read data from fpga */
                memcpy(udp_buf + len, ebi_ctrl.mem, 16);
                /* check if the end of data */
                if ( *(uint16_t *)(udp_buf + len) == 0xffff) {
                    break;
                }

                len += 16;
                if (len > RAM_SIZE) {
                    printf("ram overflow ! \n\r");
                    break;
                }
            }
            /* filter noise */
            if (len > min_sz * 16) {
                printf("%d, %d \n\r", cnt++, len);

                /* send data */
                uint8_t *ptr = udp_buf;
                for (int i = 0; i < len / UDP_BUF_MAX; i++) {
                    sendto(fd_udp, ptr, UDP_BUF_MAX, 0,
                           (struct sockaddr *)&server, sizeof(server));  
                    ptr += UDP_BUF_MAX;
                }
                /* send remain data */
                if (len % UDP_BUF_MAX) {
                    sendto(fd_udp, ptr, len % UDP_BUF_MAX, 0,
                           (struct sockaddr *)&server, sizeof(server)); 
                }
            }
            fpga_led(3, 0);
        } else {
            /* have a rest */
            usleep(100 * 1000);
        }
    }

    close(fd_udp); 
    pthread_exit("udp thread end ");
}


