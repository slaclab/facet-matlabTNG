/* 
 * applauncher_client.c - A UDP client for communicating with Matlab application launcher
 * usage: applauncher_client <message>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 
#include <dirent.h>
#include <unistd.h>
#include <stdio.h>

#define PORTRANGE1 49152
#define PORTRANGE2 65535

#define BUFSIZE 1024

/* 
 * error - wrapper for perror
 */
void error(char *msg) {
    perror(msg);
    exit(0);
}

// Get port ID
int getPort()
{
  DIR *folder;
  struct dirent *entry;
  int files=0, portnum=PORTRANGE1 ;
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
    }
  }
  return(portnum);
}

int main(int argc, char **argv) {
    int sockfd, portno, n;
    int serverlen;
    struct sockaddr_in serveraddr;
    struct hostent *server;
    char *hostname;
    char buf[BUFSIZE];

    /* check command line arguments */
    if (argc != 2) {
       fprintf(stderr,"usage: %s <message>\n", argv[0]);
       exit(0);
    }
    hostname = "127.0.0.1";
    portno = getPort() ;

    /* socket: create the socket */
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) 
        error("ERROR opening socket");

    /* gethostbyname: get the server's DNS entry */
    server = gethostbyname(hostname);
    if (server == NULL) {
        fprintf(stderr,"ERROR, no such host as %s\n", hostname);
        exit(0);
    }

    /* build the server's Internet address */
    bzero((char *) &serveraddr, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, 
	  (char *)&serveraddr.sin_addr.s_addr, server->h_length);
    serveraddr.sin_port = htons(portno);

    /* send the message to the server */
    strcpy(buf,argv[1]);
    serverlen = sizeof(serveraddr);
    n = sendto(sockfd, buf, strlen(buf), 0, &serveraddr, serverlen);
    if (n < 0) 
      error("ERROR in sendto");

    return 0;
}