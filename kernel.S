@ kernel.S 

@ ( -- argcaddr )
@ get ram address of command line argument count
Forthword_ ARGCADDR, 0, "argc#"
  user_ USER_ARGC
  end_
    
@ ( -- cmd[]addr )
@ get ram address of command line argument vector
Forthword_ ARGVADDR, 0, "argv#"
  user_ USER_ARGV
  end_
    
@ ( -- a-addr )
@ location of the cell containing the address of the next free ram location
Forthword_ HEREADDR, 0, "here#"
  user_ USER_HERE
  end_
    
@ ( -- a-addr )
@ the address of the next free ram location
Forthword_ HERE, 0, "here"
  do_ HEREADDR
  mw_
  end_


@ ( nx* -- ) (R: ny* -- )
@ initialize rf further. EXECs turnkey operation and go to quit
Forthword_ DOCMDARG, 0, "docmdarg"
  do_ ARGCADDR         @ ( ARGCADDR )
  mw_                  @ ( ARGC )
  push_                @ ( ARGC ARGC )
  lit_ 1               @ ( ARGC 1 )
  do_ GREATER          @ ( flag )
  iszero_
  if_0_ DOCMDARG_EXIT

  do_ ARGVADDR         @ ( ARGVADDR )
  mw_                  @ ( ARGV )
  fourplus_            @ ( ARGV+4 )
  mw_                  @ ( ptr )
.if BUILD_LEVEL > 9
  exit_do_ DOINCLUDE 
.endif

DOCMDARG_EXIT:
  end_

@ ( -- seconds usecs ) 
@ get time of day
@ gives the number of seconds and microseconds since the Epoch
Forthword_ TIME, 0, "time"
  zero_              @ ( 0 )
  push_              @ ( 0 0 )
  push_              @ ( 0 0 0 )
  dsp_               @ ( 0 0 DSP )
  movs r1, #0
  do_ gettimeofday   @ ( seconds usecs ? )
  pop_               @ ( seconds usecs )
  end_
    
@ ( -- n )
@ number of single-cell (4 byte) values contained in the data stack before n was placed on the stack.
Forthword_ DEPTH, 0, "depth"
  do_ DSP0           @ ( DSP0 )
  subs wreg, dsp     @ ( DSP0-dsp )
  fourslash_         @ ( (DSP0-dsp)/4 )
  end_

@ ( --  )
@ check stack underflow, throw exception 
Forthword_ QSTACK, 0, "?dsp"
  do_ DEPTH
  zeroless_
  iszero_
  if_0_ QSTACKFIN
    slit_ " Stack Underflow!"
    do_ THROW

QSTACKFIN:
  end_

@ USER variable used by catch/throw
Forthword_ HANDLER, 0, "handler"
  user_ ram_handler
  end_

@ ( i*x xt -- j*x 0 | i*x n )
@ setup handler to catch exceptions and then EXEC XT.
Forthword_ CATCH, 0, "catch"
  push_lr_
  rpushdsp_           @ ( xt ) (R: callerret DSP )
  push_               @ ( xt xt ) 
  do_ HANDLER         @ ( xt haddr )
  y_w_                @ ( xt haddr Y:haddr )
  mw_                 @ ( xt hxt )
  rpush_              @ ( xt hxt ) (R: callerret DSP hxt )
  rsp_                @ ( xt RSP ) (R: callerret DSP hxt)
  @ @haddr = rsp
  my_w_               @ ( xt RSP )
  pop_                @ ( xt )
  do_ EXEC
  @ restore handler
  rpopy_              @ ( ? Y:hxt) (R: callerret DSP )
  do_ HANDLER         @ ( haddr )
  mw_y_               @ ( haddr )
  rnip_               @ ( haddr ) (R: callerret)
  zero_               @ ( 0 )
  end_

@ ( straddr len -- )
@ throw an exception
@ will type the string passed in
Forthword_ THROW, 0, "throw"
  do_ TYPE           @ ( ? )
  do_ HANDLER        @ ( haddr )
  x_w_               @ ( haddr X:haddr )
  mw_                @ ( RP_handler )
  rsp_w_             @ ( RP_handler ) (R: callerret DSP hxt)
  rpop_              @ ( hxt ) (R: callerret DSP )
  mx_w_              @ ( hxt )
  rpopdsp_           @ ( DSP )(R: callerret )
  lit_ 1             @ ( 1 )
  end_

