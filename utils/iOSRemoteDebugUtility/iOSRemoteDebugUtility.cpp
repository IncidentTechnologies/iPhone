#include <stdlib.h>
#include <string.h>

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>


void error(char *pszMsg) {
    perror(pszMsg);
    exit(1);
}

int main(int argc, char **argv) {
    // socket file descriptors
    int fdSock;     
    int fdNewSock;
    int portno;     // port number to accept connections on
    int clilen;
    int n;

    char buffer[256];

    struct sockaddr_in serv_addr;   // server internet address
    struct sockaddr_in cli_addr;    // client internet address

    if(argc < 2) {
        fprintf(stderr, "ERROR, no port provided\n");
        exit(1);
    }

    fdSock = socket(AF_INET, SOCK_STREAM, 0);
    if(fdSock < 0)
        error("ERROR opening socket");

    bzero((char*)&serv_addr, sizeof(struct sockaddr_in));
    portno = atoi(argv[1]);

    serv_addr.sin_family = AF_INET;             // Internet address family (not local machine)
    serv_addr.sin_port = htons(portno);         // convert port number to network byte order
    serv_addr.sin_addr.s_addr = INADDR_ANY;     // Gets the IP address of the machine the code is running on 

    // Bind the socket to the address
    if(bind(fdSock, (struct sockaddr *)&serv_addr, sizeof(struct sockaddr))) {
        error("ERROR on binding to port number");
    }

    // start listening on socket for connections
    // with backlog queue of 5
    listen(fdSock, 5);

    clilen = sizeof(sockaddr_in);
    fdNewSock = accept(fdSock, (struct sockaddr *) &cli_addr, &clilen);
    if(fdNewSock < 0)
        error("ERROR on accept");

    bzero(buffer, sizeof(buffer));
    n = read(fdNewSock, buffer, sizeof(buffer) - 1);
    if(n < 0)
        error("ERROR reading from the socket");
    printf("Rx Msg: %s\n", buffer);

    n = write(fdNewSock, "I got your message", 18);
    if(n < 0)
        error("ERROR writing to socket");


    return 0;
}

