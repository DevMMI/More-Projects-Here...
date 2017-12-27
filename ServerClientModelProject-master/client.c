#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <regex.h>
#include <math.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include "md5sum.h"

void error(char *msg){
	perror(msg);
	exit(0);
}

int get_lines(){
	FILE *s = fopen("catalog.csv", "r");
	if (s == NULL) exit(0);
	char * line = NULL;
	size_t len = 0;
	ssize_t read;
	int count = 0;
	while ((read = getline(&line, &len, s)) != -1) {
			 count++;
	}
	return count-1;
}

//Concatenate two strings
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

//add a slash to the end of the directory string if it does not have one
void check_slash(char* directory, char* new_str){
  int len = strlen(directory);
  char last = directory[len-1];
  if(!(last == '/')){
    strncpy(new_str, directory, len);
    new_str[len] = '/';
    new_str[len+1] = '\0';
    }
}

// get extension of filename
char *get_extension(const char *filename) {
    const char *dot = strrchr(filename, '.');
    if(!dot || dot == filename) return "";
    return dot + 1;
}

void dumpCSV(){
	int fd = open("catalog.csv", O_RDONLY);
	int bytes_read;
	char buffer[256];
	while(1){
	  bzero(buffer,256);
	  bytes_read = read(fd, buffer, sizeof(buffer));

	  if(bytes_read == -1){
	    fprintf(stderr,"ERROR, bad file name\n");
	    fclose(fd);
	    exit(1);
	  }
	  //printf("Bytes read %s.....\n\n", buffer);
	  if (bytes_read == 0) // We're done reading from the file
	        break;

	  if (strstr(buffer, "disconnect")) {  // if the client disconnects
	    printf("Recieved disconnect command, closing socket\n");
	    return 0;
	  }
	 // printf("%s\n", buffer);
	}
	fclose(fd);
}

int is_empty(const char *s) { //src("http://stackoverflow.com/questions/3981510/getline-check-if-line-is-whitespace")
  while (*s != '\0') {
    if (!isspace(*s))
      return 0;
    s++;
  }
  return 1;
}

void display_csv(){
	char ignore[1024];
  int i;
	int index = 1;
  FILE *f = fopen("catalog.csv", "r");
  if (f == NULL) exit(EXIT_FAILURE);
  //find all files with given index in catalog.csv
	printf("===============================\n");
	printf("\nDumping contents of catalog.csv.............\n");
  fgets(ignore, sizeof(ignore), f);
  while(fgets(ignore, sizeof(ignore), f)){
    i = 0;
		printf("[%i] ", index);
		index++;
    while(ignore[i]!=','){
      printf("%c",ignore[i]);
      i++;
    }printf("\n");
	}
	printf("===============================\n");
}


int *find_file_ext(char* ext){
  char ignore[1024];
  char *filename;
  int i;
  int *nums = malloc(200);
  int nums_index = 0;
  int index = 1;
  FILE *f = fopen("catalog.csv", "r");
  if (f == NULL) exit(EXIT_FAILURE);
  //find all files with given index in catalog.csv
  fgets(ignore, sizeof(ignore), f);
  while(fgets(ignore, sizeof(ignore), f)){
    i = 0;
    filename = "";
    while(ignore[i]!=','){
      asprintf(&filename,"%s%c",filename, ignore[i]);
      i++;
    }
    if(!strcmp(get_extension(filename),ext)){
      nums[nums_index] = index;
      nums_index++;
    }index++;
  }nums[nums_index] = 0;
  return nums;
}

void find_file_index(int index, char* file){
  char name[1024];
  char ignore[1024];

  FILE *f = fopen("catalog.csv", "r");
  if (f == NULL) exit(EXIT_FAILURE);
  //find given index in catalog.csv
  for(int i=0; i<index; i++){
    fgets(ignore, sizeof(ignore), f);
  }
  fgets(name, sizeof(name), f);
  fclose(f);
  int i = 0;
  char *filename = "images/";
  //read filename from csv file at index
  while(name[i]!=','){
    asprintf(&filename,"%s%c",filename, name[i]);
    i++;
  }
  asprintf(&filename,"%s%c",filename, '\0');
  //search for filename in directory
  memcpy(file, filename, strlen(filename)+1);

}

