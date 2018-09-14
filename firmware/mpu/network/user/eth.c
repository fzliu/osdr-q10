#include <pthread.h>
#include <sys/types.h> 
#include <sys/socket.h> 
#include <unistd.h> 
#include <netinet/in.h> 
#include <arpa/inet.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <errno.h> 
#include <netdb.h> 
#include <stdarg.h> 
#include <string.h> 
#include <sys/msg.h>

#include "ebi.h"

#define TCP_PORT  10003
#define UDP_PORT  8080

void *thread_udp(void *arg);
void *thread_tcp(void *arg);
void *thread_tcp_server(void *arg);


struct msg_st {
    long int type;
    char buf[100];
};
int msgid;

int main() {
    int res;
    pthread_t fpga_thread, udp_thread, tcp_thread;
    void *thread_result;

    /* create msg queue */
    msgid = msgget((key_t)1234, 0666 | IPC_CREAT);
    if (msgid == -1) {
        printf("create msg queue error \r\n");
        exit(EXIT_FAILURE);
    }    

    /* fpga */
    res = pthread_create(&fpga_thread, NULL, thread_fpga, NULL);
    if (res != 0) {
        printf("fpga thread creation failed");
        exit(EXIT_FAILURE);
    }    

    /* udp client */
    res = pthread_create(&udp_thread, NULL, thread_udp, NULL);
    if (res != 0) {
        printf("udp thread creation failed");
        exit(EXIT_FAILURE);
    }

    /* tcp server */
    res = pthread_create(&tcp_thread, NULL, thread_tcp, NULL);
    if (res != 0) {
        printf("tcp thread creation failed");
        exit(EXIT_FAILURE);
    }

    /* wait for thread finish */
    res = pthread_join(fpga_thread, &thread_result);
    if (res != 0) {
        printf("fpga thread join failed");
        exit(EXIT_FAILURE);
    }

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

    exit(EXIT_SUCCESS);
}

void *thread_tcp(void *arg) {

    pthread_t tcp_server;
    struct sockaddr_in server, client;
    int server_fd, client_fd;
    int len;
    int res;

    printf("tcp server start ! \r\n");

    server.sin_family = AF_INET;
    server.sin_addr.s_addr = htonl(INADDR_ANY);
    server.sin_port = htons(TCP_PORT);

    server_fd = socket(AF_INET, SOCK_STREAM, 0);

    bind(server_fd, (struct sockaddr *)&server, sizeof(server));

    listen(server_fd, 5);

    len = sizeof(client);

    while(1) {
        client_fd = accept(server_fd, (struct sockaddr *)&client, &len);

        printf("[%d] %s:%d connect !\r\n", client_fd, inet_ntoa(client.sin_addr), ntohs(client.sin_port));

        res = pthread_create(&tcp_server, NULL, thread_tcp_server, (void *)client_fd);
        if (res != 0) {
            perror("Thread creation failed");
            exit(EXIT_FAILURE);
        }        
    }
    close(server_fd);

    pthread_exit("thread end");
}

void *thread_tcp_server(void *arg)
{
    int fd;
    char buf[100];
    int len;
    char str[100];
    struct msg_st cmd;

    fd = (int)arg;
    cmd.type = 1;

    while(1) {
        len = read(fd, buf, sizeof(buf));
        if (len <= 0) {    /* client is disconnect */
            break;
        }    

        if (0 == strcmp(buf, "boot")) {
            //write(fd, "system reboot", strlen("system reboot")+1);
            sprintf(str, "[%d] system reboot", fd);
            write(fd, str, strlen(str)+1);
            //system("reboot");
        }
        else if (0 == strcmp(buf, "ping")) {
            //write(fd, "ping", strlen("ping")+1);
            sprintf(str, "[%d] ping", fd);
            write(fd, str, strlen(str)+1);            
        }
        else if (0 == strcmp(buf, "blen")) {
            //write(fd, "buf len is 1024", strlen("buf len is 1024")+1);
            sprintf(str, "[%d] buf len is 1024", fd);
            write(fd, str, strlen(str)+1);            
        }
        else if (0 == strcmp(buf, "rate")) {
            //write(fd, "rate is 2.4GHz", strlen("rate is 2.4GHz")+1);
            sprintf(str, "[%d] rate is 2.4GHz", fd);
            write(fd, str, strlen(str)+1);            
        }
        else if (0 == strcmp(buf, "data")) {
            //write(fd, "start send data", strlen("start send data")+1);
            sprintf(str, "[%d] start send data", fd);
            write(fd, str, strlen(str)+1);

            cmd.buf[0] = 1;
            if (msgsnd(msgid, (void *)&cmd, sizeof(cmd.buf), 0) == -1) {
                printf("send msg error \r\n");
                //break;
            }               
        }
        else if (0 == strcmp(buf, "stop")) {
            //write(fd, "stop send data", strlen("stop send data")+1);
            sprintf(str, "[%d] stop send data", fd);
            write(fd, str, strlen(str)+1);

            cmd.buf[0] = 0;
            if (msgsnd(msgid, (void *)&cmd, sizeof(cmd.buf), 0) == -1) {
                printf("send msg error \r\n");
                //break;
            }             
        }
        else {
            //write(fd, "unknow cmd", strlen("unknow cmd")+1);
            sprintf(str, "[%d] unknow cmd", fd);
            write(fd, str, strlen(str)+1);
        }
    }

    printf("[%d] closed . \r\n", fd);
    close(fd);
}



/* udp clent */
void *thread_udp(void *arg) {

    struct sockaddr_in server;  
    char buf[100];  
    int cnt = 0;
    int len;
    int fd; 
    int flag = 0;
    struct msg_st cmd;

    server.sin_family = AF_INET; 
    server.sin_addr.s_addr = inet_addr("192.168.1.42"); 
    server.sin_port = htons(UDP_PORT); 

    fd = socket(AF_INET, SOCK_DGRAM, 0); 

    while(1) {  
        if (msgrcv(msgid, (void *)&cmd, sizeof(cmd.buf), 0, IPC_NOWAIT) >= 0) {
            flag = cmd.buf[0];
        }

        /* get data from fpga */
        

        if (flag) {
            cnt++;
            sprintf(buf, "%d", cnt);
            sendto(fd, buf, strlen(buf)+1, 0, (struct sockaddr *)&server, sizeof(server));  
            sleep(1);
        }
    } 

    close(fd); 

    pthread_exit("udp client end ");
}



