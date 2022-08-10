#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <dirent.h>
#include "mex.h"
#define SOCKNO 49151

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, 
  const mxArray *prhs[]) {
    int socket_desc;
    struct sockaddr_in server_addr, client_addr;
    char server_message[2000], client_message[2000];
    int client_struct_length = sizeof(client_addr);
    
    // Check output parameters
    if (nlhs<1)
      mexPrintf("Error, must supply output parameter");
    
    
    // Clean buffers:
    memset(server_message, '\0', sizeof(server_message));
    memset(client_message, '\0', sizeof(client_message));
    
    // Create UDP socket:
    socket_desc = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    
    if(socket_desc < 0){
        printf("Error while creating socket\n");
        plhs[0] = mxCreateString((const char *) client_message);
        return ;
    }
    printf("Socket created successfully\n");
    
    // Set port and IP:
    server_addr.sin_family = AF_INET;
    //printf("Using socket port %d\n",portno);
    server_addr.sin_port = htons(SOCKNO);
    server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    
    // Bind to the set port and IP:
    if(bind(socket_desc, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0){
        printf("Couldn't bind to the port\n");
        plhs[0] = mxCreateString((const char *) client_message);
        return ;
    }
    printf("Done with binding\n");
    
    printf("Listening for incoming messages...\n\n");
    
    // Receive client's message:
    if (recvfrom(socket_desc, client_message, sizeof(client_message), 0,
         (struct sockaddr*)&client_addr, &client_struct_length) < 0){
      plhs[0] = mxCreateString((const char *) client_message);  
      printf("Couldn't receive\n");
        return ;
    }
    printf("Received message from IP: %s and port: %i\n",
           inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));
    
    printf("Msg from client: %s\n", client_message);
    
    plhs[0] = mxCreateString((const char *) client_message);
    
    // Respond to client:
    strcpy(server_message, client_message);
    
    if (sendto(socket_desc, server_message, strlen(server_message), 0,
         (struct sockaddr*)&client_addr, client_struct_length) < 0){
        printf("Can't send\n");
        return ;
    }
    
    // Close the socket:
    close(socket_desc);
    
    return;
}

// Get port ID
int getPort()
{
  DIR *folder;
  struct dirent *entry;
  int files=0, portnum=0 ;
  FILE *fp ;
  char newfile[80], portchar[80] ;

  folder = opendir(".");
  if(folder == NULL)
  {
    printf("Unable to read local directory");
    return(1);
  }
  while( (entry=readdir(folder)) )
  {
    files++;
    if (!strncmp("applauncherPort_",entry->d_name,16)) {
      portnum = atoi(entry->d_name+16) ;
      break;
    }
  }
  closedir(folder);
  return(portnum);
}
