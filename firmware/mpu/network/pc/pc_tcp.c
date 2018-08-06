#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define TCP_PORT  10003

int main(void) {

    int sockfd;
    int len;
    struct sockaddr_in address;
    int result;
    char write_buf[100];
    char read_buf[100];

    sockfd = socket(AF_INET, SOCK_STREAM, 0);

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = inet_addr("192.168.1.43");
    address.sin_port = htons(TCP_PORT);
    len = sizeof(address);

    result = connect(sockfd, (struct sockaddr *)&address, len);

    if(result == -1) {
        perror("connect error \r\n");
        exit(1);
    } else {
        printf("connected ! \r\n");
    }

    while(1) {
        scanf("%s", write_buf);
        write(sockfd, write_buf, strlen(write_buf)+1);

        len = read(sockfd, read_buf, sizeof(read_buf));
        if(len <= 0) {
            break;
        }
        printf("ack: %s \r\n", read_buf);
    }

    close(sockfd);
}

