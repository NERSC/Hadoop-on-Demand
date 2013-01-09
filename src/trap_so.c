/*
 * The Cray platforms do not have name services (i.e. passwd, ldap, etc) configured on the compute nodes.
 * This library can be preloaded to fix that.
 *
 */


#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <grp.h>
#include <string.h>
#include <dlfcn.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/un.h>



#define BUFSIZE 80

void init(void);
void __attribute__ ((constructor)) init(void);
//  void __attribute__ ((destructor)) my_fini(void);

int debug=0;

int getpwnam_r(const char *name, struct passwd *pwd, char *buf, size_t buflen, struct passwd **result)
{
   char *ptr;


  ptr=buf;
  if (init == NULL)
    init();
  if (debug)
    fprintf(stderr,"trapped getpwname_r\n");
  strcpy(ptr,getenv("USER"));
  pwd->pw_name=ptr;
  ptr+=strlen(ptr);
  ptr++;
  
  strcpy(ptr,"*");
  pwd->pw_passwd=ptr;
  ptr+=strlen(ptr);
  ptr++;

  strcpy(ptr,"theuser");
  pwd->pw_gecos=ptr;
  ptr+=strlen(ptr);
  ptr++;

  strcpy(ptr,getenv("HOME"));
  pwd->pw_dir=ptr;
  ptr+=strlen(ptr);
  ptr++;

  strcpy(ptr,getenv("SHELL"));
  pwd->pw_shell=ptr;
  ptr+=strlen(ptr);
  ptr++;

  pwd->pw_uid=getuid();
  pwd->pw_gid=getgid();
 
  *result=pwd; 
  return 0;
}

struct passwd * getpwuid(uid_t uid)
{
  char *buf;
  int buflen=BUFSIZE;
  struct passwd *pwd;
  struct passwd *result;

  if (debug)
    fprintf(stderr,"trapped getpwuid\n");
  buf=(char *)malloc(buflen);
  pwd=(struct passwd *)malloc(sizeof(struct passwd));
  if (buf==NULL || pwd==NULL){
	errno=ENOMEM;
	return NULL; 
  }
  getpwnam_r(NULL,pwd,buf,buflen,&result);
  return pwd;
}

struct group * getgrgid(gid_t gid)
{
  char *buf;
  int buflen=BUFSIZE;
  struct group *pwd;
  struct group *result;

  if (debug)
    fprintf(stderr,"trapped getpwuid\n");
  buf=(char *)malloc(buflen);
  pwd=(struct group *)malloc(sizeof(struct group));
  if (buf==NULL || pwd==NULL){
	errno=ENOMEM;
	return NULL; 
  }
  getgrnam_r(NULL,pwd,buf,buflen,&result);
  return pwd;
}

int getpwuid_r(uid_t uid, struct passwd *pwd, char *buf, size_t buflen, struct passwd **result)
{
  if (debug)
    fprintf(stderr,"trapped getpwuid\n");
  getpwnam_r(NULL,pwd,buf,buflen,result);
  return 0;
}

int getgrnam_r(const char *name, struct group *grp, char *buf, size_t buflen, struct group **result)
{
   char *ptr;


  ptr=buf;
  if (debug)
    fprintf(stderr,"trapped getgrnam\n");
  strcpy(ptr,getenv("USER"));
  grp->gr_name=ptr;
  ptr+=strlen(ptr);
  ptr++;
  
  strcpy(ptr,"*");
  grp->gr_passwd=ptr;
  ptr+=strlen(ptr);
  ptr++;

  grp->gr_mem=NULL;
  ptr+=strlen(ptr);
  ptr++;

  grp->gr_gid=getgid();
 
  *result=grp; 
  return 0;
}

int getgrgid_r(uid_t uid, struct group *grp, char *buf, size_t buflen, struct group **result)
{
  if (debug)
    fprintf(stderr,"trapped getgrgid\n");
  getgrnam_r(NULL,grp,buf,buflen,result);
  return 0;
}

void init(void)
{
  return;
}

