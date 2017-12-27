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
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include "md5sum.h"

int DIR_COUNT = 0;
char* GDIR = NULL;

void error(char *msg)
{
    perror(msg);
    exit(1);
}

typedef struct {
	char item1[50];
	char item2[50];
	char item3[50];
} replyItems;

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
// get base of filename
char* get_filename_base(char *filename) {
  char *dot = strrchr(filename, '.');
  if(!dot || dot == filename) return "";
  int size = strlen(filename);

  size_t newsize = size - 4;

  char *hold = malloc(sizeof(char) * (newsize + 1));
  strncpy(hold, filename, newsize);
  hold[newsize] = '\0';
  return hold;
}

int createCatalog(char *directory){
  int matched;
  struct dirent *ent;
  DIR *dir;
  DIR *newdir;
  char *name;
  int lengthOfFile;
  unsigned char sum[MD5_DIGEST_LENGTH];

  if ((dir = opendir(directory)) == NULL){
      closedir(dir);
      fprintf(stderr, "B Can't open %s\n", dir);
    }
  regex_t file;
  regcomp(&file, "^[\\.a-zA-Z0-9_-]+\\.(JPG|jpg|PNG|png|TIFF|tiff|GIF|gif)", REG_EXTENDED|REG_NOSUB != 0);

  while ((ent = readdir(dir)) != NULL){
    matched = -1;
    matched = regexec(&file, ent->d_name, (size_t) 0, NULL, 0);
    if(matched == 0){
      int len = strlen(directory);
      char last = directory[len-1];
      if(last != '/'){ //if dir doesn't have a slash at the end
        char new_str[len+2];
        check_slash(directory, new_str);
        name = concat_str(new_str, ent->d_name);
      }
      else{
        name = concat_str(directory, ent->d_name);
      }

      FILE *i = fopen(name, "r");
      if (i == NULL) exit(EXIT_FAILURE);
      //getting filesize
      fseek(i, 0, SEEK_END);
      lengthOfFile = ftell(i);
      rewind(i);
      fclose(i);


      //write information to catalog.csv
      const char *page;
      char *checksum = "";
      md5sum(name, sum);

      for (int i = 0; i < MD5_DIGEST_LENGTH; i++)
          asprintf(&checksum,"%s%02x", checksum,sum[i]);

      FILE *f2 = fopen("catalog.csv", "a");

      asprintf(&page,"%s, %i, %s\n", ent->d_name, lengthOfFile, checksum);
      DIR_COUNT++;
      fputs(page, f2);

      fclose(f2);

    }else if(strstr(ent->d_name, ".")==0){
       int len = strlen(directory);
       char last = directory[len-1];
       if(last != '/'){ //if dir doesn't have a slash at the end
         char new_str[len+2];
         check_slash(directory, new_str);
         name = concat_str(new_str, ent->d_name);
       }
       else{
         name = concat_str(directory, ent->d_name);
       }
       if ((newdir = opendir(name)) == NULL){
           closedir(newdir);
         }else{
           createCatalog(name);
         }
    }
  }
  regfree(&file);
  closedir(dir);
  return 0;
}

