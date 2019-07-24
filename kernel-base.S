@ kernel-base.S - minimum kernel to get if running

@ ( -- addr )
@ flags address
Forthword_ FFLAGS, 0, "fflags"
    user_  fflags
    bx lr
    
@ ( -- addr )
@ system state variable. 0 is interpret mode. Not 0 is compile mode
@ is half word
Forthword_ STATE, 0, "state"
    user_ state
    hmw_
    bx lr

Forthword_ STATESTORE, 0, "state="
    y_w_
    user_ state
    hmw_y_
    bx lr

@ ( --  )
@ enter interpreter mode
Forthword_ LBRACKET, IMMEDIATE_EN, "["
    zero_
    b STATESTORE

@ ( --  )
@ enter compile mode
Forthword_ RBRACKET, 0, "]"
    lit_ 1
    b STATESTORE


@ ( -- pauseaddr )
@ get ram address of pause defer
Forthword_ PAUSE_FETCH, 0, "pause@"
    user_ USER_PAUSE
    mw_
    bx lr

@ ( addr --  )
@ set pause to addr
Forthword_ PAUSE_STR, 0, "pause="
  y_w_
  user_ USER_PAUSE
  mw_y_
  bx lr

Forthword_ PAUSE_CLR, 0, "pause.clr"
  @ init pause to noop
  push {lr}
  lit32_ NOOP
  pop_lr_
  b PAUSE_STR

@ ( val -- char )
@ convert low byte of val to a printable hex character
Forthword_ NHEX, 0, "#h"
    movs r1, #0x0F
    and wreg, r1
    cmp wreg, #10
    blo.n NHEX_NEXT
    adds wreg, #7

    @ <then>
NHEX_NEXT:
    adds wreg, #48
    bx lr

@ ( n -- )
@ simple 4 bit hex print
Forthword_ PNIB, 0, ".h"
    push {lr}
    bl NHEX
    pop_lr_
    b EMIT

@ ( n -- )
@ simple 32 bit hex print
Forthword_ PHEX, 0, ".$"
    push {lr}
    lit_ '$
    bl EMIT
    lit_ 28
PHEX_BEGIN:
    y_d0_
    push_
    pushy_       @ ( n x n x )
    rshift_
    bl PNIB
    fourminus_
    bne.n PHEX_BEGIN

    pop_
    bl PNIB
    lit_ 32
    pop_lr_
    b EMIT

@ ( -- )
@ set terminate flag which indicates request to exit forth interpreter
Forthword_ BYE, 0, "bye"
    push {lr}
    bl FFLAGS
    x_w_
    lit_y_ 1 
    hmx_
    w_or_y_
    hmx_w_
    pop {pc}

@ ( -- )
@ send the READY prompt to the command line
Forthword_ PROMPTRDY, 0, ".>"
    push {lr}
    type_ "\n> testing... \n"
    pop {pc}

@ ( -- )
@ send the READY prompt to the command line
Forthword_ PROMPTCOMPILE, 0, ".:"
    push {lr}
    type_ "\n: "
    pop {pc}

@ ( -- )
@ send the OK prompt to the command line
Forthword_ PROMPTOK, 0, ".ok"
    push {lr}
    type_ " ok"
    pop {pc}

@ ( n -- )
@ process the error prompt
Forthword_ PROMPTERROR, 0, ".??"
    push {lr}
    type_ " ?? "
    pop {pc}

@ ( -- )
@ check if a ready prompt is required
Forthword_ QP_RD, 0, "?prd"
    push {lr}
    bl STATE
    @ output ready prompt if in interpret mode
    @ <-if>
    iszero_
    bne.n QP_RD_exit
      pop_lr_
      b PROMPTRDY

QP_RD_exit:
    @ <then>
      pop_lr_
      b PROMPTCOMPILE


@ ( -- flag )
@ refill the input buffer
@ flag is true if buffer needs processing ie full or enter pressed
Forthword_ DOREFILL, 0, "(refill)"
  push {lr}
  @ if just starting new input line then check prompt and reset input position
  bl G_IN                  @ ( >inaddr )
  hmw_                     @ ( >in )
  iszero_                  @ ( )
  beq.n DOREFILL_do
    bl INRESET

DOREFILL_do:
  @ refill the input buffer
  pop_lr_
  b REFILL                 @ ( f )

@ ( -- )
@ Fetch pause vector and EXEC it. may make a context/task switch
Forthword_ DOPAUSE, 0, "(pause)"
    push {lr}
    push_
    bl SLEEP @@ temp fix for cpu hogging
    bl PAUSE_FETCH
    pop_lr_
    b EXEC

@ ( -- )
@ main loop - iterate through scheduled tasks
Forthword_ DOTASKS, 0, "(tasks)"
    @ <begin>
    push {lr}
DOTASKS1:
    bl DOREFILL      @ ( flag )
    @ <if>
    iszero_
    beq.n DOTASK_N1
      @ there is something in the input buffer, try interpreting it
.if BUILD_LEVEL > 1
      bl DOINTERPRET
.endif
DOTASK_N1:
    bl DOPAUSE
    

    @ check to see if tasks should be terminated
    bl FFLAGS
    hmw_
    bittest_ TERMINATE_F
    @ <again>
    beq.n DOTASKS1
    pop {pc}


@ ( -- a-addr )
@ address of idletime
Forthword_ IDLETIMEADDR, 0, "idletime#"
  user_ USER_IDLETIME
  bx lr

@ ( n -- )
@ set idletime
Forthword_ IDLETIMESTORE, 0, "idletime="
  y_w_
  user_ USER_IDLETIME
  mw_y_
  bx lr
  
@ ( -- n )
@ get idletime
Forthword_ IDLETIMEFETCH, 0, "idletime@"
  user_ USER_IDLETIME
  mw_
  bx lr

@ ( n -- )
@ sleep for n micro seconds
Forthword_ USLEEP, 0, "usleep"
  b usleep


@ ( -- )
@ sleep for n micro seconds
Forthword_ SLEEP, 0, "sleep"
  push {lr}
  bl IDLETIMEFETCH
  iszero_
  beq.n NO_IDLESLEEP
    pop_lr_
    b USLEEP
NO_IDLESLEEP:
  pop {pc}

@ ( -- )
@ turn sleep off
Forthword_ SLEEPOFF, 0, "sleep.off"
  zero_
  b IDLETIMESTORE
 
@ ( -- )
@ turn sleep on
Forthword_ SLEEPON, 0, "sleep.on"
  lit_ 5000
  b IDLETIMESTORE

@ ( -- )
@ reset input source
Forthword_ RESET, 0, "reset"
  push {lr}

  @ reset input source for key
  lit32_ STDIN
  y_w_
  bl KEYADDR
  mw_y_

  bl EMIT_ON
  @ reset input buffer
  bl INRESET
  bl SLEEPON

.if BUILD_LEVEL > 2
  bl WSET
  zero_
  bl SMUDGE_STR
.endif

  bl PAUSE_CLR
  @ switch to interpret mode
  pop_lr_
  b LBRACKET
     
@ ( -- )
@ reset stacks and start over again
Forthword_ QUIT, 0, "quit"
    push {lr}
    @ reset data stack
    bl DSP0
    dsp_w_
    @ reset return stack pointers
    @bl RP0
    @fetch_
    @bl RP_STORE
    bl RESET
    pop_lr_
    b DOTASKS

