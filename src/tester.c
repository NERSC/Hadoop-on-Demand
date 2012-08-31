#include <stdio.h>
#include <sys/types.h>
#include <pwd.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>


int main(int argc, char * argv[])
{
  char buffer[1024];
  struct passwd pwd;   
  struct passwd *result;
  int i=0;
  int fd;

  getpwuid_r(getuid(), &pwd, buffer, 1024, &result);
  printf("0x%lx 0x%lx\n",&pwd,result);
  printf("%s %s\n",pwd.pw_name,pwd.pw_gecos);
}
