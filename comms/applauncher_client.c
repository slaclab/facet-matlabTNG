#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <dirent.h>
#include <string.h>
#define SOCK1 49153
#define MAXSOCK 49155

int main(int argc, char **argv){
    int socket_desc;
    int sockno=SOCK1;
    struct sockaddr_in server_addr;
    char server_message[2000], client_message[2000];
    char rungui[2000] ;
    char hname[2000];
    int server_struct_length = sizeof(server_addr);
    
    /* Don't use server for facet-srv*
    sprintf(hname,"%s",getenv("HOSTNAME"));
    if (!strncmp(hname,"facet-srv",9)) {
      sprintf(rungui,"xterm -iconic -T \"%s\" -e \"cd /usr/local/facet/tools/matlabTNG; ./rungui.sh %s\" &",argv[1],argv[1]);
      system( rungui ) ;
      return 0;
    }*/
    
    /* check command line arguments */
    if (argc != 3) {
      fprintf(stderr,"usage: %s <appname> \"<workspace_num> <xpos> <ypos>\"\n", argv[0]);
      return -1;
    }
    
    // Clean buffers:
    memset(server_message, '\0', sizeof(server_message));
    memset(client_message, '\0', sizeof(client_message));
    
    // Create socket:
    socket_desc = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    
    if(socket_desc < 0){
        printf("Error while creating socket\n");
        return -1;
    }
    printf("Socket created successfully\n");
    
    // Set port and IP:
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(sockno);
    server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    
    // Get input from the user:
    sprintf(client_message,"%s %s",argv[1],argv[2]); // app,workspace,xpos,ypos
    
    // Set timeout for waiting for server response
    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 100000;
    if (setsockopt(socket_desc, SOL_SOCKET, SO_RCVTIMEO,&tv,sizeof(tv)) < 0) {
      perror("Error");
    }
    
    // Send the message to server:
    while (sockno<=MAXSOCK)
    {
      if(sendto(socket_desc, client_message, strlen(client_message), 0,
              (struct sockaddr*)&server_addr, server_struct_length) < 0)
      {
        printf("Unable to send message, trying socket %d\n",++sockno);
        server_addr.sin_port = htons(sockno);
        continue;
      }
      

      // Receive the server's response
      while (recvfrom(socket_desc, server_message, sizeof(server_message), 0,
           (struct sockaddr*)&server_addr, &server_struct_length) > 0 ) ;
      printf("Server response: %s\n",server_message);

      // server should respond with the same message as sent
      if (strcmp((const char*) server_message, client_message))
      {
        if (sockno==MAXSOCK)
        {
          if ( strcmp(argv[1],"SHUTDOWN") &&  strcmp(argv[1],"TEST")) {
              printf("Error communicating with server, using rungui.sh\n");
              sprintf(rungui,"xterm -iconic -T \"%s\" -e \"cd /usr/local/facet/tools/matlabTNG; ./rungui.sh %s\" &",argv[1],argv[1]);
              system( rungui ) ;
          }
          close(socket_desc);
          return -1;
        }
        else
        {
          printf("Unable to send message, trying socket %d\n",++sockno);
          server_addr.sin_port = htons(sockno);
        }
      }
      else
      {
        break;
      }
    }
    // Close the socket:
    close(socket_desc);
    
    return 0;
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
