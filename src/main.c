/*
 * main.c - if c stub main entry 
 */

#include <stdlib.h>     /* exit(3) */
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <setjmp.h>
#include <sys/mman.h>

#include "input.h"

#define CODE_SIZE 0xffff

extern void COLD(void);
extern void RECOVER(void);
extern int USER_ARGC;
extern char **USER_ARGV;
extern int CPSTART;

static sigjmp_buf quitbuf;

void handler (int signo, siginfo_t *info, void *arg)
{
  printf("Signal: %s\n", strsignal(signo));
  printf("Faulted at address 0x%x\n", info->si_addr);
  
  siglongjmp( quitbuf, -1 );
}

void make_cp_memory_executable(void)
{
  int status = mprotect(&CPSTART, CODE_SIZE, PROT_READ | PROT_WRITE | PROT_EXEC);

  if (status) {
    perror("mprotect new code segment");
  }
}

int main(int argc, char *argv[])
{
  struct sigaction action;
  
  sigaction(SIGSEGV, NULL, &action);
  action.sa_sigaction = handler;
  action.sa_flags |= SA_SIGINFO;
  sigaction(SIGSEGV, &action, NULL);

  USER_ARGC = argc;
  USER_ARGV = argv;

  make_cp_memory_executable();
  set_input_mode();
  
  if (sigsetjmp(quitbuf, 1) != 0)
  { 
    RECOVER();
  }
	else 
  {
    COLD();
  }

  return 0;
}
