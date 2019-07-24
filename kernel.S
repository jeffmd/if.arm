@ kernel.S 

@ ( -- argcaddr )
@ get ram address of command line argument count
Forthword_ ARGCADDR, 0, "argc#"
    user_ USER_ARGC
    bx lr
    
@ ( -- cmd[]addr )
@ get ram address of command line argument vector
Forthword_ ARGVADDR, 0, "argv#"
    user_ USER_ARGV
    bx lr
    
@ ( -- a-addr )
@ location of the cell containing the address of the next free ram location
Forthword_ HEREADDR, 0, "here#"
    user_ USER_HERE
    bx lr
    
@ ( -- a-addr )
@ the address of the next free ram location
Forthword_ HERE, 0, "here"
    push {lr}
    bl HEREADDR
    fetch_
    pop {pc}


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
Forthword_ QSTACK, 0, "?dsp"
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
  user_ ram_handler
  bx lr

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

