#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <dirent.h>
#include <string.h>
#define SOCKNO 49151

int main(int argc, char **argv){
    int socket_desc;
    struct sockaddr_in server_addr;
    char server_message[2000], client_message[2000];
    char rungui[] = "./rungui.sh ";
    int server_struct_length = sizeof(server_addr);
    
    /* check command line arguments */
    if (argc != 2) {
      fprintf(stderr,"usage: %s <message>\n", argv[0]);
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
    server_addr.sin_port = htons(SOCKNO);
    server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    
    // Get input from the user:
    strcpy(client_message,argv[1]);
    
    // Send the message to server:
    if(sendto(socket_desc, client_message, strlen(client_message), 0,
         (struct sockaddr*)&server_addr, server_struct_length) < 0){
        printf("Unable to send message\n");
        return -1;
    }
    
    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 100000;
    if (setsockopt(socket_desc, SOL_SOCKET, SO_RCVTIMEO,&tv,sizeof(tv)) < 0) {
      perror("Error");
    }
    
    // Receive the server's response:
    if(recvfrom(socket_desc, server_message, sizeof(server_message), 0,
         (struct sockaddr*)&server_addr, &server_struct_length) < 0){
        if ( strcmp(argv[1],"SHUTDOWN") ) {
          printf("Error communicating with server, using rungui.sh\n");
          strcat(rungui,argv[1]);
          system( rungui ) ;
        }
        return -1;
    }
    // server should respond with the same message as sent
    if (strcmp((const char*) server_message, (const char*) client_message))
    {
      if ( strcmp(argv[1],"SHUTDOWN") ) {
          printf("Error communicating with server, using rungui.sh\n");
          strcat(rungui,argv[1]);
          system( rungui ) ;
        }
      return -1;
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
