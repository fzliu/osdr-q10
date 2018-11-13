#include "main.h"
#include "fpga.h"
#include "udp.h"
#include "tcp.h"

int msg_cmd;
int min_sz = 256;

int main(int argc, char **argv)
{ 
    int ch;
    pthread_t udp_thread, tcp_thread;
    void *thread_result;

    printf("\r\nnetwork app start \r\n");
    while ((ch = getopt(argc, argv, "s:h")) != -1) {
        switch (ch) {
            case 's':
                // printf("The argument of -l is %s\n\n", optarg); 
                sscanf(optarg, "%d", &min_sz);
                break;
            case 'h':
            case '?':
                printf("\r\nUsage: network [options] \r\n");
                printf("    -h  this help \n\r");
                printf("    -s  set minimum buf size \r\n");
                printf("\r\n");
                return -1;
        }
    }

    fpga_led(5, 1);

    /* create msg queue */
    msg_cmd = msgget((key_t)1234, 0666 | IPC_CREAT);
    if (msg_cmd == -1) {
        printf("create msg queue error \r\n");
        exit(EXIT_FAILURE);
    }    

    /* create thread */
    int res = pthread_create(&tcp_thread, NULL, thread_tcp, NULL);
    if (res != 0) {
        printf("tcp thread creation failed");
        exit(EXIT_FAILURE);
    }

    res = pthread_create(&udp_thread, NULL, thread_udp, NULL);
    if (res != 0) {
        printf("udp thread creation failed");
        exit(EXIT_FAILURE);
    }

    /* wait for thread finish */
    res = pthread_join(udp_thread, &thread_result);
    if (res != 0) {
        printf("udp thread join failed");
        exit(EXIT_FAILURE);
    }

    res = pthread_join(tcp_thread, &thread_result);
    if (res != 0) {
        printf("tcp thread join failed");
        exit(EXIT_FAILURE);
    }    

    fpga_led(5, 0);
    exit(EXIT_SUCCESS);
}


