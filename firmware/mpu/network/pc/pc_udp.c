#include<sys/types.h> 
#include<sys/socket.h> 
#include<unistd.h> 
#include<netinet/in.h> 
#include<arpa/inet.h> 
#include<stdio.h> 
#include<stdlib.h> 
#include<errno.h> 
#include<netdb.h> 
#include<stdarg.h> 
#include<string.h> 

#define UDP_PORT  8080

/* udp server */
int main(void) { 

    struct sockaddr_in server, client;   
    char buf[100]; 
    int len;
    int fd; 

    server.sin_family = AF_INET; 
    server.sin_addr.s_addr = htonl(INADDR_ANY); 
    server.sin_port = htons(UDP_PORT); 

    fd = socket(AF_INET, SOCK_DGRAM, 0); 

    bind(fd, (struct sockaddr *)&server, sizeof(server));

    while(1) {          
        len = recvfrom(fd, buf, sizeof(buf), 0, NULL, NULL);  
        if (len <= 0) {  
            printf("recv error \r\n");
        } else {
            printf("recv: %s \r\n", buf);
        }
    } 
    
    close(fd); 
} 


