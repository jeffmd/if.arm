@  if.S 

.set BUILD_LEVEL, 4
@ BUILD_LEVEL 0: then a minimum kernel is built but with no interpreter
@ BUILD_LEVEL 1: core and kernel are working
@ BUILD_LEVEL 2: word interpreter and dictionary working
@ BUILD_LEVEL 3: core-inline working
@ BUILD_LEVEL 4: number working
@ BUILD_LEVEL 5: interpret_number working
@ BUILD_LEVEL 10: compiler and interpret number working
@ minimum kernel build has minimum word set needed to be up and running without interpreter

@ used to track when lr is pushed onto return stack: 0 - not pushed, 1 - pushed on return stack
.set PUSH_LR, 0
 
.syntax unified
.thumb

.set rpi2, 0

.include "macros.S"

@ size of the Terminal Input Buffer
.set TIBSIZE, 100
.set MAX_CONTEXTS, 10

.bss
.balign 4

datastack:
  .space 200
topdatastack:
  .space 8

.balign 2
sysvar_base:

.globl USER_ARGC
.globl  USER_ARGV

COLON_SMUDGE: .space 4
user_g_in: .space 2
state: .space 2
USER_BASE: .space 2
USER_PAUSE: .space 4
USER_KEY: .space 4
USER_KEYFILE: .space 4
USER_EMIT: .space 4
USER_ARGC: .space 4
USER_ARGV: .space 4
USER_HERE: .space 4
USER_IDLETIME: .space 4
ram_CURRENT: .space 4
ram_CONTEXTidx: .space 2
ram_CONTEXT: .space 4 * MAX_CONTEXTS @ 10 wordlists max
fflags: .space 2
ram_dp: .space 4
ram_cp: .space 4

# interpreter register copy
WR: .space 4
RA: .space 4
RB: .space 4
RX: .space 4
RY: .space 4

# litteral word defer
Lit_Interpret: .space 4
Lit_Compile: .space 4

rstack0: .space 4
ram_handler: .space 4
ram_sharptib: .space 2
ram_tib: .space TIBSIZE

EE_FORTHWORDLIST:
  .space 4 @ head pointer
  .space 4 @ name pointer
  .space 4 @ sibling link pointer
  .space 4 @ child pointer

DICTIONARY_START:
  .space 4
  @ start of user program area
DPSTART:
  .space 0xffff

  @ start of user ram area
HERESTART:
   .space 0xffff

  # start of user code area
CPSTART:
   .space 0xffff

@ start of hard coded program area that can not be modified at runtime
.text

.balign 2

.set VE_HEAD, 0

.if BUILD_LEVEL >= 3
  .include "core-inline.S"
.endif

.if BUILD_LEVEL >= 4
  .include "number.S"
.endif

.if BUILD_LEVEL >= 5
  .include "interpret_number.S"
.endif

.if BUILD_LEVEL >= 10
  .include "compiler.S"
  .include "asm.S"
  .include "include.S"
  .include "mathadv.S"
  @ .include "defer.S"
  @ .include "file.S"  
.endif

.include "core-base.S"
.include "cin.S"
.include "cout.S"
.include "math.S"
.include "string.S"
.include "kernel-base.S"

.if BUILD_LEVEL >= 1
  .include "core.S"
  .include "kernel.S"
.endif

.if BUILD_LEVEL >= 2
  .include "interpret.S"
  .include "dictionary.S"
.endif


@ ( nx* -- ) (R: ny* -- )
@ initialize asforth further. EXECs turnkey operation and go to quit
Forthword_ WARM, 0, "warm"
  do_ RESET
.if BUILD_LEVEL > 1
  do_ ONLY
.if BUILD_LEVEL > 3
  do_ DECIMAL           @ default to decimal base
.endif
.endif

  type_ "if.arm 0.2\n"
  @ check if command line args need to be loaded
.if BUILD_LEVEL > 1
  do_ DOCMDARG
.endif

  end_do_ QUIT

@ ( -- addr)
@ start address of the data stack
Forthword_ DSP0, 0, "dsp0"
  ldr wreg, addr_dstack
  end_

@ ( -- addr)
@ start address of return stack
Forthword_ RSP0, 0, "rsp0"
  user_ rstack0
  end_


.globl RECOVER
@.type RECOVER, @function

@ ( -- )
@ start up if after sig alarm ie segv.
.thumb_func
Forthword_ RECOVER, 0, "recover"
  push_lr_
  @ initialize data stack
  ldr dsp, addr_dstack
  @ initialize sysvar pointer
  ldr sysvar, addr_sysvar

  do_ RESET
  
.if BUILD_LEVEL > 1
	do_ ONLY
.if BUILD_LEVEL > 3
  do_ DECIMAL           @ default to decimal base
.endif
.endif

  type_ "recovering...\n"
  end_do_ QUIT


.globl COLD
@.type COLD, @function

@ ( -- )
@ start up if from cold.
.thumb_func
Forthword_ COLD, 0, "cold"
  push_lr_ @ save return
  @ initialize data stack
  ldr dsp, addr_dstack
  @ initialize sysvar pointer
  ldr sysvar, addr_sysvar

  rsp_
  y_w_
  do_ RSP0
  mw_y_

.if BUILD_LEVEL > 1
  do_ WIPE
.endif
  end_do_ WARM

.if BUILD_LEVEL > 1
@ minimum.S must be last
.include "minimum.S"
.endif

.balign 4
@ ram pointers that need relocation on startup
addr_dstack: .word topdatastack
addr_sysvar: .word sysvar_base
addr_dpstart: .word DPSTART

