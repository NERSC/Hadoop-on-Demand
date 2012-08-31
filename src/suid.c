#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc,char *argv[])
{
	char *args[2];

	if (argc<2){
		fprintf(stderr,"Usage: %s <uid>\n",argv[0]);
		return -1;
	}
        args[0]="bash";
        args[1]=NULL;
        if (getuid()!=0){
		fprintf(stderr,"You must be root to do this\n");
		return -1;
        }
	setgid(atoi(argv[1]));
	setuid(atoi(argv[1]));
	setegid(atoi(argv[1]));
	seteuid(atoi(argv[1]));
        execv("/bin/bash",args);
	return 0;
}
