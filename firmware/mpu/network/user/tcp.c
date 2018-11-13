#include "tcp.h"
#include "main.h"
#include "udp.h"
#include "fpga.h"


void *thread_tcp(void *arg)
{
    struct sockaddr_in server, client;
    char buf[100];
    udp_st udp_data;
    msg_st msg_tcp_cmd;

    server.sin_family = AF_INET;
    server.sin_addr.s_addr = htonl(INADDR_ANY);
    server.sin_port = htons(TCP_PORT);

    /* create socket */
    int fd_tcp_srv = socket(AF_INET, SOCK_STREAM, 0);
    setsockopt(fd_tcp_srv, SOL_SOCKET, SO_REUSEADDR, NULL, 1);
    bind(fd_tcp_srv, (struct sockaddr *)&server, sizeof(server));
    listen(fd_tcp_srv, 5);

    while(1) {
        int len = sizeof(struct sockaddr);  
        int fd_tcp_cli = accept(fd_tcp_srv, (struct sockaddr *)&client, (socklen_t *)&len);
        printf("client %s:%d connected !\n\r", inet_ntoa(client.sin_addr), ntohs(client.sin_port));
        fpga_led(4, 1);

        do {
            len = read(fd_tcp_cli, buf, sizeof(buf));

            /* setup massage */
            udp_data.addr = client.sin_addr;
            udp_data.port = ntohs(client.sin_port) + 1000;
            msg_tcp_cmd.type = 1;
            msg_tcp_cmd.pdata = &udp_data;            

            /* check command */
            if (len <= 0) {
                udp_data.flag = UDP_FLAG_STOP;
            } else if (0 == memcmp(buf, "data", 4)) {
                udp_data.flag = UDP_FLAG_DATA;
            } else if(0 == memcmp(buf, "stop", 4)) {
                udp_data.flag = UDP_FLAG_STOP;
            } else if(0 == memcmp(buf, "boot", 4)) {
                system("reboot");
            } else {
                udp_data.flag = UDP_FLAG_NONE;
                printf("tcp unknow cmd \n\r");
            }

            /* send massage to udp thread */
            if (msgsnd(msg_cmd, (void *)&msg_tcp_cmd, sizeof(msg_tcp_cmd.pdata), 0) == -1) {
                printf("send msg_cmd error \r\n");
            }
        } while(len > 0);
        
        close(fd_tcp_cli);      
        fpga_led(4, 0);
        printf("client disconnected \n\r");         
    }
    close(fd_tcp_srv);

    pthread_exit("tcp thread end");
}


