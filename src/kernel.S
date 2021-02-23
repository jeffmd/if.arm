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
Forthword_ HERE_STR, 0, "here="
  y_w_
  user_ USER_HERE
  mw_y_
  end_
    
@ ( -- a-addr )
@ the address of the next free ram location
Forthword_ HERE, 0, "here"
  user_ USER_HERE
  mw_
  end_


@ ( nx* -- ) (R: ny* -- )
@ initialize rf further. EXECs turnkey operation and go to quit
Forthword_ DOCMDARG, 0, "docmdarg"
  do_ ARGCADDR         @ ( ARGCADDR )
  mw_                  @ ( ARGC )
  d_w_                 @ ( ARGC ARGC )
  lit_ 1               @ ( ARGC 1 )
  do_ GREATER          @ ( flag )
  iszero_
  ifz_ DOCMDARG_EXIT

  do_ ARGVADDR         @ ( ARGVADDR )
  mw_                  @ ( ARGV )
  plus_4_              @ ( ARGV+4 )
  mw_                  @ ( ptr )
.if BUILD_LEVEL >= INCLUDE
  exit_do_ DOINCLUDE 
.endif

DOCMDARG_EXIT:
  end_

@ ( -- seconds usecs ) 
@ get time of day
@ gives the number of seconds and microseconds since the Epoch
Forthword_ TIME, 0, "time"
  zero_              @ ( 0 )
  d_w_               @ ( 0 0 )
  d_w_               @ ( 0 0 0 )
  dsp_               @ ( 0 0 DSP )
  x_0_
  do_ gettimeofday   @ ( seconds usecs ? )
  d_                 @ ( seconds usecs )
  end_
    
@ ( -- n )
@ number of single-cell (4 byte) values contained in the data stack before n was placed on the stack.
Forthword_ DEPTH, 0, "depth"
  do_ DSP0           @ ( DSP0 )
  subs wreg, dsp     @ ( DSP0-dsp )
  div_4_             @ ( (DSP0-dsp)/4 )
  end_

@ ( --  )
@ check stack underflow, throw exception 
Forthword_ QSTACK, 0, "?dsp"
  do_ DEPTH
  lesszero_
  iszero_
  ifz_ QSTACKFIN
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
  r_dsp_              @ ( xt ) (R: callerret DSP )
  d_w_                @ ( xt xt ) 
  do_ HANDLER         @ ( xt haddr )
  y_w_                @ ( xt haddr Y:haddr )
  mw_                 @ ( xt hxt )
  r_w_                @ ( xt hxt ) (R: callerret DSP hxt )
  rsp_                @ ( xt RSP ) (R: callerret DSP hxt)
  @ @haddr = rsp
  my_w_               @ ( xt RSP )
  d_                  @ ( xt )
  do_ EXEC
  @ restore handler
  y_r_                @ ( ? Y:hxt) (R: callerret DSP )
  do_ HANDLER         @ ( haddr )
  mw_y_               @ ( haddr )
  r_sub_1_            @ ( haddr ) (R: callerret)
  zero_               @ ( 0 )
  end_

@ ( straddr len -- )
@ throw an exception
@ will type the string passed in
Forthword_ THROW, 0, "throw"
  d_w_
  do_ RESET
  d_
  do_ TYPE           @ ( ? )
  do_ HANDLER        @ ( haddr )
  x_w_               @ ( haddr X:haddr )
  mw_                @ ( RP_handler )
  rsp_w_             @ ( RP_handler ) (R: callerret DSP hxt)
  r_                 @ ( hxt ) (R: callerret DSP )
  mx_w_              @ ( hxt )
  dsp_r_             @ ( DSP )(R: callerret )
  lit_ 1             @ ( 1 )
  end_

