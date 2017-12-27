#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
#include <regex.h>
#include <pthread.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>

struct TypeInfo {
  char *inputdir;
  char imagetype;
};

struct ImageTuple {
  long FileId;
  char *FileName;
  char *FileType;
  int size;
  char *TimeOfModification;
  int ThreadId;
};

int G_COUNT=0;
char *G_INPUT;
pthread_t tid[100];
pthread_mutex_t count_mutex;
void* imageTypeCheckerHelper(void* imgtype);
int G_directoriesTraversed = 0;
int G_imagesHandled = 0;
int end_flag = 0;
char directories[128][128];
int dirPlace = 0;


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


// write html from directory and filename inputs
void write_html(char* directory, char* filename){
    G_imagesHandled++;
    printf("images: %i %s\n", G_imagesHandled, filename);

    struct ImageTuple newfile;
    char *fullpath = concat_str(directory, filename);
    //printf("%s\n", fullpath);
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

}

// Variant 1, searches for image files, does everything image-wise, if subdir
// found it creates another thread and calls dirImgChecker(itself) on it
// Iterates through a directory, if it finds a subdirectory, creates new thread to parse for that
void* dirImgChecker(void* input_dir){
  pthread_mutex_lock(&count_mutex);
  char *input_directory = (char *) input_dir;
  struct dirent *ent;
  DIR *dir;
  int matched = -1;

  if ((dir = opendir(input_directory)) == NULL)
    {
      closedir(dir);
      pthread_exit(NULL);

      fprintf(stderr, "Can't open %s\n", dir);
    }
    else{
    //printf("Dir : %s\n", input_directory);
    regex_t file;
    regcomp(&file, "^[\\.a-zA-Z0-9_-]+\\.(VIZ|viz|JPG|jpg|PNG|png|BMP|bmp|GIF|gif)", REG_EXTENDED|REG_NOSUB != 0);
    regex_t potentialdir;
    regcomp(&potentialdir, "^[a-zA-Z0-9_-]+", REG_EXTENDED|REG_NOSUB != 0);

      // Thread ID:

  	// Create attributes
  	pthread_attr_t attr;
  	pthread_attr_init(&attr);

  	//
    G_directoriesTraversed++;
    printf("directories: %i\n",G_directoriesTraversed);
    // iterates through a directory
    while ((ent = readdir(dir)) != NULL)
    {

      //printf("BAKAR!!\n" );
      char* concated_dir;
      matched = -1;
      matched = regexec(&file, ent->d_name, (size_t) 0, NULL, 0);
      if (!matched){  //Checks to see if file is a proper image type
          //printf("image: %s\n", ent->d_name);
          char *input_dir = input_directory;
          int len = strlen(input_dir);
          char last = input_dir[len-1];

          if(last != '/'){
            char new_str[len+2];
            check_slash(input_dir, new_str);
            write_html(new_str, ent->d_name);
          } //end if last != '/'
          else{
            write_html(input_dir, ent->d_name);
          }
        } // end matched

      else{
          matched = -1;
          matched = regexec(&potentialdir, ent->d_name, (size_t) 0, NULL, 0);
          if(!matched){ //if regex matches, and it's a potentialdir
            char *input_dir = input_directory;
            int len = strlen(input_dir);
            char last = input_dir[len-1];

            if(last != '/'){
              char new_str[len+2];
              check_slash(input_dir, new_str);
              concated_dir = concat_str(new_str, ent->d_name);
              struct stat path_stat;
              stat(concated_dir, &path_stat);
              int dir_bool = -1;
              dir_bool = S_ISREG(path_stat.st_mode);
              if(!dir_bool){
                G_COUNT++;
                //printf("Reach %s\n", concated_dir);
                pthread_create(&tid[G_COUNT], &attr, dirImgChecker, (void *)concated_dir);
              }

            } //end if last != '/'

            else{
              concated_dir = concat_str(input_directory, ent->d_name);
              struct stat path_stat;
              stat(concated_dir, &path_stat);
              int dir_bool = -1;
              dir_bool = S_ISREG(path_stat.st_mode);
              if(!dir_bool){
                G_COUNT++;
                //printf("Reach %s\n", concated_dir);
                pthread_create(&tid[G_COUNT], &attr, dirImgChecker, (void *)concated_dir);
              }
            }
          }//end matched

        } //end else

    }
    pthread_mutex_unlock(&count_mutex);

    regfree(&file);
    regfree(&potentialdir);
    closedir(dir);
    pthread_exit(NULL);
  }


}


