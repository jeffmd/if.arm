@  if.S 

@ build levels, increasing build level adds higher level functions
.set MIN_KERNEL,     0  @ minimum kernel built but with no interpreter
.set CORE_KERNEL,    1  @ higher level core and kernel functionality but no interpreter
.set INT_DICTIONARY, 2  @ interpreter and dictionary
.set CORE_INLINE,    3  @ inline core functions
.set NUMBER_BASE,    4  @ number conversion
.set INT_NUMBER,     5  @ number interpreter
.set COMPILER,       8  @ support routines for compiling
.set ASM_BASE,       9  @ asm routines used by compiler
.set INCLUDE,       12  @ include file support
.set ASM,           14  @ simple ARM thumb assembler
.set MATH_ADV,      16  @ advanced math routines 

.set BUILD_LEVEL, ASM_BASE

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

.if BUILD_LEVEL >= CORE_INLINE
  .include "core-inline.S"
.endif

.if BUILD_LEVEL >= NUMBER_BASE
  .include "number.S"
.endif

.if BUILD_LEVEL >= INT_NUMBER
  .include "interpret_number.S"
.endif

.if BUILD_LEVEL >= COMPILER
  .include "compiler.S"
.endif

.if BUILD_LEVEL >= ASM_BASE
  .include "asm-base.S"
.endif

.if BUILD_LEVEL >= ASM
  .include "asm.S"
.endif

.if BUILD_LEVEL >= INCLUDE
  .include "include.S"
.endif

.if BUILD_LEVEL >= MATH_ADV
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

.if BUILD_LEVEL >= CORE_KERNEL
  .include "core.S"
  .include "kernel.S"
.endif

.if BUILD_LEVEL >= INT_DICTIONARY
  .include "interpret.S"
  .include "dictionary.S"
.endif


@ ( nx* -- ) (R: ny* -- )
@ initialize asforth further. EXECs turnkey operation and go to quit
Forthword_ WARM, 0, "warm"
  do_ RESET
.if BUILD_LEVEL > CORE_KERNEL
  do_ ONLY
.if BUILD_LEVEL >= NUMBER_BASE
  do_ DECIMAL           @ default to decimal base
.endif
.endif

  type_ "if.arm 0.2\n"
  @ check if command line args need to be loaded
.if BUILD_LEVEL > CORE_KERNEL
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
  
.if BUILD_LEVEL > CORE_KERNEL
  do_ ONLY
.if BUILD_LEVEL >= NUMBER_BASE
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

.if BUILD_LEVEL > CORE_KERNEL
  do_ WIPE
.endif
  end_do_ WARM

.if BUILD_LEVEL > CORE_KERNEL
@ minimum.S must be last
.include "minimum.S"
.endif

.balign 4
@ ram pointers that need relocation on startup
addr_dstack: .word topdatastack
addr_sysvar: .word sysvar_base
addr_dpstart: .word DPSTART

