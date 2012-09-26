#include <stdlib.h>

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include "SocketServer.h"

#define START_PORT 8889

int main(int argc, char **argv) 
{
    printf("Server starting on port %d...\n", START_PORT);
    
    // Create socket server on port 8889
    SocketServer *pSocketServer = new SocketServer(START_PORT);
    
    // check for input
    while(1) {
        int newConnectionId = pSocketServer->AcceptNewConnection();
        if(newConnectionId > 0)
            printf("Added new connection id:%d\n", newConnectionId);
        
        pSocketServer->PollConnections(3000);
        
        sleep(1);
    }

    return 0;
}