// Variant 2, calls < > for each image-type, if subdir
// found it creates another thread and calls imageTypeChecker(itself) on it
void* imageTypeChecker(void* imgtype){
  int i;
  G_directoriesTraversed++;
  printf("Directories: %i\n",G_directoriesTraversed);
    struct TypeInfo *img = imgtype;
    char *inputdir = img->inputdir;
    printf("%s\n", img->inputdir);
    for(i=0;i<=dirPlace;i++){
      if(strcmp(directories[i], ))
    }

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    G_COUNT++;
    int a = G_COUNT;
    struct TypeInfo jpgType = {.inputdir = inputdir, .imagetype = 'j'};;
    struct TypeInfo pngType = {.inputdir = inputdir, .imagetype = 'p'};;
    struct TypeInfo bmpType = {.inputdir = inputdir, .imagetype = 'b'};;
    struct TypeInfo gifType = {.inputdir = inputdir, .imagetype = 'g'};;
    pthread_create(&tid[G_COUNT], &attr, imageTypeCheckerHelper, (void *)&jpgType);
    G_COUNT++;
    int b = G_COUNT;
    pthread_create(&tid[G_COUNT], &attr, imageTypeCheckerHelper, (void *)&pngType);
    G_COUNT++;
    int c = G_COUNT;
    pthread_create(&tid[G_COUNT], &attr, imageTypeCheckerHelper, (void *)&bmpType);
    G_COUNT++;
    int d = G_COUNT;
    pthread_create(&tid[G_COUNT], &attr, imageTypeCheckerHelper, (void *)&gifType);

    pthread_join(tid[a], NULL);
    pthread_join(tid[b], NULL);
    pthread_join(tid[c], NULL);
    pthread_join(tid[d], NULL);

    struct dirent *ent;
    DIR *dir;

    if ((dir = opendir(inputdir)) == NULL)
      {
        closedir(dir);
        pthread_exit(NULL);

        fprintf(stderr, "Can't open %s\n", dir);
      }
    int matched = -1;
    regex_t potentialdir;
    regcomp(&potentialdir, "^[a-zA-Z0-9_-]+", REG_EXTENDED|REG_NOSUB != 0);
    pthread_mutex_lock(&count_mutex);
    while ((ent = readdir(dir)) != NULL)
    {
      matched = -1;
      matched = regexec(&potentialdir, ent->d_name, (size_t) 0, NULL, 0);
      //printf("REACHED\n" );
      if(!matched){
        char* concated_dir;

        char *input_dir = inputdir;
        int len = strlen(input_dir);
        char last = input_dir[len-1];

        if(last != '/'){
          char new_str[len+2];
          check_slash(input_dir, new_str);
          concated_dir = concat_str(new_str, ent->d_name);
          struct stat path_stat;
          stat(concated_dir, &path_stat);
          int dir_bool = -1;
          dir_bool = S_ISREG(path_stat.st_mode);
          if(!dir_bool){
            G_COUNT++;
            //printf("Reach %s\n", concated_dir);
            struct TypeInfo dirInfo = {.inputdir = concated_dir, .imagetype = 'D'};
            pthread_create(&tid[G_COUNT], &attr, imageTypeChecker, (void *)&dirInfo);
          }

        } //end if last != '/'
        else{
          concated_dir = concat_str(input_dir, ent->d_name);
          struct stat path_stat;
          stat(concated_dir, &path_stat);
          int dir_bool = -1;
          dir_bool = S_ISREG(path_stat.st_mode);
          if(!dir_bool){
            G_COUNT++;
            //printf("Reach %s\n", concated_dir);
            struct TypeInfo dirInfo = {.inputdir = concated_dir, .imagetype = 'D'};
            pthread_create(&tid[G_COUNT], &attr, imageTypeChecker, (void *)&dirInfo);
              }
            }

        }// end matched

  } //end while
  pthread_mutex_unlock(&count_mutex);


  regfree(&potentialdir);
  closedir(dir);
  pthread_exit(NULL);

}