//searches through nested directories for the given filename
void search_helper(char *filename, char *directory, char* imgdir, char* check_sum){
  unsigned char sum[MD5_DIGEST_LENGTH];
  char *fullpath;
  struct dirent *ent;
  DIR *dir;
  DIR *newdir;
  if ((dir = opendir(directory)) == NULL){
      closedir(dir);
      fprintf(stderr, "C Can't open %s\n", dir);
    }

  //iterate through directory
  while ((ent = readdir(dir)) != NULL){
    int len = strlen(directory);
    char last = directory[len-1];
    if(last != '/'){ //if dir doesn't have a slash at the end
      char new_str[len+2];
      check_slash(directory, new_str);
      fullpath = concat_str(new_str, ent->d_name);
    }
    else{
      fullpath = concat_str(directory, ent->d_name);
    }

    //if file is found return its full path
    if(!strcmp(filename,ent->d_name)){
      char *checksum = "";
      md5sum(fullpath, sum);
      for (int i = 0; i < MD5_DIGEST_LENGTH; i++)
          asprintf(&checksum,"%s%02x", checksum,sum[i]);

      asprintf(&checksum,"%s%02x", checksum,'\0');

//_____________________________________________________________________________________________________

//this is where the method has successfully found the fullpath and checksum of the file in question
  memcpy(imgdir, fullpath, strlen(fullpath)+1);
  memcpy(check_sum, checksum, strlen(checksum)+1);
  //printf("FFF %s\n", fullpath);
  //printf("CCC %s\n", checksum);
//________________________________________________________________________________________________________


    //if file is a potential directory
    }else if(strstr(ent->d_name, ".")==0){
      if ((newdir = opendir(fullpath)) == NULL){
          closedir(newdir);
        }else{
          //recursive call to find_file on nested directory
          search_helper(filename, fullpath, imgdir, check_sum);
        }
    }
  }
  closedir(dir);
}

//take index as input and find file at that place is csv file
void find_file_index(int index, char* directory, char* imgdir, char* check_sum){
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
  char *filename = "";
  //read filename from csv file at index
  while(name[i]!=','){
    asprintf(&filename,"%s%c",filename, name[i]);
    i++;
  }
  asprintf(&filename,"%s%c",filename, '\0');
  //search for filename in directory
  search_helper(filename, directory, imgdir, check_sum);
}

int *find_file_ext(char* ext, char* directory){
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

int main(int argc, char *argv[])
{
  if(argc!=2){
		printf("Usage: ./server server.config\n\n");
		exit(0);
	}

  /* read through client config file, gets data */
  char sbuffer[256];

  char * line = NULL;
  size_t len = 0;
  ssize_t rread;
  int line_num = 1;
  char *line_val;
  //char dir_val[1] = "0";
  char *dir_val = malloc(245);
  char* dir_v = "-1";
  int port_val = -1;
  FILE *s = fopen("server.config", "r");
  if (s == NULL) exit(EXIT_FAILURE);


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
     port_val = atoi(name);
     //printf("port val %d\n", port_val);
     line_num++;
   }else{
     dir_val = name;
     asprintf(&dir_val,"%s%c",dir_val,'\0');
     //printf("directory %s\n",dir_val);
   }
   }fclose(s);
  /* while ((rread = getline(&line, &len, s)) != -1) {
    if(line_num == 1){
      line_val = line+7;
      port_val = atoi(line_val);
      printf("%d : %d\n", line_num, port_val);
      line_num++;
    }
    else if(line_num == 2){
      line_val = line+6;
      dir_v = line_val;
      int sssize = sizeof(dir_v);
      char dir_va[sssize-2];
      strncpy(dir_va, dir_v, sssize-3);
      dir_va[sssize-2] = '\0';
      char *dir_val = malloc(sssize-2);
      dir_val = &dir_va[0];
      printf("%s\n", dir_val);
      fflush(stdout);
      line_num++;
    }
  }
  fclose(s); */
 /*   End: read through config file, gets data */



 //initialize catalog.csv
 FILE *f = fopen("catalog.csv", "w+");
 if (f == NULL) exit(EXIT_FAILURE);
 fputs("filename, size, checksum\n", f);
 fclose(f);

 createCatalog("images/");


/*
/* listen for client connections, and have the proper response routines */
// port_val is port number
// dir_val is directory
char buffer[256];
char reply[256];
int sockfd, newsockfd, portno, clilen;
struct sockaddr_in serv_addr, cli_addr;
int n, itemRequestNum;
if (port_val == -1 || !strcmp(dir_val, "-1")) { //if we're missing directory or the port value
    fprintf(stderr,"ERROR, no port provided\n");
    exit(1);
}
sockfd = socket(AF_INET, SOCK_STREAM, 0); // setup socket
if (sockfd < 0)
   error("ERROR opening socket");
