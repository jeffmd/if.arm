@ kernel.S 

@ ( -- addr )
@ flags address
Forthword_ FFLAGS, 0, "fflags"
    douser_  fflags
    .set TERMINATE_F, 1
    @ bit 0 - Terminate Tasks

@ ( -- addr )
@ system state variable. 0 is interpret mode. Not 0 is compile mode
@ is half word
Forthword_ STATE, 0, "state"
    douser_ state

Forthword_ STATEFETCH, 0, "state@"
    push {lr}
    bl STATE
    hfetch_
    pop {pc}

@ ( --  )
@ enter interpreter mode
Forthword_ LBRACKET, IMMEDIATE_EN, "["
    push {lr}
    bl STATE
    pop_lr_
    b ZEROHSTORE

@ ( -- pauseaddr )
@ get ram address of pause defer
Forthword_ PAUSEADDR, 0, "pause#"
    douser_ USER_PAUSE

@ ( -- argcaddr )
@ get ram address of command line argument count
Forthword_ ARGCADDR, 0, "argc#"
    douser_ USER_ARGC

@ ( -- cmd[]addr )
@ get ram address of command line argument vector
Forthword_ ARGVADDR, 0, "argv#"
    douser_ USER_ARGV

@ ( -- a-addr )
@ location of the cell containing the address of the next free ram location
Forthword_ HEREADDR, 0, "here#"
    douser_ USER_HERE

@ ( -- a-addr )
@ the address of the next free ram location
Forthword_ HERE, 0, "here"
    push {lr}
    bl HEREADDR
    fetch_
    pop {pc}


@ ( -- a-addr )
@ address of idletime
Forthword_ IDLETIMEADDR, 0, "idletime#"
  douser_ USER_IDLETIME

@ ( n -- )
@ set idletime
Forthword_ IDLETIMESTORE, 0, "idletime!"
  push {lr}
  bl IDLETIMEADDR
  pop_lr_
  b STORE

@ ( -- n )
@ get idletime
Forthword_ IDLETIMEFETCH, 0, "idletime@"
  push {lr}
  bl IDLETIMEADDR
  fetch_
  pop {pc}


@ ( -- )
@ send the READY prompt to the command line
Forthword_ PROMPTRDY, 0, ".>"
    push {lr}
    type_ "\n> "
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
    pop_
    type_ " ?? "
    pop {pc}

@ ( -- )
@ check if a ready prompt is required
Forthword_ QP_RD, 0, "?prd"
    push {lr}
    bl STATEFETCH
    @ output ready prompt if in interpret mode
    @ <-if>
    zerosense_
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
  hfetch_                  @ ( >in )
  zerosense_               @ ( )
  beq.n DOREFILL_do
    bl INRESET

DOREFILL_do:
  @ refill the input buffer
  bl REFILL                @ ( f )
  pop {pc}

@ ( -- )
@ Fetch pause vector and EXEC it. may make a context/task switch
Forthword_ DOPAUSE, 0, "(pause)"
    push {lr}
    bl SLEEP @@ temp fix for cpu hogging
    bl PAUSEADDR
    fetch_
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
    zerosense_
    beq.n DOTASK_N1
      @ there is something in the input buffer, try interpreting it
      bl DOINTERPRET
DOTASK_N1:
    bl DOPAUSE
    

    @ check to see if tasks should be terminated
    bl FFLAGS
    hfetch_
    bittest_ TERMINATE_F
    @ <again>
    beq.n DOTASKS1
    pop {pc}

@ ( -- )
@ set terminate flag which indicates request to exit forth interpreter
Forthword_ BYE, 0, "bye"
    push {lr}
    one_
    bl FFLAGS
    hfetch_
    or_
    bl FFLAGS
    pop_lr_
    b HSTORE

@ ( -- )
@ reset input source
Forthword_ RESET, 0, "reset"
    push {lr}
    bl SMUDGE
    bl ZEROSTORE

    @ reset input source for key
    dolit32_ STDIN
    bl KEYADDR
    bl STORE

    @ reset output source for emit
    dolit32_ PUTCHAR
    bl EMITADDR
    bl STORE

    @ reset input buffer
    bl INRESET

    bl SLEEPON
    @ switch to interpret mode
    pop_lr_
    b LBRACKET
    