void write_html(char* filename, int index){
	char *name = filename + 7;
	//printf("filename\n %s", filename);
  const char *page;
	char *checksum = "";
	unsigned char sum[MD5_DIGEST_LENGTH];

	md5sum(filename, sum);
	for (int i = 0; i < MD5_DIGEST_LENGTH; i++){
			asprintf(&checksum,"%s%02x", checksum,sum[i]);}

	char name2[1024];
	char ignore[1024];
	FILE *f = fopen("catalog.csv", "r");
	if (f == NULL) exit(EXIT_FAILURE);
	//find given index in catalog.csv
	for(int i=0; i<index; i++){
		fgets(ignore, sizeof(ignore), f);
	}
	fgets(name2, sizeof(name2), f);
	fclose(f);
	int i = 0;
  char *check = "";

	while(name2[i]!=','){
    i++;
  }i = i+2;printf("\n");
	while(name2[i]!=','){
    i++;
  }i = i+2;
	while(name2[i]!='\n'){
		asprintf(&check,"%s%c",check, name2[i]);
    i++;
	}asprintf(&check,"%s%c",check, '\0');

  FILE *f2 = fopen("download.html", "a");
  //if the file cannot be opened call perror
  if (f == NULL){
    perror("Error: ");
  }
	//printf("checksum %s\n", checksum);
	//printf("check %s\n", check);

	if(!strcmp(checksum, check)){
  asprintf(&page, "(Checksum match!) <a href='%s'>%s</a><br/>", filename, name);
}else{
	asprintf(&page, "(Checksum mismatch!)	<a href='%s'>%s</a><br/>", filename, name);
}
  fputs(page, f2);
  fclose(f2);
}

char * toArray(int number){ //src <http://stackoverflow.com/questions/14564813/how-to-convert-integer-to-character-array-using-c>
	int n = log10(number) + 1;
	int i;
	char *numberArray = calloc(n, sizeof(char));
	for ( i = 0; i < n; ++i, number /= 10 )
	{
		numberArray[i] = number % 10;
	}
	return numberArray;
}

