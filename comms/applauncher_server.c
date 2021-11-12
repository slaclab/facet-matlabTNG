#include <stdio.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <dirent.h>
#include <unistd.h>
#include <stdio.h>
#define MAX 80
#define SA struct sockaddr
#define PORTRANGE1 49152
#define PORTRANGE2 65535

// Get port ID and Increment file name port number by 2 within range PORTRANGE1:PORTRANGE2
int getPort(int newport)
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
      if (newport)
        portnum = portnum+2 ;
      remove(entry->d_name);
    }
  }
  if (portnum >= PORTRANGE2)
    portnum = PORTRANGE1 ;
  closedir(folder);
  strcpy(newfile,"applauncherPort_");
  sprintf(portchar,"%d",portnum);
  strcat(newfile,portchar);
  fp = fopen(newfile,"w") ;
  fclose(fp);
  return(portnum);
}

// Start new matlab launch server and socket
int create_matsock(int portnum)
{
  char buff[MAX] ;
  int matsock, connfd, len ;
  struct sockaddr_in servaddr, cli;
  matsock = socket(AF_INET, SOCK_STREAM, 0);
	if (matsock == -1) {
		printf("Matlab socket creation failed...\n");
		return(0);
	}
	else
		printf("Matlab Socket successfully created..\n");
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(portnum);
	if ((bind(matsock, (SA*)&servaddr, sizeof(servaddr))) != 0) {
		printf("Matlab socket bind failed...\n");
		return(0);
	}
	else
		printf("Matlab Socket successfully binded..\n");
  if ((listen(matsock, 5)) != 0) {
		printf("Matlab socket Listen failed...\n");
		return(0);
	}
	else
		printf("Matlab Server listening on port %d..\n",portnum);
  // Launch matlab server
  printf("Launching Matlab server in xterm window...\n");
  sprintf(buff,"./applauncher.sh %d",portnum) ;
  system(buff);
  bzero(buff, MAX);
	len = sizeof(cli);
  connfd = accept(matsock, (SA*)&cli, &len);
	if (connfd < 0) {
		printf("Matlab server accept failed...\n");
		return(0);
	}
	else
		printf("Matlab server accepts client...\n");
  write(matsock,"INIT",4);

  return(matsock);
}

// Handling comms between app req client and server.
void appFun(int sockAppReq, int portnum)
{
	char buff[MAX], appname[MAX];
  int matsock, connfd, len ;
  struct sockaddr_in servaddr, cli;

  // Start new matlab launch server and socket to communicate to it with
  matsock = create_matsock(portnum) ;
  if (!matsock)
    return ;

	// infinite loop for recieving and processing app requests
	for (;;) {
		bzero(buff, MAX);

		// read the message from client and copy it in buffer
		read(sockAppReq, buff, sizeof(buff));

		// print buffer which contains the client contents
		printf("Request from app req client: %s\n : ", buff);

    // exit : close server
		if (strncmp("exit", buff, 4) == 0) {
			printf("App Launcher Server Exit...\n");
			break;
		}

    // app launch command
    if (strncmp("launch ", buff, 7) == 0) {
      strcpy(appname,buff+7); 
			printf("Commanding launch of application %s...\n",appname);
      // Send app launch request to Matlab server
      bzero(buff, MAX);
      strcpy(buff,appname);
      write(matsock, appname, sizeof(buff));
      // Close this socket and open new Matlab server instance
      close(matsock);
		}

    sleep(1);
	}
  close(matsock);
}

// Driver function
int main(int argc, char *argv[])
{
	int sockAppReq, connfd, len, portnum ;
	struct sockaddr_in servaddr, cli;
  char syscmd[MAX] ;

	// Server socket to listen to new application launch requests
	sockAppReq = socket(AF_INET, SOCK_STREAM, 0);
	if (sockAppReq == -1) {
		printf("app req socket creation failed...\n");
		return(0);
	}
	else
		printf("app req Socket successfully created..\n");
	bzero(&servaddr, sizeof(servaddr));

	// assign IP, PORT
  portnum = getPort(1) ;
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(portnum);

	// Binding newly created socket to given IP and verification
	if ((bind(sockAppReq, (SA*)&servaddr, sizeof(servaddr))) != 0) {
		printf("app req socket bind failed...\n");
		return(1);
	}
	else
		printf("app req Socket successfully binded..\n");

	// Now server is ready to listen and verification
	if ((listen(sockAppReq, 5)) != 0) {
		printf("app req Listen failed...\n");
		return(1);
	}
	else
		printf("app req Server listening on port %d..\n",portnum);
	len = sizeof(cli);

	// Accept the data packet from client and verification
	connfd = accept(sockAppReq, (SA*)&cli, &len);
	if (connfd < 0) {
		printf("app req server accept failed...\n");
		return(1);
	}
	else
		printf("app req server accepts client...\n");

	// Function for chatting between app request client and server
	appFun(connfd,portnum+1);

	// After chatting close the socket
	close(sockAppReq);

  return(0);
}