bzero((char *) &serv_addr, sizeof(serv_addr));
portno = port_val;
serv_addr.sin_family = AF_INET;
serv_addr.sin_addr.s_addr = INADDR_ANY;
serv_addr.sin_port = htons(portno);
if (bind(sockfd, (struct sockaddr *) &serv_addr,
         sizeof(serv_addr)) < 0)
         error("ERROR on binding");
listen(sockfd,5);
listen(sockfd,5);
clilen = sizeof(cli_addr);
newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen);
if (newsockfd < 0)
  error("ERROR on accept");

//Connection Opened..........................................................///
char chunk[5];
int bytes_readt = read(newsockfd, chunk, sizeof(chunk));
int chunk_size = atoi(chunk);
//printf("Chunk Size %d\n", chunk_size);

//find_file_index(7, "images");
/* Send csv file size
fseek(c, 0L, SEEK_END);
int siz = ftell(c);
fclose(c);
char cat_siz[sizeof(siz)];
sprintf(cat_siz,"%ld", siz);
printf("Size of catalog %d : %s\n", siz, cat_siz ); */
int bytes_read;
// Send csv file, to print to stdout
int fd = open("catalog.csv", O_RDONLY);
while(1){
  bzero(buffer,256);
  bytes_read = read(fd, buffer, sizeof(buffer));
  //printf("Bytes read %d.....\n\n", bytes_read);
  if(bytes_read == -1){
    fprintf(stderr,"ERROR, bad file name\n");
    fclose(fd);
    //close(sockfd);
    //close(newsockfd);
    exit(1);
  }

  if (bytes_read == 0){ // We're done reading from the file
        //printf("Server breaks from loop\n");
        break;
    }
  if (strstr(buffer, "disconnect")) {  // if the client disconnects
    printf("Recieved disconnect command, closing socket\n");
    return 0;
  }

  void *p = buffer;

  while( bytes_read > 0){
    int bytes_written = write(newsockfd, p, bytes_read);
    if(bytes_written == -1){
      break;
    }
    //printf("Wrote %d bytes.....\n", bytes_written);
    fflush(stdout);
    bytes_read -= bytes_written;
    //printf("%d bytes remaining\n", bytes_read);
    p += bytes_written;
  }
}
//printf("CSV FILE SENT..........\n\n");