int main(int argc, char *argv[]){

	if(argc!=2){
		printf("Usage: ./client client.config\n\n");
		exit(0);
	}

	struct stat st = {0};

	if (stat("images", &st) == -1) {
		mkdir("images", 0700);
	}
		FILE *f = fopen("download.html", "w+");
		//if the file cannot be opened call perror
		if (f == NULL){
			 perror("Error: ");
			 }
		fputs("<html><head><title>My Image Download BMP</title></head><body>", f);
		fclose(f);

	  char sbuffer[256];
		int bool_imgtypefound = 0;

	  char * line = NULL;
	  size_t len = 0;
	  ssize_t rread;
	  int line_num = 1;
	  char* ip_val = malloc(245);
		char ip[20];
	  int port_val;
	  int chunk_size;
	  char* img_type = malloc(10);
	  FILE *s = fopen("client.config", "r");
	  if (s == NULL) exit(0);


		char ignore[1024];
		while(fgets(ignore, sizeof(ignore), s)){
		int i = 0;
		char *name = "";
		while(ignore[i]!='='){
			i++;
		}
		i = i+2;
		while(ignore[i]!='\n'){
			asprintf(&name,"%s%c",name, ignore[i]);
			i++;
		}
		if(line_num == 1){
			ip_val = name;
			asprintf(&ip_val,"%s%c",ip_val,'\0');
			line_num++;
		}else if(line_num == 2){
			port_val = atoi(name);
	    line_num++;
		}else if(line_num == 3){
			chunk_size = atoi(name);
	    line_num++;
		}else{
			img_type = name;
			asprintf(&img_type,"%s%c",img_type,'\0');
			if(strstr(img_type,"jpg") || strstr(img_type,"png") || strstr(img_type,"gif") || strstr(img_type,"tiff")){
				bool_imgtypefound = 1;}}
		}fclose(s);

		//printf("server asdfasd |%s|\n",ip_val);
	 // printf("port val |%d|\n", port_val);
		//printf("chunk_size |%d|\n", chunk_size);
		//printf("image type |%s|\n",img_type);


	 //   End: read through config file, gets data
	 printf("===============================");
	 printf("\nConnecting server at %s, port %d\n", ip_val, port_val );

	 if(bool_imgtypefound == 1){ // Passive mode
		 printf("Chunk size is %d bytes. Image type is %s\n", chunk_size, img_type );
		 printf("===============================\n");
	 }
	 else{ // Interactive Mode
		 printf("Chunk size is %d bytes. No image type found.", chunk_size);
		 printf("===============================\n\n");
	 }

	 // Commence Dump


	int sockfd, portno, n;
	struct sockaddr_in serv_addr;
	struct hostent *server;
	FILE *received_file;
	int bytes_read;

	char buffer[256];

	portno = port_val;
	sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if (sockfd < 0)
		error("ERROR opening socket");
	server = gethostbyname(ip_val);
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


//Connection Opened..........................................................///
/****  Send Chunk Size *****/
char chunk[5];
int chunk_count;
int na = sprintf(chunk, "%d", chunk_size);
int bytes_writ = write(sockfd, chunk, sizeof(chunk));

	// Receive CSV file and dump it to stdout
	bzero(buffer,256);
	FILE *csv_file = fopen("catalog.csv", "w+");

	while(1){
		int bytes_read = read(sockfd, buffer, sizeof(buffer));
		//printf("bytes_read .... %d\n", bytes_read);
		//if (bytes_read == 0) break;
		//printf("%s\n", buffer);
		if (strstr(buffer, "disconnect")) {  // if the client disconnects
			printf("Recieved disconnect command, closing socket\n");
			return 0;
			}
			if(bytes_read < 256){
				fwrite(buffer, 1, bytes_read, csv_file);
				//printf("%s\n", buffer);
				fclose(csv_file);
				break;
			}
			//printf("%s\n", buffer);
		fwrite(buffer, 1, bytes_read, csv_file);

		bzero(buffer,256);
	}
	display_csv();
	int line_count = get_lines();
	//printf("%i\n",line_count);


	/* Decide which mode to go into, communicate that........................*/
	if (bool_imgtypefound){ // Passive mode only dl'd imgtype
	printf("Running in Passive Mode...Downloading %s files...\n\n", img_type);
		char buller[chunk_size];
		int *files = malloc(200);
		files = find_file_ext(img_type);

		char mode[10] = "passive";
		int bytes_written = write(sockfd, mode, sizeof(mode));
		//printf("wrote %d\n", bytes_written);
		bytes_written = write(sockfd, img_type, sizeof(img_type));
		//printf("wrote %d\n", bytes_written);

		for(int i = 0; files[i] != 0; i++){
			char* filename = malloc(200);
			find_file_index(files[i], filename);
			//printf("%s\n", filename);
			received_file = fopen(filename, "w+");

			bzero(buller, chunk_size);
			printf("Downloaded %s,", filename);
			while(1){

				int bytes_read = read(sockfd, buller, sizeof(buller));
				sleep(0.5);
				chunk_count+=1;
				if(bytes_read == 0){
					fclose(received_file);
					write_html(filename, files[i]);
					break;
				}

				if (strstr(buffer, "disconnect")) {  // if the client disconnects
					printf("Recieved disconnect command, closing socket\n");
					close(sockfd);
					return 0;
					}


					if(bytes_read < chunk_size){
						fwrite(buller, 1, bytes_read, received_file);
						//printf("%i\n\n", bytes_read);
						fclose(received_file);
						write_html(filename, files[i]);
						break;
					}
					fwrite(buller, 1, bytes_read, received_file);
				bzero(buller, chunk_size);
			}
			printf("%d chunks transmitted\n\n", chunk_count);
			//char done[1];
			//write(sockfd, done,  sizeof(done));

		}
		printf("Computing Checksums for downloaded files...\n Generating HTML file...\n");


		  //close(sockfd);
			//return 0;


	} // end Passive mode
	else { // Active mode let user choose which file to dl'd


			//printf("Active bih\n");
			//printf("Closed : %d\n", close(sockfd));
			char mode[10] = "active";
			int bytes_written = write(sockfd, mode, sizeof(mode));
			//printf("Wrote...%d\n", bytes_written);

			char type[5] = "none";
			bytes_written = write(sockfd, type, sizeof(type));//settled
			//printf("Wrote......%d\n", bytes_written);
			received_file = fopen("a.jpg", "w+");
			//bzero(buffer,256);
			char budder[chunk_size];

			while(1){
				chunk_count = 0;
				char response[5];
				bzero(response,5);
				char but[50];
				bzero(but,50);
				int bytes_read = read(sockfd, but, sizeof(but)); //msg
				sleep(.1);
				printf("%s\n", but);
				scanf("%s", response);
				int resp = atoi(response);
				if(resp == 0){
					close(sockfd);
					exit(0);
				}else if(resp > line_count){
					close(sockfd);
					printf("index out of bounds\n");
					exit(0);
				}
				if (strstr(budder, "disconnect")) {  // if the client disconnects
					printf("Recieved disconnect command, closing socket\n");
					close(sockfd);
					return 0;
					}
				bytes_written = write(sockfd, response,  sizeof(response)); //response
				bzero(budder,chunk_size);
				char *filename = malloc(200);
				find_file_index(resp, filename);
				printf("%s\n", filename);
				FILE *received_file = fopen(filename, "w+");
				printf("Downloaded %s,", filename);
				if(received_file == -1){
					exit(0);
				}
				while(1){
					int bytes_read = read(sockfd, budder, sizeof(budder));
					sleep(.1);
					chunk_count += 1;
					//printf("bytes read...%d\n", bytes_read);
					if(bytes_read == 0){
						fclose(received_file);
						write_html(filename, resp);
						break;
					}

						if(bytes_read < chunk_size){
							fwrite(budder, 1, bytes_read, received_file);
							fclose(received_file);
							write_html(filename, resp);
							break;
						}

					fwrite(budder, 1, bytes_read, received_file);
					bzero(budder,chunk_size);
				}
				printf("%d chunks transmitted\n\n", chunk_count);
				char done[1];
				write(sockfd, done,  sizeof(done));
				//fclose(received_file);
			}

	return 0;
  }
}