@ ( nx* -- ) (R: ny* -- )
@ initialize rf further. EXECs turnkey operation and go to quit
Forthword_ DOCMDARG, 0, "docmdarg"
    push {lr}
    bl ARGCADDR
    fetch_
    one_
    bl GREATER
    zerosense_
    beq.n DOCMDARG_EXIT

    bl ARGVADDR
    fetch_
    fourplus_
    fetch_
    bl DOINCLUDE 
       
DOCMDARG_EXIT:
    pop {pc}

@ ( -- seconds usecs ) 
@ get time of day
@ gives the number of seconds and microseconds since the Epoch
Forthword_ TIME, 0, "time"
    push {lr}
    push_
    movs wreg, #0
    push_
    push_
    mov r0, dsp
    movs r1, #0
    bl gettimeofday
    pop_
    pop {pc}
    
@ ( -- addr)
@ start address of return stack
Forthword_ RP0, 0, "rp0"
  douser_ rstack0

@ ( -- n )
@ number of single-cell (4 byte) values contained in the data stack before n was placed on the stack.
Forthword_ DEPTH, 0, "depth"
    push {lr}
    bl SP0
    spfetch_
    minus_
    fourslash_
    @ acount for value push on data stack
    oneminus_
    pop {pc}

@ ( --  )
@ check stack underflow, throw exception -4
Forthword_ QSTACK, 0, "?sp"
    push {lr}
    bl DEPTH
    zeroless_
    zerosense_
    beq.n QSTACKFIN
      @doliteral_ 0xBEF
      $lit_ " Stack Underflow!"
      bl THROW

QSTACKFIN:
    pop {pc}

@ USER variable used by catch/throw
Forthword_ HANDLER, 0, "handler"
  douser_ ram_handler

@ ( i*x xt -- j*x 0 | i*x n )
@ setup handler to catch exceptions and then EXEC XT.
Forthword_ CATCH, 0, "catch"
    push {lr}
    @ sp@ >r
    spfetch_            @ ( xt SP )
    to_r_               @ ( xt ) (R: ret -- callerret SP )
    @ handler @ >r
    bl HANDLER          @ ( xt haddr )
    fetch_              @ ( xt hxt )
    to_r_               @ ( xt ) (R: callerret SP hxt )
    @ rp@ handler !
    rpfetch_            @ ( xt RP ) (R: callerret SP hxt)
    bl HANDLER          @ ( xt RP haddr )
    bl STORE            @ ( xt )
    bl EXEC
    @ restore handler
    @ r> handler !
    r_from_             @ ( hxt ) (R: callerret SP )
    bl HANDLER          @ ( hxt haddr )
    bl STORE            @ ( )
    r_drop_             @ ( ) (R: callerret)
    zero_
    pop {pc}

@ ( straddr len -- )
@ throw an exception
@ will type the string passed in
Forthword_ THROW, 0, "throw"
    push {lr}
    bl TYPE
    bl HANDLER         @ ( haddr )
    fetch_             @ ( RP_handler )
    rpstore_           @ ( ) (R: callerret SP hxt)
    r_from_            @ ( hxt ) (R: callerret SP )
    bl HANDLER         @ ( hxt haddr )
    bl STORE           @ ( )
    r_from_            @ ( SP ) (R: callerret )
    spstore_           @ ( ... )
    one_               @ ( ... 1 )
    pop {pc}

@ ( n -- )
@ sleep for n micro seconds
Forthword_ USLEEP, 0, "usleep"
  mov r0, wreg
  pop_
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
  pop_
  pop {pc}

@ ( -- )
@ turn sleep off
Forthword_ SLEEPOFF, 0, "sleep.off"
  zero_
  b IDLETIMESTORE
 
@ ( -- )
@ turn sleep on
Forthword_ SLEEPON, 0, "sleep.on"
  dolit16_ 5000
  b IDLETIMESTORE
 
