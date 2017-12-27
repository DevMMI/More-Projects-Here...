#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

#include<pthread.h>

pthread_mutex_t lock;

struct ImageTuple {
  long FileId;
  char *FileName;
  char *FileType;
  int size;
  char *TimeOfModification;
  int ThreadId;
};

//get extension of filename
char *get_extension(const char *filename) {
    const char *dot = strrchr(filename, '.');
    if(!dot || dot == filename) return "";
    return dot + 1;
}

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

void write_html(char* directory, char* filename){

    pthread_mutex_lock(&lock);

    struct ImageTuple newfile;
    char *fullpath = concat_str(directory, filename);

    //get inode number and modification time
    struct stat sb;
    if (stat(fullpath, &sb) == -1) {
         perror("stat");
         exit(EXIT_FAILURE);
     }
     newfile.FileId = sb.st_ino;
     newfile.TimeOfModification = ctime(&sb.st_mtime);

     //get filename and extension
     newfile.FileName = get_filename_base(filename);
     newfile.FileType = get_extension(filename);

     //get file size
     FILE *f = fopen(fullpath, "r");
     fseek(f, 0, SEEK_END);
     newfile.size = ftell(f);
     fseek(f, 0, SEEK_SET);

     //get thread ID
     newfile.ThreadId = getpid();

     //write to the html page
     const char *page;
     FILE *catalog = fopen("catalog.html", "a");
     //if the file cannot be opened call perror
     if (f == NULL){
         perror("Error: ");
     }
     asprintf(&page,"<a href=./%s> <img src=./%s width=100 height=100></img></a><p align= left> %li, %s, %s, %i, %s, %i </p>", fullpath, fullpath, newfile.FileId, newfile.FileName, newfile.FileType, newfile.size, newfile.TimeOfModification, newfile.ThreadId);
     fputs(page, catalog);
     fclose(catalog);

     pthread_mutex_unlock(&lock);

}

void funccity(long id){
  if(id!=0){
    write_html("dir0/","3.bmp");
  }else{
    write_html("dir0/","2.jpg");
  }
}


int main(int argc, char *argv[]){

  //char * ext = get_extension("holy.jpg");
  //printf("%s\n", ext);

  //char *dir = argv[1];
  //check_slash(dir);
  //printf("%s\n", dir);

  if (pthread_mutex_init(&lock, NULL) != 0)
    {
        printf("\n mutex init failed\n");
        return 1;
    }

  FILE *f = fopen("catalog.html", "w+");
    //if the file cannot be opened call perror
    if (f == NULL){
      perror("Error: ");
    }
  fputs("<html><head><title>My Image Manager BMP</title></head><body>", f);
  fclose(f);

  long id = fork();
  funccity(id);

  pthread_mutex_destroy(&lock);


return 1;
}


/*
//add a slash to the end of the directory string if it does not have one
void check_slash(char* directory)
{
        int len = strlen(directory);
        char slash = directory[len-1];
        if(!(slash == '/')){
          strcat(directory, "/");}
}
*/
