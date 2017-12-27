#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

void error(char *msg)
{
	perror(msg);
	exit(0);
}

char* concat_str(const char *s1, const char *s2){
    char *result = malloc(strlen(s1) +strlen(s2)+1);//+1 for the zero-terminator
    if( result == NULL )
     {
       fprintf(stderr, "Failed to Allocate Memory to Concatenate Strings, exiting...\n" );
       exit( 0 );
     }
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

void write_html(char* directory, char* filename){
  char *fullpath = concat_str(directory, filename);
  const char *page;
  FILE *f = fopen("download.html", "a");
  //if the file cannot be opened call perror
  if (f == NULL){
    perror("Error: ");
  }
  asprintf(&page, "<a href='%s'>%s</a>", fullpath, filename);
  fputs(page, f);
  fclose(f);
}

int main(int argc, char *argv[])
{
	/* read through config file, gets data  //
	char sbuffer[256];
	char ip[20];
	char port[20];
	char chunk_size[20];
	char ImageType[20];

	char * line = NULL;
	size_t len = 0;
	ssize_t read;
	int line = 1;
	FILE *s = fopen("client.config", "r");
	if (s == NULL) exit(EXIT_FAILURE);

	while ((read = getline(&line, &len, s)) != -1) {
		if(line == 1){

			line++;
		}
		else if(line == 2){

			line++;
		}
		else if(line == 3){

			line++;
		}
		else if(line == 4){

			line++;
		}
			printf("%s", line);
	}
 //   End: read through config file, gets data */

	int sockfd, portno, n;
	struct sockaddr_in serv_addr;
	struct hostent *server;

	FILE *f = fopen("download.html", "w+");
	    //if the file cannot be opened call perror
	  if (f == NULL){
	    perror("Error: ");
	  }
	  fputs("<html><head><title>My Image Download BMP</title></head><body>", f);
	  fclose(f);

	char buffer[256];
	if (argc < 3) {
		fprintf(stderr,"usage %s hostname port\n", argv[0]);
		exit(0);
	}
	portno = atoi(argv[2]);
	sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if (sockfd < 0)
		error("ERROR opening socket");
	server = gethostbyname(argv[1]);
	if (server == NULL) {
		fprintf(stderr,"ERROR, no such host\n");
		exit(0);
	}
	bzero((char *) &serv_addr, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	bcopy((char *)server->h_addr,
		(char *)&serv_addr.sin_addr.s_addr,
		server->h_length);
	serv_addr.sin_port = htons(portno);
	if (connect(sockfd,&serv_addr,sizeof(serv_addr)) < 0)
		error("ERROR connecting");
	while(1) {
		//printf("Please enter the message: ");
		//bzero(buffer,256); //zeros out buffer
		// FILE *f = fopen("a.txt", "r");


		//fgets(buffer,255,stdin);
		//n = write(sockfd,buffer,strlen(buffer)); //writes to server
		if (n < 0)
			error("ERROR writing to socket");
		if (strstr(buffer, "disconnect")) {
			printf("Recieved disconnect command, closing socket\n");
			close(sockfd);
			return 0;
		}
		bzero(buffer,256);
		n = read(sockfd,buffer,255);
		if (n < 0)
			error("ERROR reading from socket");
		printf("%s\n",buffer);
	}
	return 0;
}