/* identify what mode client wants to be in....................*/
  char mode[10];
  char type[5];
  bytes_read = read(newsockfd, mode, sizeof(mode));
  //printf("Bytes read %d\n", bytes_read);
  bytes_read = read(newsockfd, type, sizeof(type));
  //printf("Bytes read %d\n", bytes_read);
  char* my_type = "jpg";
  //printf("My mode: %s\n", mode);

  if (strstr(mode, "passive")) {  // Passive mode..........................
    //printf("Starting passive...on %s...\n\n", type);
  //  printf("Dir count is %d, Dir val is %s\n", DIR_COUNT, dir_val);
    char *imgdir = malloc(100);
    char *check_sum = malloc(100);
    int *files = malloc(200);
    char buller[chunk_size];
    if (strstr(type, "jpg")) {  // if the client disconnects
      my_type = "jpg";
    }
    else if (strstr(type, "gif")) {  // if the client disconnects
      my_type = "gif";
    }
    else if (strstr(type, "png")) {  // if the client disconnects
      my_type = "png";
    }
    else if (strstr(type, "tiff")) {  // if the client disconnects
      my_type = "tiff";
    }
    //printf("MyType %s\n", my_type);
    files = find_file_ext(my_type, dir_val);

    for(int i = 0; files[i] != 0; i++){
      find_file_index(files[i], dir_val, imgdir, check_sum);
      //printf("%s\n", imgdir);
      //printf("check_sum %s\n", check_sum);
        //printf("LKord %s\n", path_);

        int bytes_read = 0;
        int fd = open(imgdir, O_RDONLY);
        while(1){
          bzero(buller,chunk_size);
          bytes_read = read(fd, buller, sizeof(buller));
          //printf("Bytes Read.....%d\n", bytes_read);
          if(bytes_read == -1){
            fprintf(stderr,"ERROR, bad file name\n");
            close(sockfd);
            close(newsockfd);
            exit(1);
          }
          //printf("Bytes read %s.....\n\n", buffer);
          if (bytes_read == 0){ // We're done reading from the file
                break;}

          if(bytes_read < chunk_size){
          //  printf("%i\n\n", bytes_read);
          }

          if (strstr(buller, "disconnect")) {  // if the client disconnects
            printf("Recieved disconnect command, closing socket\n");
            close(sockfd);
            return 0;
          }
          void *p = buller;
          while( bytes_read > 0){
            int bytes_written = write(newsockfd, p, bytes_read);
            //printf("bytes written/......%d\n", bytes_written);
            if(bytes_written == -1){
              break;
            }
            //printf("Wrote %d bytes.....\n", bytes_written);
            bytes_read -= bytes_written;
            //printf("%d bytes remaining\n", bytes_read);
            p += bytes_written;
          }
        }
        //char done[1];
        //read(newsockfd, done, sizeof(done));
        sleep(1);
      } //end for
    //  printf("\n\n\n\n\n");
			}
  else if (strstr(mode, "active")) {  // if the client disconnects
    char type[5];
    char budder[chunk_size];
    bytes_read = -1;
    //bzero(buffer,256);
    char *imgdir = malloc(100);
    char *check_sum = malloc(100);
    char response[5];
    char but[50] = "Enter ID to download (0 to quit):";
    while(1){
      bzero(response,5);
      //printf("Again  \n");
      int bytes_written = write(newsockfd, but,  sizeof(but)); //message
      bytes_read = read(newsockfd, response, sizeof(response));
      int id_val = atoi(response);
      //printf("ID Val : %d\n", id_val);
      find_file_index(id_val, dir_val, imgdir, check_sum);
      //printf("imgdir %s\n", imgdir);
    //  printf("check_sum %s\n\n", check_sum);
      fflush(stdout);
      if (id_val == 0) {  // if the client disconnects
        printf("Recieved disconnect command, closing socket\n");
        break;
      }

      int fd = open(imgdir, O_RDONLY);
      while(1){
        char busser[chunk_size];
        bzero(busser,chunk_size);
        //printf("%s     ", imgdir);
        bytes_read = read(fd, busser, sizeof(busser));
        if(bytes_read == -1){
          fprintf(stderr,"ERROR, bad file name\n");
          close(sockfd);
          close(newsockfd);
          exit(1);
        }
        //printf("Bytes read %s.....\n\n", buffer);
        if (bytes_read == 0) // We're done reading from the file
              break;
        if (strstr(busser, "disconnect")) {  // if the client disconnects
          printf("Recieved disconnect command, closing socket\n");
          close(sockfd);
          return 0;
        }
        void *p = busser;
        while( bytes_read > 0){
          int bytes_written = write(newsockfd, p, bytes_read);
          //printf("bytes written/......%d\n", bytes_written);
          if(bytes_written == -1){
            break;
          }
          //printf("Wrote %d bytes.....\n", bytes_written);
          bytes_read -= bytes_written;
          //printf("%d bytes remaining\n", bytes_read);
          p += bytes_written;
        }
      }
      char done[1];
      read(newsockfd, done, sizeof(done));
      //sleep(1);
  }

}



//fclose(fd);
 //int bytes_written = write(newsockfd, cat_siz, siz);



close(sockfd);
close(newsockfd);


/* end listening */



	 return 0;
}