void* imageTypeCheckerHelper(void* imgtype){
  pthread_mutex_lock(&count_mutex);
  //printf("%s\n", img->inputdir);
  struct dirent *ent;
  DIR *dir;
  int matched = -1;
  struct TypeInfo *img = imgtype;
  char *input_directory = img->inputdir;
  char type = img->imagetype;
  //printf("Dir: %s, Type: %c\n", input_directory, type);
  regex_t imgcheck;

  if ((dir = opendir(input_directory)) == NULL)
    {
      closedir(dir);
      pthread_exit(NULL);

      fprintf(stderr, "Can't open %s\n", dir);
    }
  if(type == 'j'){
    regcomp(&imgcheck, "^[\\.a-zA-Z0-9_-]+\\.(JPG|jpg)", REG_EXTENDED|REG_NOSUB != 0);
  }else if(type == 'b'){
    regcomp(&imgcheck, "^[\\.a-zA-Z0-9_-]+\\.(BMP|bmp)", REG_EXTENDED|REG_NOSUB != 0);
  }else if(type == 'p'){
    regcomp(&imgcheck, "^[\\.a-zA-Z0-9_-]+\\.(PNG|png)", REG_EXTENDED|REG_NOSUB != 0);
  }else if(type == 'g'){
    regcomp(&imgcheck, "^[\\.a-zA-Z0-9_-]+\\.(GIF|gif)", REG_EXTENDED|REG_NOSUB != 0);
  }
  regex_t potentialdir;
  regcomp(&potentialdir, "^[a-zA-Z0-9_-]+", REG_EXTENDED|REG_NOSUB != 0);
  pthread_attr_t attr;
  pthread_attr_init(&attr);
  while ((ent = readdir(dir)) != NULL)
  {
    //printf("REACHED\n" );
    char* concated_dir;
    matched = -1;
    matched = regexec(&imgcheck, ent->d_name, (size_t) 0, NULL, 0);

    if (!matched){  //Checks to see if file is a proper image type,
        char *input_dir = input_directory;
        int len = strlen(input_dir);
        char last = input_dir[len-1];
        if(last != '/'){
          char new_str[len+2];
          check_slash(input_dir, new_str);
          write_html(new_str, ent->d_name);
        } //end if last != '/'
        else{
          write_html(input_dir, ent->d_name);
        }
      }


} //end while
    pthread_mutex_unlock(&count_mutex);
    regfree(&potentialdir);
    regfree(&imgcheck);
    closedir(dir);
    pthread_exit(NULL);

}
/* NOT DONE YET
/* Variant 3
void* levelTypeChecker(void* imgtype){
  pthread_mutex_lock(&count_mutex);
  struct TypeInfo *img = imgtype;
  char *inputdir = img->inputdir;
  pthread_attr_t attr;
  pthread_attr_init(&attr);
  struct dirent *ent;
  DIR *dir;
  if ((dir = opendir(inputdir)) == NULL)
    {
      closedir(dir);
      pthread_exit(NULL);

      fprintf(stderr, "Can't open %s\n", dir);
    }
    int matched = -1;
    regex_t potentialdir;
    regcomp(&potentialdir, "^[a-zA-Z0-9_-]+", REG_EXTENDED|REG_NOSUB != 0);
    pthread_mutex_lock(&count_mutex);
    while ((ent = readdir(dir)) != NULL){
      matched = -1;
      matched = regexec(&potentialdir, ent->d_name, (size_t) 0, NULL, 0);
      //printf("REACHED\n" );
      if(!matched){
        char* concated_dir;

        char *input_dir = inputdir;
        int len = strlen(input_dir);
        char last = input_dir[len-1];

        if(last != '/'){
          char new_str[len+2];
          check_slash(input_dir, new_str);
          concated_dir = concat_str(new_str, ent->d_name);
          struct stat path_stat;
          stat(concated_dir, &path_stat);
          int dir_bool = -1;
          dir_bool = S_ISREG(path_stat.st_mode);
          if(!dir_bool){
            G_COUNT++;
            //printf("Reach %s\n", concated_dir);
            struct TypeInfo dirInfo = {.inputdir = concated_dir, .imagetype = 'D'};
            pthread_create(&tid[G_COUNT], &attr, levelTypeCheckforDirs, (void *)&dirInfo);
          }
        } // end if last != '/'
        else{
          concated_dir = concat_str(input_dir, ent->d_name);
          struct stat path_stat;
          stat(concated_dir, &path_stat);
          int dir_bool = -1;
          dir_bool = S_ISREG(path_stat.st_mode);
          if(!dir_bool){
            G_COUNT++;
            //printf("Reach %s\n", concated_dir);
            struct TypeInfo dirInfo = {.inputdir = concated_dir, .imagetype = 'D'};
            pthread_create(&tid[G_COUNT], &attr, levelTypeCheckforDirs, (void *)&dirInfo);
              }
            }

        }// end matched

  } //end while

}

  pthread_mutex_unlock(&count_mutex);
}
void* levelTypeCheckforDirs(void* imgtype){

}
void* levelTypeCheckforImages(void* imgtype){

}
*/

