//
//  SocketServer.cpp
//  iOSRemoteDebugServer
//
//  Created by Idan Beck on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "SocketServer.h"

SocketServer::SocketServer(int portNumber) :
    m_portNumber(portNumber),
    m_pAddrClientSockets(NULL),
    m_ConnIdCounter(0)
{
    m_pAddrClientSockets = new std::list<SocketConnection *>();
    
    m_fdSocket = socket(AF_INET, SOCK_STREAM, 0);
    if(m_fdSocket < 0)
        SockError((char *)"ERROR opening socket");
    
    // set up the socket to be non-blocking
    int FlagsFD = fcntl(m_fdSocket, F_GETFL, 0);
    fcntl(m_fdSocket, F_SETFL, FlagsFD | O_NONBLOCK);
    FlagsFD = fcntl(m_fdSocket, F_GETFL, 0);
    
    bzero((char*)&m_sockAddrServer, sizeof(struct sockaddr_in));        
    m_sockAddrServer.sin_family = AF_INET;             // Internet address family (not local machine)
    m_sockAddrServer.sin_port = htons(m_portNumber);         // convert port number to network byte order
    m_sockAddrServer.sin_addr.s_addr = INADDR_ANY;     // Gets the IP address of the machine the code is running on 
    
    // Bind the socket to the address
    if(bind(m_fdSocket, (struct sockaddr *)&m_sockAddrServer, sizeof(struct sockaddr_in)))
        SockError((char *)"ERROR on binding to port number");
    
    // start listening on socket for connections with backlog queue of 5
    listen(m_fdSocket, 5);
}

int SocketServer::PollConnections(int msTimeout)
{
    if(m_pAddrClientSockets->size() <= 0) 
        return 0;
    
    struct pollfd *pufds = NULL;
    pufds = new struct pollfd[m_pAddrClientSockets->size() - 1];
    
    std::list<SocketConnection*>::iterator it;
    int i = 0;
    for(it = m_pAddrClientSockets->begin(); it != m_pAddrClientSockets->end(); it++) {
        SocketConnection *pTempSockConn = reinterpret_cast<SocketConnection *>(*it);
        pufds[i].fd = pTempSockConn->fdSocket;
        pufds[i].events = POLLIN;
        i++;
    }
    
    int rv = 0;
    if((rv = poll(pufds, m_pAddrClientSockets->size(), msTimeout)) > 0) 
    {
        for(i = 0; i < m_pAddrClientSockets->size(); i++)
        {
            if(pufds[i].revents & POLLIN) 
            {
                char buffer[512];
                memset(&buffer, 0, sizeof(char) * 512);
                long RxBytes = recv(pufds[i].fd, (void*)buffer, (sizeof(buffer) - 1), 0);

                if(RxBytes > 0)
                {
                    printf("client %d: %s\n", GetSocketId(pufds[i].fd), buffer);
                }
                else 
                {
                    int socketId = GetSocketId(pufds[i].fd);
                    
                    if(CloseSocket(pufds[i].fd) != -1)
                        printf("client %d Socket closed, read 0 bytes on socket\n", socketId);
                    else
                        printf("client %d Socket closed, error on socket disconnect\n", socketId);
                }            
            }
        }
    }

    return rv;
}

SocketServer::~SocketServer() 
{
    if(m_pAddrClientSockets != NULL) 
    {
        delete m_pAddrClientSockets;
        m_pAddrClientSockets = NULL;
    }
}

long SocketServer::SendSocketData(int SocketId, unsigned char *buffer, long buffer_n) 
{
    for(std::list<SocketConnection*>::iterator it = m_pAddrClientSockets->begin(); it != m_pAddrClientSockets->end(); it++) 
    {
        SocketConnection *pTempSockConn = reinterpret_cast<SocketConnection *>(*it);
        if(pTempSockConn->m_id == SocketId) 
        {
            long TxBytes = send(pTempSockConn->fdSocket, buffer, buffer_n, 0);
            printf("Sent %d bytes to client id: %d\n", SocketId, TxBytes);    
            return TxBytes;
        }
    }
    
    return -1;
}

int SocketServer::GetSocketId(int fdSocket)
{
    for(std::list<SocketConnection*>::iterator it = m_pAddrClientSockets->begin(); it != m_pAddrClientSockets->end(); it++) 
    {
        SocketConnection *pTempSockConn = reinterpret_cast<SocketConnection *>(*it);
        if(pTempSockConn->fdSocket == fdSocket)
            return pTempSockConn->m_id;
    }
    
    return -1;
}

int SocketServer::CloseSocket(int fdSocket) 
{
    for(std::list<SocketConnection*>::iterator it = m_pAddrClientSockets->begin(); it != m_pAddrClientSockets->end(); it++) {
        SocketConnection *pTempSockConn = reinterpret_cast<SocketConnection *>(*it);
        if(pTempSockConn->fdSocket == fdSocket)
        {
            m_pAddrClientSockets->erase(it);
            return close(fdSocket);
        }
    }
    
    // return -1 if socket not found
    return -1;
}

int SocketServer::AcceptNewConnection() {
    if(m_fdSocket < 0)
        return -1;
    
    // Check for a new connection, this is non-blocking so return if nothing found
    struct sockaddr_in sockAddrClient;
    int clientLength = sizeof(sockaddr_in);
    int fdNewSock = accept(m_fdSocket, (struct sockaddr *) &sockAddrClient, (socklen_t *)&clientLength);
    if(fdNewSock < 0)
        return fdNewSock;
    
    SocketConnection *pSockConn = new SocketConnection;
    pSockConn->m_id = ++m_ConnIdCounter;
    pSockConn->addr = sockAddrClient;
    pSockConn->fdSocket = fdNewSock;
    
    m_pAddrClientSockets->push_front(pSockConn);
    return pSockConn->m_id;
}

void SocketServer::SockError(char *pszMsg) {
    perror(pszMsg);
    exit(1);
}
