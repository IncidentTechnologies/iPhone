//
//  SocketServer.h
//  iOSRemoteDebugServer
//
//  Created by Idan Beck on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef iOSRemoteDebugServer_SocketServer_h
#define iOSRemoteDebugServer_SocketServer_h

// Socket Includes
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/poll.h>

#include <fcntl.h>

#include <string.h> 

#include <list>

typedef struct SOCKET_CONNECTION {
    int m_id;                   // local server id
    struct sockaddr_in addr;    // address
    int fdSocket;               // socket file descriptor
} SocketConnection;

class SocketServer 
{
public:   
    SocketServer(int portNumber);    
    ~SocketServer();
    
    int PollConnections(int msTimeout);
    int AcceptNewConnection();
    int CloseSocket(int fdSocket);
    int GetSocketId(int fdSocket);
    
    long SendSocketData(int SocketId, unsigned char *buffer, long buffer_n);

private:
    void SockError(char *pszMsg);
    
private: 
    int m_portNumber;
    int m_fdSocket;
    
    struct sockaddr_in m_sockAddrServer;   // server internet address    
    std::list<SocketConnection *> *m_pAddrClientSockets;
    
    int m_ConnIdCounter;
};



#endif