long long current_timestamp() {
    struct timeval te;
    gettimeofday(&te, NULL); // get current time
    long long milliseconds = te.tv_sec*1000LL + te.tv_usec/1000; // caculate milliseconds
    // printf("milliseconds: %lld\n", milliseconds);
    return milliseconds;
}

void catalog(FILE *f2){
  const char *page;
  int i;
  int imagesHandled = 0;
  long timey = current_timestamp();
  long original_time = timey;
  while(end_flag==0 || imagesHandled!=G_imagesHandled){
    imagesHandled = G_imagesHandled;
    while(current_timestamp() < timey + 100);
    if(imagesHandled!=G_imagesHandled){
      asprintf(&page,"Time %i      #dir %i #files %i\n", current_timestamp()-original_time, G_directoriesTraversed, G_imagesHandled);
      fputs(page, f2);
      timey = current_timestamp();}
    else break;
    printf("\nwowsa\n\n");
  }
  fclose(f2);
  pthread_exit(NULL);
  }

int main(int argc, char *argv[]){
  FILE *f = fopen("catalog.html", "w+");
    //if the file cannot be opened call perror
    if (f == NULL){
      perror("Error: ");
    }
  fputs("<html><head><title>My Image Manager BMP</title></head><body>", f);
  fclose(f);

  FILE *f2 = fopen("catalog.log", "a");
    //if the file cannot be opened call perror
    if (f2 == NULL){
      perror("Error: ");
    }
  fputs("\nnew execution\n", f2);



  /*char * ext = get_extension("holy.jpg");
  printf("%s\n", ext);
  char *dir = argv[1];
  check_slash(dir);
  printf("%s\n", dir); */

  /*      Variant 1     */
  /*char *inputdir = "./A4/dir0";
  G_INPUT = inputdir;

  // Create attributes
  pthread_attr_t attr;
  pthread_attr_init(&attr);
  pthread_create(&tid[G_COUNT], &attr, catalog, (void *)f2);
  pthread_create(&tid[0], &attr, dirImgChecker, (void *)inputdir);
  pthread_join(tid[0], NULL);
  end_flag = 1;
  pthread_exit(NULL);

  /* end Variant 1     *********************/


        //Variant 2
  printf("v2\n");
  char *inputdir = "./A4/dir0";
  // Create TypeInfo struct
  struct TypeInfo type = {.inputdir = inputdir, .imagetype = 'D'};
  // Create attributes
  pthread_attr_t attr;
  pthread_attr_init(&attr);
  pthread_create(&tid[G_COUNT], &attr, catalog, (void *)f2);
  pthread_create(&tid[0], &attr, imageTypeChecker, (void *)&type);
  pthread_join(tid[0], NULL);
  end_flag = 1;
  pthread_exit(NULL);  /*

  /* end Variant 2     *********************/


  /* HTML testcode
  FILE *f = fopen("catalog.html", "w+");
    //if the file cannot be opened call perror
    if (f == NULL){
      perror("Error: ");
    }
  fputs("<html><head><title>My Image Manager BMP</title></head><body>", f);
  fclose(f);
  write_html("A4/dir0/","2.jpg");
  write_html("A4/dir0/","3.bmp"); */
  return 0;
}
